import gc
import json
import logging
import os
import shutil
import subprocess
import threading
import time
from statistics import median

import cv2
import ffmpeg
import nltk
import torch
import whisper
from bertopic import BERTopic
from bertopic.representation import KeyBERTInspired, MaximalMarginalRelevance
from bertopic.vectorizers import OnlineCountVectorizer
from django.conf import settings
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import sent_tokenize, word_tokenize
from PIL import Image
from scipy.special import expit
from sentence_transformers import SentenceTransformer
from skimage.metrics import structural_similarity as ssim
from sklearn.cluster import MiniBatchKMeans
from sklearn.decomposition import IncrementalPCA
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    VisionEncoderDecoderModel,
    ViTImageProcessor,
    pipeline,
)

from transcoder.manager import BOTO_S3, SKIPPED_VIDEO_IDS, video_folder
from transcoder.models import VideoEngineVideopost

CAPTION_MODEL = "nlpconnect/vit-gpt2-image-captioning"
CATEGORY_MODEL = "cardiffnlp/tweet-topic-latest-multi"
SENTIMENT_MODEL = "lxyuan/distilbert-base-multilingual-cased-sentiments-student"
# Category id stored when the classifier is not confident about any label.
UNCATEGORISED = 19
# Pause between the heavy stages so the GPU can release memory.
STAGE_PAUSE_SECONDS = 10


class Ronin:
    """The ML pipeline run on every uploaded video.

    It turns a video into text and then labels that text:
      1. detect the spoken language (whisper)
      2. transcribe English audio, translate anything else to English (insanely-fast-whisper)
      3. cut the video into scenes by frame similarity and caption one frame per scene (ViT-GPT2)
      4. merge the captions into the transcript at their timestamps
      5. score sentiment of the description and the transcript (DistilBERT)
      6. assign a topic cluster (the BERTopic model in topic_models/) and a category (tweet-topic)
    The results are written to the video's row in the core database.
    """

    def __meta__(self) -> None:
        self.VERSION = 0.1
        self.BUILD = "ALPHA"
        # Two sampled frames less similar than this (SSIM) start a new scene.
        self.SIMILARITY_THRESHOLD = 0.76
        # Seconds between sampled frames.
        self.VIDEO_SAMPLING_RATE = 1
        self.OUTPUT_DIR = settings.MEDIA_ROOT

    def __scene_classification_meta__(self):
        """Load the image captioning model that describes one frame per scene."""
        self.model = VisionEncoderDecoderModel.from_pretrained(CAPTION_MODEL)
        self.feature_extractor = ViTImageProcessor.from_pretrained(CAPTION_MODEL)
        self.tokenizer = AutoTokenizer.from_pretrained(CAPTION_MODEL)

        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)
        self.gen_kwargs = {"max_length": 16, "num_beams": 4}

    def load_sub_models(self):
        """Build the sub-models of the topic model.

        Only the embedding model is passed when the saved model is loaded. The
        others record the setup the topic model uses: PCA to 256 dimensions in
        place of UMAP, mini-batch k-means with 2048 clusters in place of HDBSCAN,
        and an online vectorizer, so it can be fitted in batches.
        """
        self.embedding_model = SentenceTransformer("all-distilroberta-v1")
        self.umap_model = IncrementalPCA(n_components=256)
        self.cluster_model = MiniBatchKMeans(n_clusters=2048, random_state=0)
        self.vectorizer_model = OnlineCountVectorizer(stop_words="english", decay=0.01)
        self.representation_model = {
            "KeyBERT": KeyBERTInspired(),
            "MMR": MaximalMarginalRelevance(diversity=0.4),
        }
        logging.info("Default sub-models loaded.")

    def __topic_modeller_meta__(self):
        # Only 5Mil_C10_Lite is in the repository.
        self.topic_modellers_available = ["2Mil_C4", "4Mil_C8_Heavy", "5Mil_C10_Lite"]
        self.topic_model_type = "5Mil_C10_Lite"
        self.load_sub_models()
        nltk.download("punkt")
        nltk.download("wordnet")
        nltk.download("stopwords")

    def __init__(self) -> None:
        self.__meta__()
        self.__topic_modeller_meta__()
        self.__scene_classification_meta__()
        self.load_model()
        self.s3_client = BOTO_S3
        self.s3_bucket = settings.AWS_STORAGE_BUCKET_NAME
        logging.info(f"LIMELIGHT'S RONIN {self.VERSION} {self.BUILD}")

    def load_model(self):
        """Load the saved BERTopic model from topic_models/."""
        model_path = f"topic_models/{self.topic_model_type}"
        self.topic_model = None
        if os.path.exists(model_path):
            self.topic_model = BERTopic.load(model_path, embedding_model=self.embedding_model)
        else:
            logging.error(f"Topic model not found at {model_path}")

    # Files
    # ------------------------------------------------------------------------------

    def make_path(self, video_obj) -> None:
        """Create the local working folders for a video."""
        self.VIDEO_FOLDER = self.OUTPUT_DIR + "/videos/" + video_folder(video_obj)
        self.OUTPUT_FOLDER = self.VIDEO_FOLDER + "/cache/"
        os.makedirs(self.OUTPUT_FOLDER, exist_ok=True)

    def fetch_video_object(self, video_id) -> VideoEngineVideopost | None:
        """Return the video row and prepare its working folders, or None if it does not exist."""
        try:
            obj = VideoEngineVideopost.objects.get(video_id=video_id)
            self.make_path(obj)
            return obj
        except VideoEngineVideopost.DoesNotExist:
            return None

    def fetch_video_path(self, video: VideoEngineVideopost) -> str:
        """Download the uploaded original from S3 and return its local path."""
        formatted = video_folder(video)
        file_key = f"media/videos/{formatted}/original.mp4"
        local_file_path = os.path.join(settings.MEDIA_ROOT, f"videos/{formatted}/")
        os.makedirs(local_file_path, exist_ok=True)

        result = {"file_path": None, "error": None}

        def download_video():
            try:
                logging.info(f"Downloading {file_key}")
                self.s3_client.download_file(self.s3_bucket, file_key, local_file_path + "original.mp4")
                result["file_path"] = local_file_path + "original.mp4"
            except Exception as e:
                result["error"] = str(e)
                logging.error(f"Error downloading video from S3: {str(e)}")

        # NOTE: this does not enforce a timeout. After 12000 seconds it still
        # waits for the download to finish, and only then reports a timeout.
        thread = threading.Thread(target=download_video)
        thread.start()
        thread.join(timeout=1200 * 10)

        if thread.is_alive():
            thread.join()
            result["error"] = "Download timed out"

        if result["error"]:
            raise Exception(result["error"])
        return result["file_path"]

    def upload_to_s3(self, local_file_path, s3_key):
        """Upload one file to the media bucket."""
        try:
            self.s3_client.upload_file(local_file_path, self.s3_bucket, s3_key)
            logging.info(f"File uploaded to S3: {s3_key}")
        except Exception as e:
            logging.error(f"Error uploading to S3: {str(e)}")

    def clean_up_local(self):
        """Free disk and GPU memory after a video.

        NOTE: this deletes all of MEDIA_ROOT, including the files of any video
        another worker on the same machine is still processing.
        """
        shutil.rmtree(self.OUTPUT_DIR)
        gc.collect()
        torch.cuda.empty_cache()

    def _check_file_exists(self, file_path):
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File doesn't exist: {file_path}")

    def _load_output_json(self, path="output.json"):
        self._check_file_exists(path)
        with open(path) as json_file:
            return json.load(json_file)

    # Audio: language, transcript, subtitles
    # ------------------------------------------------------------------------------

    def resize_video(self, input_file):
        """Write the working copy of the video that the rest of the pipeline reads.

        NOTE: with `-c copy` ffmpeg does not re-encode, so `-s hd480` has no
        effect. The copy keeps the source resolution with the moov atom moved first.
        """
        output_file = f"{self.OUTPUT_FOLDER}resized.mp4"
        self._check_file_exists(input_file)

        subprocess.run([
            "ffmpeg", "-i", input_file,
            "-s", "hd480",
            "-c", "copy", "-movflags", "+faststart", "-y", output_file,
        ])  # fmt: skip

        return output_file if os.path.isfile(output_file) else None

    def extract_audio(self, input_file):
        """Extract the audio track as mono WAV. Returns None when ffmpeg produced nothing."""
        self._check_file_exists(input_file)
        output_file = f"{self.OUTPUT_FOLDER}audio.wav"
        subprocess.run(["ffmpeg", "-i", input_file, "-ac", "1", output_file, "-y"])
        return output_file if os.path.isfile(output_file) else None

    def _has_audio_stream(self, input_file):
        probe = ffmpeg.probe(input_file)
        return any(stream["codec_type"] == "audio" for stream in probe["streams"])

    def recognize_audio_language(self, input_file):
        """Return the language code whisper finds most likely for the first 30 seconds of audio."""
        try:
            self._check_file_exists(input_file)
            model = whisper.load_model("base")
            audio = whisper.load_audio(input_file)
            audio = whisper.pad_or_trim(audio)
            mel = whisper.log_mel_spectrogram(audio).to(model.device)
            _, probs = model.detect_language(mel)
            return max(probs, key=probs.get)
        except Exception as e:
            raise RuntimeError(f"An error occurred during audio language recognition: {e}")

    def _transcribe_or_translate(self, input_file, task):
        """Run insanely-fast-whisper on the audio and return the path of its JSON output."""
        audio_path = self.extract_audio(input_file)
        output_path = f"{self.OUTPUT_FOLDER}output.json"
        subprocess.run([
            "insanely-fast-whisper",
            "--file-name", audio_path,
            "--batch-size", "12",
            "--task", task,
            "--transcript-path", output_path,
        ])  # fmt: skip
        return output_path

    def transcribe_video(self, input_file):
        """Transcribe the audio in its own language."""
        return self._transcribe_or_translate(input_file, "transcribe")

    def translate_video(self, input_file):
        """Transcribe the audio and translate it to English."""
        return self._transcribe_or_translate(input_file, "translate")

    def _subtitles_format_seconds(self, seconds):
        whole_seconds = int(seconds)
        milliseconds = int((seconds - whole_seconds) * 1000)

        hours = whole_seconds // 3600
        minutes = (whole_seconds % 3600) // 60
        seconds = whole_seconds % 60

        return f"{hours:02d}:{minutes:02d}:{seconds:02d},{milliseconds:03d}"

    def _subtitles_format_chunk(self, chunk, index):
        start, end = chunk["timestamp"][0], chunk["timestamp"][1]
        start_format, end_format = self._subtitles_format_seconds(start), self._subtitles_format_seconds(end)
        return f"{index}\n{start_format} --> {end_format}\n{chunk['text']}\n\n"

    def make_subtitles(self, input_file="output.json"):
        """Write the transcript as an SRT file next to the video. The pipeline does not call this yet."""
        output_file = f"{self.VIDEO_FOLDER}/subtitles.srt"
        data = self._load_output_json(input_file)

        string = ""
        for index, chunk in enumerate(data["chunks"], 1):
            string += self._subtitles_format_chunk(chunk, index)

        with open(output_file, "w", encoding="utf-8") as file:
            file.write(string)

    def make_transcript_text(self, output):
        """Join the transcript chunks into one string."""
        return "".join(chunk["text"] for chunk in output["chunks"])

    # Video: scenes and captions
    # ------------------------------------------------------------------------------

    def get_video_fps(self, input_file):
        cap = cv2.VideoCapture(input_file)
        fps = cap.get(cv2.CAP_PROP_FPS)
        cap.release()
        return fps

    def calculate_frame_similarity(self, frame1, frame2):
        """Return the structural similarity (SSIM) of two frames in greyscale."""
        gray_frame1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
        gray_frame2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)

        percentage, _ = ssim(gray_frame1, gray_frame2, full=True)
        return percentage

    def make_scenes(self, input_file):
        """Group sampled frames into scenes.

        One frame is sampled per VIDEO_SAMPLING_RATE seconds and compared with
        the next sample. A similarity below SIMILARITY_THRESHOLD starts a new scene.
        Returns {scene_id: {"frames": [frame indices], "similarity": highest seen}}.
        """
        cap = cv2.VideoCapture(input_file)
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        step = int(fps * self.VIDEO_SAMPLING_RATE)
        scenes = {}
        scene_id = 0

        for i in range(0, frame_count - 1, step):
            cap.set(cv2.CAP_PROP_POS_FRAMES, i)
            ret1, frame1 = cap.read()
            cap.set(cv2.CAP_PROP_POS_FRAMES, i + step)
            ret2, frame2 = cap.read()
            if not ret1 or not ret2:
                break

            similarity_index = self.calculate_frame_similarity(frame1, frame2)

            if scene_id not in scenes:
                scenes[scene_id] = {"frames": [], "similarity": 0}

            if similarity_index < self.SIMILARITY_THRESHOLD:
                if len(scenes[scene_id]["frames"]) == 0:
                    scenes[scene_id]["frames"].append(i)
                    scenes[scene_id]["similarity"] = similarity_index
                else:
                    scene_id += 1
                    scenes[scene_id] = {"frames": [i], "similarity": similarity_index}
            else:
                scenes[scene_id]["frames"].append(i)
                scenes[scene_id]["similarity"] = max(scenes[scene_id]["similarity"], similarity_index)

        cap.release()
        return scenes

    def get_scenes(self, scenes, fps):
        """Return (median frame index, its time in seconds) for every scene."""
        output = []
        for scene_info in scenes.values():
            median_frame_index = int(median(scene_info["frames"]))
            output.append((median_frame_index, median_frame_index / fps))
        return output

    def scenes_to_text(self, input_file, scene_frames):
        """Caption the given frames, 12 at a time, and return one description per frame."""
        cap = cv2.VideoCapture(input_file)
        images = []
        for frame_index in scene_frames:
            cap.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
            ret, frame = cap.read()
            if not ret:
                logging.warning(f"Failed to read frame {frame_index}")
                continue
            images.append(Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)))

        chunk_size = 12
        preds = []
        for i in range(0, len(images), chunk_size):
            torch.cuda.empty_cache()
            pixel_values = self.feature_extractor(images=images[i : i + chunk_size], return_tensors="pt").pixel_values
            pixel_values = pixel_values.to(self.device)
            output_ids = self.model.generate(pixel_values, **self.gen_kwargs)
            preds.extend(self.tokenizer.batch_decode(output_ids, skip_special_tokens=True))
            torch.cuda.empty_cache()
        return [pred.strip() for pred in preds]

    def attach_descriptions_to_scenes(self, scenes_median_frames, descriptions):
        """Pair every scene's time in seconds with its description."""
        if len(scenes_median_frames) != len(descriptions):
            raise Exception("number of scenes doesn't match number of descriptions")
        return [(scene[1], description) for scene, description in zip(scenes_median_frames, descriptions)]

    def _embed_scenes_to_transcript(self, transcript, scenes):
        """Prefix each transcript chunk with the descriptions of the scenes that start inside it.

        A chunk reads "( a man sitting at a desk,a laptop on a table) spoken words".
        """
        embedded_transcript = transcript.copy()
        for chunk in embedded_transcript["chunks"]:
            timestamp = chunk["timestamp"]
            if timestamp is None or timestamp[0] is None or timestamp[1] is None:
                continue
            for scene_start, scene_description in scenes:
                if timestamp[0] <= scene_start <= timestamp[1]:
                    text = chunk["text"]
                    if "(" in text:
                        splits = text.split(")")
                        chunk["text"] = splits[0] + f",{scene_description})" + splits[1]
                    else:
                        chunk["text"] = f"( {scene_description}){text}"
        return embedded_transcript

    def embed_scenes(self, median_frames, descriptions, path="output.json"):
        """Load the transcript and merge the scene descriptions into it."""
        if not os.path.exists(path):
            raise Exception(f"Transcribing or translating output is not available at the path {path}.")

        formatted_scenes = self.attach_descriptions_to_scenes(median_frames, descriptions)
        return self._embed_scenes_to_transcript(self._load_output_json(path), formatted_scenes)

    # Text: sentiment, topic and category
    # ------------------------------------------------------------------------------

    def get_score_for_label(self, scores_dict, target_label):
        for item in scores_dict:
            if item["label"] == target_label:
                return item["score"]
        return None

    def get_max_label(self, scores_dict):
        return max(scores_dict, key=lambda x: x["score"])["label"]

    def _do_sentiment_analysis(self, txt):
        """Score a text from -2 to 2. Empty text scores 0.

        Positive text scores 1 + P(positive) and neutral text scores P(neutral).
        NOTE: negative text scores -(1 + P(positive)); P(negative) was probably meant.
        """
        if txt == "" or txt is None:
            return 0

        classifier = pipeline(model=SENTIMENT_MODEL, return_all_scores=True)
        # The original passed the literal string "txt" here, so every video got the same score.
        scores_dict = classifier(txt, truncation=True)[0]
        label = self.get_max_label(scores_dict)

        sentiment_score = self.get_score_for_label(scores_dict, "neutral")
        if label == "positive":
            sentiment_score = self.get_score_for_label(scores_dict, "positive") + 1
        elif label == "negative":
            sentiment_score = (1 + self.get_score_for_label(scores_dict, "positive")) * -1

        return sentiment_score

    def get_description_sentiments(self, video_obj):
        return self._do_sentiment_analysis(video_obj.video_description)

    def get_video_sentiments(self, video_obj):
        return self._do_sentiment_analysis(video_obj.transcript)

    def pre_process_text(self, document):
        """Lowercase and lemmatize a text and drop English stop words."""
        lemmatizer = WordNetLemmatizer()
        stop_words = set(stopwords.words("english"))

        clean_sentences = ""
        for sentence in sent_tokenize(document):
            clean_words = [
                lemmatizer.lemmatize(word.lower()) for word in word_tokenize(sentence) if word not in stop_words
            ]
            # NOTE: sentences are joined without a space between them.
            clean_sentences += " ".join(clean_words).strip()

        return clean_sentences

    def get_topic_name(self, text):
        """Return (cluster id, cluster names) from the topic model for a text."""
        if self.topic_model is None:
            logging.error("Topic model is not loaded.")
            return None
        topics, _ = self.topic_model.transform(text)
        cluster_id = topics[0]
        cluster_name = list(self.topic_model.get_topic_info(cluster_id)["Name"])
        return (cluster_id, cluster_name)

    def predict_category(self, text):
        """Run the tweet-topic classifier on the first 512 tokens of a text. The model is loaded on every call."""
        self.category_model = AutoModelForSequenceClassification.from_pretrained(CATEGORY_MODEL)
        tokenizer = AutoTokenizer.from_pretrained(CATEGORY_MODEL, allow_long_sentences=True)
        tokenizer.model_max_length = 512

        tokens = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
        if "input_ids" not in tokens or len(tokens["input_ids"]) == 0:
            raise ValueError("Tokenizer did not produce valid input tokens.")
        return self.category_model(**tokens)

    def clean_output_pre_trained(self, output):
        """Return the id of the highest scoring label above 0.5, or UNCATEGORISED when there is none."""
        class_mapping = self.category_model.config.id2label
        scores = expit(output[0][0].detach().numpy())
        confident = {category: score for score, category in zip(scores, class_mapping) if score > 0.5}
        if not confident:
            return UNCATEGORISED
        return max(confident, key=confident.get)

    def use_pretrained_hugging_face_categorizer(self, text):
        return self.clean_output_pre_trained(self.predict_category(text))

    def start_topic_modelling(self, text_content):
        """Return (topic cluster id, cluster names, category id) for a transcript."""
        clean_document = self.pre_process_text(text_content)
        topic_cluster_id = self.get_topic_name(clean_document)
        topic_category_id = self.use_pretrained_hugging_face_categorizer(clean_document)
        return (topic_cluster_id[0], topic_cluster_id[1], topic_category_id)

    # Pipeline
    # ------------------------------------------------------------------------------

    def start_pipeline(self, video_id):
        """Run the whole pipeline on one video and save the results on its row."""
        if str(video_id) in SKIPPED_VIDEO_IDS:
            return
        video_obj = self.fetch_video_object(video_id)
        video_path = self.fetch_video_path(video_obj)

        if not video_obj.gone_through_ml and not video_obj.ml_processing_happening:
            torch.cuda.empty_cache()
            try:
                logging.info(f"Video title: {video_obj.title}")
                video_obj.ml_processing_happening = True
                video_obj.save()
                resized_path = self.resize_video(video_path)
                video_language = self.recognize_audio_language(resized_path)
                logging.info(f"Video language: {video_language}")

                if video_language == "nn":
                    video_obj.transcript = "Hazel AI has trouble in identifying language of this video."
                    self.finish(video_obj)
                    return

                if video_language == "en":
                    transcript_path = self.transcribe_video(resized_path)
                else:
                    transcript_path = self.translate_video(resized_path)
                time.sleep(STAGE_PAUSE_SECONDS)
                torch.cuda.empty_cache()

                logging.info("Finding scenes")
                scenes = self.make_scenes(resized_path)
                fps = self.get_video_fps(resized_path)
                scenes_median_frames = self.get_scenes(scenes, fps)
                time.sleep(STAGE_PAUSE_SECONDS)

                logging.info("Describing scenes")
                scene_descriptions = self.scenes_to_text(resized_path, [frame for frame, _ in scenes_median_frames])
                time.sleep(STAGE_PAUSE_SECONDS)

                output = self.embed_scenes(scenes_median_frames, scene_descriptions, transcript_path)
                time.sleep(STAGE_PAUSE_SECONDS)
                torch.cuda.empty_cache()

                # The original assigned the language to `video_obj.video`, which is not a column.
                video_obj.language = video_language
                video_obj.transcript = self.make_transcript_text(output)
                video_obj.description_sentiment = self.get_description_sentiments(video_obj)
                video_obj.transcript_sentiment = self.get_video_sentiments(video_obj)
                torch.cuda.empty_cache()

                topic_id, _, topic_category_id = self.start_topic_modelling(video_obj.transcript)
                if video_obj.topic_id is not None:
                    video_obj.topic_id = topic_id
                    video_obj.topic_category_id = topic_category_id

                self.finish(video_obj)
                logging.info("Done with video ML.")
                time.sleep(STAGE_PAUSE_SECONDS)
                return
            except Exception as e:
                logging.error(f"ERROR WITH PIPELINE {str(e)}")
                self.save_status(video_obj, False)
                raise

        if video_obj.topic_category_id == -1:
            logging.error("Somehow topic id is -1. Ignoring for now.")
            self.save_status(video_obj, False)
            raise Exception("Something went wrong with the video ML processing.")

        self.clean_up_local()

    def finish(self, video_obj):
        """Mark a video as processed, save it and delete the local files."""
        video_obj.gone_through_ml = True
        video_obj.ml_processing_happening = False
        self.save_video_with_timeout(video_obj)
        self.clean_up_local()

    def save_status(self, video_obj, gone_through_ml):
        video_obj.gone_through_ml = gone_through_ml
        video_obj.save()

    def save_video_with_timeout(self, video_obj, timeout=10):
        """Save the row in a thread and raise if the database has not answered within the timeout.

        Returns the error text, or None on success.
        """
        result = {"error": None}

        def thread_function():
            try:
                video_obj.save()
            except Exception as e:
                result["error"] = str(e)

        thread = threading.Thread(target=thread_function)
        thread.start()
        thread.join(timeout)

        if thread.is_alive():
            raise Exception("Timeout while saving")
        return result["error"]
