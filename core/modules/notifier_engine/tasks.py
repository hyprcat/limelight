import logging
from datetime import timedelta

from celery import shared_task
from django.utils import timezone

from modules.notifier_engine.manager import notifierAgent
from modules.notifier_engine.models import *

RETRY_WINDOW = timedelta(days=3)


@shared_task()
def notification_sender():
    """Retry unsent pushes, fan out new videos and promotions, and register processed-video notifications."""
    logging.info("SENDING NOTIFICATIONS")
    now = timezone.now()

    senders = (
        (VideoUploadedNotification, notifierAgent.send_video_uploaded_notification),
        (LoungePostNotification, notifierAgent.send_lounge_post_created_notification),
        (VideoCommentReplyNotification, notifierAgent.send_video_comment_reply_created_notification),
        (LoungePostReplyNotification, notifierAgent.send_lounge_post_reply_created_notification),
        (PromotionalNotification, notifierAgent.send_promo_notification),
        (VideoLikeScheduledNotification, notifierAgent.send_video_liked_scheduled_notification),
        (VideoCommentNotification, notifierAgent.send_video_comment_created_notification),
        (VideoProcessedNotification, notifierAgent.send_video_processed_notification),
    )
    for model, send in senders:
        unsent = model.objects.filter(notification_sent=False).all()
        for obj in unsent.iterator(chunk_size=100):
            if now - obj.creation_date < RETRY_WINDOW:
                send(obj)

    video_qs = VideoPost.objects.all()
    for video in video_qs.iterator(chunk_size=50):
        if now - video.creation_date < RETRY_WINDOW:
            notifierAgent.distrubute_video_uploaded_notifications(video)

    promotional_wrapper_qs = PromotionNotificationWrapper.objects.filter(delivered=False).all()
    for promo in promotional_wrapper_qs.iterator(chunk_size=50):
        notifierAgent.distrubute_promotional_notifications(promo.title, promo.message)
        promo.delivered = True
        promo.save()

    already_notified = VideoProcessedNotification.objects.all()
    not_notified = VideoPost.objects.exclude(video_id__in=already_notified.values('linked_video__video_id'))

    for video in not_notified.iterator(chunk_size=50):
        if video.is_encoded and video.gone_through_ml:
            notifierAgent.register_video_processed_notification(video.creator, video)

    logging.info("SENT NOTIFICATIONS")
