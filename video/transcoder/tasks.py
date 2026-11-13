import logging

from celery import shared_task

from config.celery_app import app as celery_app
from machine_learning.manager import Ronin
from transcoder.manager import VideoEncoder
from transcoder.models import VideoEngineVideopost


@celery_app.task(bind=True, queue="ml_queue")
def start_ml_pipeline_async(self, video_id):
    """Run the ML pipeline for one video and record any failure on the video row."""
    logging.info(f"Starting ml pipeline for video ID {video_id}")
    ronin = Ronin()
    video = VideoEngineVideopost.objects.get(video_id=video_id)
    try:
        ronin.start_pipeline(video.video_id)
    except Exception as e:
        logging.error(f"Error in ml pipeline for video ID {video.video_id}: {str(e)}")
        video.ml_processing_happening = False
        video.ml_processing_contains_error = True
        video.ml_processing_error_reason = str(e)
        video.save()


@celery_app.task(bind=True, queue="encoder_queue")
def start_encoding_pipeline_async(self, video_id):
    """Transcode one video and record any failure on the video row."""
    logging.info(f"Starting encoding pipeline for video ID {video_id}")
    video_encoder = VideoEncoder()
    video = VideoEngineVideopost.objects.get(video_id=video_id)
    try:
        video_encoder.start_pipeline(video.video_id)
    except Exception as e:
        logging.error(f"Error in encoding pipeline for video ID {video.video_id}: {str(e)}")
        video.encoder_contains_error = True
        video.encoder_error_reason = str(e)
        video.save()


@shared_task
def periodic_checker():
    """Queue every video that still needs the ML pipeline or encoding, oldest first, and log the backlog."""
    videos = VideoEngineVideopost.objects
    needs_ml = videos.filter(gone_through_ml=False).order_by("creation_date")
    for video in needs_ml.iterator(chunk_size=5):
        start_ml_pipeline_async.apply_async(args=(video.video_id,), queue="ml_queue")

    needs_encoding = videos.filter(is_encoded=False, is_processing=False).order_by("creation_date")
    for video in needs_encoding.iterator(chunk_size=5):
        start_encoding_pipeline_async.apply_async(args=(video.video_id,), queue="encoder_queue")

    logging.info(
        "videos: %s total, %s fully processed",
        videos.count(),
        videos.filter(gone_through_ml=True, is_encoded=True).count(),
    )
    logging.info(
        "ronin: %s waiting, %s processed, %s running, %s failed",
        needs_ml.count(),
        videos.filter(gone_through_ml=True).count(),
        videos.filter(ml_processing_happening=True).count(),
        videos.filter(ml_processing_contains_error=True).count(),
    )
    logging.info(
        "encoder: %s waiting, %s processed, %s running, %s failed",
        needs_encoding.count(),
        videos.filter(is_encoded=True).count(),
        videos.filter(is_processing=True).count(),
        videos.filter(encoder_contains_error=True).count(),
    )
