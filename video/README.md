# LimeLight Video

The video worker of LimeLight Social. It does two jobs for every uploaded video: it transcodes the file into HLS renditions, and it runs an ML pipeline that produces a transcript, scene descriptions, sentiment scores, a topic and a category. The API server in `../core` uses those results for playback, search, categories and ranking.

This is code from 2023 and 2024, published as it was. It last ran in production in October 2024 and is not maintained. It was tidied for reading before publication: dead code removed, files renamed, comments added. That pass was not tested, so expect to fix things if you try to run it. Known holes are marked in the code with `NOTE:` comments.

## What is in here

A Django project used as a Celery worker host. It has no tables of its own for videos. It connects to the core API's Postgres database and reads and updates the video rows through unmanaged models.

```
transcoder/
  manager.py      VideoEncoder: the ffmpeg HLS pipeline
  tasks.py        the Celery tasks and the periodic checker
  views.py        the two HTTP endpoints
  models.py       unmanaged mirrors of the core tables, generated with inspectdb
  db_router.py    keeps the Celery beat schedule in a local SQLite file
machine_learning/
  manager.py      Ronin: the ML pipeline
topic_models/
  5Mil_C10_Lite/  the saved topic model
notebooks/
  ml.ipynb        the notebook the ML pipeline was prototyped in
config/           settings, urls, Celery app
limelight_video/  cookiecutter-django leftovers (User model, templates)
compose/, docker-compose-*.yml, appspec.yml, scripts/    deployment
```

## Endpoints

| Method | Path | Purpose | Auth |
|---|---|---|---|
| POST | `/transcoder/start_encoding_task` | Queue HLS transcoding for the `video_id` in the JSON body. | none |
| POST | `/transcoder/start_ml_task` | Queue the ML pipeline for the `video_id` in the JSON body. | none |

Both are in `transcoder/views.py`. They have no authentication. The rest of `config/urls.py` is the cookiecutter-django template (admin, allauth, a users API).

## Background jobs

`transcoder/tasks.py`:

- `periodic_checker`, every 3 minutes (`CELERY_BEAT_SCHEDULE` in `config/settings/base.py`): queues every video with `gone_through_ml=False` for the ML pipeline and every video with `is_encoded=False` that is not being encoded for transcoding, oldest first. This is how work normally arrives. It also logs the size of both backlogs.
- `start_encoding_pipeline_async`, on `encoder_queue`: runs `VideoEncoder.start_pipeline` and records a failure on the video row.
- `start_ml_pipeline_async`, on `ml_queue`: runs `Ronin.start_pipeline` and records a failure on the video row.

## Transcoding

`VideoEncoder` in `transcoder/manager.py`:

1. Downloads `media/videos/<video id without dashes>/original.mp4` from S3.
2. Remuxes it with the moov atom first, then reads width, height, frame rate and duration with OpenCV and saves them on the video row.
3. Encodes one rendition for each rung of the ladder that the source is wide enough for: 144, 240, 360, 480, 720 and 1080. Each is an ffmpeg run with libx265, CRF 28, preset `veryfast`, cut into 10 second HLS segments with a VOD playlist. Two renditions run at a time.
4. Uploads each rendition to `media/videos/<id>/<height>/` in the same bucket and sets `is_encoded`.

There is no master playlist. The client picks a resolution and asks the core API for `/video_engine/stream/<video_id>/<resolution>/video.m3u8`, which reads the file from S3.

## The ML pipeline

`Ronin` in `machine_learning/manager.py`. For one video it runs these steps in order:

1. **Language.** Whisper `base` detects the spoken language from the first 30 seconds of audio.
2. **Transcript.** `insanely-fast-whisper` transcribes English audio. Other languages are translated to English.
3. **Scenes.** One frame per second is compared with the next using structural similarity (SSIM). A score below 0.76 starts a new scene.
4. **Captions.** The middle frame of each scene is captioned with `nlpconnect/vit-gpt2-image-captioning`.
5. **Merged text.** Each caption is inserted into the transcript at its timestamp, so the stored transcript holds both what is said and what is shown.
6. **Sentiment.** `lxyuan/distilbert-base-multilingual-cased-sentiments-student` scores the description and the transcript.
7. **Topic.** The topic model in `topic_models/` assigns the transcript to one of its clusters. The cluster id is stored as `topic_id`.
8. **Category.** `cardiffnlp/tweet-topic-latest-multi` assigns one of its 19 labels, stored as `topic_category_id`. The core API groups these into the categories the app shows (`TOPIC_MAP` in `core/modules/video_engine/manager.py`).

The results are saved on the video row and `gone_through_ml` is set.

## The topic model

`topic_models/5Mil_C10_Lite/` is the one model in this repository that was trained for LimeLight. The others are public pretrained models, downloaded when first used.

It is a saved [BERTopic](https://github.com/MaartenGr/BERTopic) model:

- `topic_embeddings.safetensors` holds one 768-dimensional embedding for each of 2048 topics, about 1.57 million numbers.
- `topics.json` holds the top words of each topic and the topic assignments of 500,000 training documents.
- `Ronin.load_sub_models` records the setup: `all-distilroberta-v1` sentence embeddings, incremental PCA to 256 dimensions, mini-batch k-means with 2048 clusters, an online count vectorizer, and KeyBERT and MMR for the topic words. This is BERTopic's online configuration, which is fitted in batches.

What is not here: the training script and the training data. The code lists two other variants by name, `2Mil_C4` and `4Mil_C8_Heavy`, which are also not here. The git history says only that the model was added in March 2024 as a "DistilBERT based topic modeller".

The sentence encoder it depends on, `all-distilroberta-v1`, is a public model. It was not trained here.

`notebooks/ml.ipynb` holds the prototype of the pipeline and experiments with zero-shot BERTopic that map topics to category names.

## Deployment

Production ran on AWS EC2 through CodeDeploy. `scripts/boot.sh` picks the compose file from the instance's name tag:

- `docker-compose-production.worker.yml`: the GPU machine. Its Celery worker takes `ml_queue`, one task at a time.
- `docker-compose-production.cpu.yml`: the CPU machine. Its Celery worker takes `encoder_queue`.

Both also run Django under gunicorn, Postgres, Redis, Celery beat and Traefik. The worker image installs ffmpeg (`compose/production/django/Dockerfile`).

## Configuration

Copy `.env.example` to `.env`. It lists every variable the settings read. The `POSTGRES_*` values must point at the core API's database and the `DJANGO_AWS_*` values at the same bucket. No credentials are in this repository.
