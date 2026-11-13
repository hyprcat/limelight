import concurrent.futures
import gc
import logging
import os
import shutil
import subprocess

import boto3
import cv2
from django.conf import settings

from transcoder.models import VideoEngineVideopost

# The worker image needs: apt-get install ffmpeg libsm6 libxext6

BOTO_S3 = boto3.client(
    "s3",
    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    region_name=settings.AWS_S3_REGION_NAME,
)

# Videos both pipelines skip. This one was excluded by hand in production.
SKIPPED_VIDEO_IDS = {"f4557df3-7dfc-45f7-bb92-f2231ff3e4cc"}


def video_folder(video):
    """Return a video's folder name, the same under MEDIA_ROOT and in the bucket: its id without dashes."""
    return "".join(str(video.video_id).split("-"))


class VideoEncoder:
    """Turns an uploaded original.mp4 into one HLS rendition per resolution and uploads them to S3."""

    def __meta__(self) -> None:
        self.VERSION = 0.9
        self.MAX_OBJECT_LIMIT = 12
        self.USE_S3 = True
        self.BUILD = "BETA"
        # Rendition ladder, keyed by height. A rendition is made when the source is at least as wide.
        self.RESOLUTIONS = {
            144: {"width": 256, "maxrate": "300k", "audio_bitrate": "96k"},
            240: {"width": 426, "maxrate": "500k", "audio_bitrate": "128k"},
            360: {"width": 480, "maxrate": "800k", "audio_bitrate": "128k"},
            480: {"width": 854, "maxrate": "1500k", "audio_bitrate": "128k"},
            720: {"width": 1280, "maxrate": "3000k", "audio_bitrate": "192k"},
            1080: {"width": 1920, "maxrate": "6000k", "audio_bitrate": "192k"},
        }

    def __init__(self) -> None:
        self.__meta__()
        self.s3_client = BOTO_S3
        self.s3_bucket = settings.AWS_STORAGE_BUCKET_NAME
        logging.info(f"LIMELIGHT VIDEO ENCODER {self.VERSION} {self.BUILD}")

    def build_response(self, message):
        """Wrap a message in the response shape the core API uses."""
        return {"status": 200, "message": message}

    def fetch_video_object(self, video_id):
        """Return the video row, or None if it does not exist."""
        try:
            return VideoEngineVideopost.objects.get(video_id=video_id)
        except VideoEngineVideopost.DoesNotExist:
            return None

    def fetch_video_path(self, video: VideoEngineVideopost):
        """Download the uploaded original from S3 and return its local path, or None on failure."""
        formatted = video_folder(video)
        file_key = f"media/videos/{formatted}/original.mp4"
        local_file_path = os.path.join(settings.MEDIA_ROOT, f"videos/{formatted}/")
        os.makedirs(local_file_path, exist_ok=True)
        try:
            logging.info(f"Downloading {file_key}")
            self.s3_client.download_file(self.s3_bucket, file_key, local_file_path + "original.mp4")
            return local_file_path + "original.mp4"
        except Exception as e:
            logging.error(f"Error downloading video from S3: {str(e)}")
            return None

    def upload_to_s3(self, local_file_path, s3_key):
        """Upload every file under a local rendition folder to the given key prefix."""
        try:
            true_path = os.path.join(settings.MEDIA_ROOT, local_file_path)
            for root, _, files in os.walk(true_path):
                for file in files:
                    self.s3_client.upload_file(os.path.join(root, file), self.s3_bucket, s3_key + file)
            logging.info(f"Files uploaded to S3: {s3_key}")
        except Exception as e:
            logging.error(f"Error uploading to S3: {str(e)}")

    def get_video_file_info(self, video_obj, path) -> VideoEngineVideopost:
        """Read width, height, fps, frame count, duration and bitrate from the file into the video row."""
        if not isinstance(video_obj, VideoEngineVideopost):
            raise ValueError("Invalid video object provided")

        try:
            fixed_video_path = self.fix_video_file_structure(path)
            capture = cv2.VideoCapture(fixed_video_path)

            if not capture.isOpened():
                raise Exception("Error opening video file")

            video_obj.video_width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
            video_obj.video_height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
            video_obj.video_fps = capture.get(cv2.CAP_PROP_FPS)
            video_obj.video_frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
            video_obj.video_duration_seconds = video_obj.video_frame_count / video_obj.video_fps
            video_obj.video_bitrate = int(capture.get(cv2.CAP_PROP_BITRATE))

            # NOTE: OpenCV does not expose audio stream details, so these three hold video values.
            video_obj.audio_fps = int(capture.get(cv2.CAP_PROP_FPS))
            video_obj.audio_channels = int(capture.get(cv2.CAP_PROP_CHANNEL))
            video_obj.audio_bitrate = int(capture.get(cv2.CAP_PROP_BITRATE))

            capture.release()
            return video_obj

        except Exception as e:
            logging.error(f"Error in get_video_file_info: {str(e)}")
            raise

    def fix_video_file_structure(self, input_file):
        """Remux the file in place with the moov atom first, so OpenCV and players can read it."""
        try:
            temp_output_file = "/".join(input_file.split("/")[:-1]) + "/temp.mp4"
            ffmpeg_command = [
                "ffmpeg", "-i", input_file,
                "-c", "copy", "-movflags", "+faststart", "-y", temp_output_file,
            ]  # fmt: skip
            result = subprocess.run(ffmpeg_command)
            if result.returncode == 0:
                os.replace(temp_output_file, input_file)
            else:
                logging.warning(f"ffmpeg faststart remux failed for {input_file}")
        except Exception as e:
            logging.warning(f"Could not remux {input_file}: {str(e)}")
        return input_file

    def run_ffmpeg(self, video) -> bool:
        """Encode every rendition the source is wide enough for, two at a time, and upload each."""
        try:
            video_path = self.fetch_video_path(video)
            video = self.get_video_file_info(video, video_path)

            def convert_resolution(resolution_key, resolution_data, video_path, final_path):
                try:
                    output_file_path = os.path.join(final_path, "video.m3u8")
                    ffmpeg_command = [
                        "ffmpeg",
                        "-i", video_path,
                        "-c:v", "libx265",
                        "-preset", "veryfast",
                        "-crf", "28",
                        "-vf", f'scale=w={resolution_data["width"]}:h=-2',
                        "-b:v", resolution_data["maxrate"], "-b:a", resolution_data["audio_bitrate"],
                        "-map", "0:v:0", "-map", "0:a:0?",
                        "-f", "hls",
                        "-hls_time", "10", "-hls_flags", "independent_segments",
                        "-hls_playlist_type", "vod",
                        "-y", output_file_path,
                    ]  # fmt: skip

                    subprocess.run(ffmpeg_command)
                    self.upload_to_s3(final_path, f"media/videos/{video_folder(video)}/{resolution_key}/")

                except Exception as e:
                    logging.error(f"FFMPEG FAILED for resolution {resolution_key}: {str(e)}")

            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
                futures = []

                for resolution_key, resolution_data in self.RESOLUTIONS.items():
                    if video.video_width >= resolution_data["width"]:
                        resolution_directory = f"videos/{video_folder(video)}/{resolution_key}/"
                        final_path = os.path.join(settings.MEDIA_ROOT, resolution_directory)
                        os.makedirs(final_path, exist_ok=True)
                        video.max_transcoded_resolution = resolution_data["width"]
                        futures.append(
                            executor.submit(
                                convert_resolution,
                                resolution_key,
                                resolution_data,
                                video_path,
                                final_path,
                            )
                        )

                concurrent.futures.wait(futures)

            logging.info("All renditions finished.")
            video.is_encoded = True
            video.save()
            return True
        except Exception as e:
            video.is_processing = True
            video.save()
            self.clean_up_local(video)
            logging.error(f"FFMPEG FAILED: {str(e)}")
            return False

    def clean_up_local(self, video):
        """Delete the local rendition folders of a video."""
        for resolution_key in self.RESOLUTIONS:
            final_path = os.path.join(settings.MEDIA_ROOT, f"videos/{video_folder(video)}/{resolution_key}/")
            shutil.rmtree(final_path, ignore_errors=True)

        gc.collect()

    def start_pipeline(self, video_id):
        """Encode a video unless it is already encoded or another worker is on it."""
        if str(video_id) in SKIPPED_VIDEO_IDS:
            return
        video_obj = self.fetch_video_object(video_id)
        if video_obj.is_encoded or video_obj.is_processing:
            self.save_status(video_obj, False)
            return self.build_response("success")

        self.save_status(video_obj, True)
        ffmpeg_status = self.run_ffmpeg(video_obj)
        logging.info(f"FFMPEG FUNCTION COMPLETE - STATUS {ffmpeg_status}.")
        self.save_status(video_obj, False)
        return self.build_response("success" if ffmpeg_status else "pipeline failed.")

    def save_status(self, video_obj, is_processing):
        """Set or clear the flag that marks a video as being encoded."""
        video_obj.is_processing = is_processing
        video_obj.save()
