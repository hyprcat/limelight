import os
from django.db import models

from modules.lounge_engine.models import LoungePost
from modules.user_engine.models import UserProfile
from modules.video_engine.models import Comment, VideoPost


def generate_thumbnail_path(instance, x):
    """Storage path of a promotion image: promos/<pk without dashes>/thumbnail.jpeg."""
    return os.path.join(f'promos/{"".join(str(instance.pk).split("-"))}/', "thumbnail.jpeg")


class PromotionNotificationWrapper(models.Model):
    """A promotion written in the admin. The notification_sender task copies it to every user once."""

    title = models.TextField()
    message = models.TextField()
    image = models.FileField(upload_to=generate_thumbnail_path, null=True, blank=True)
    creation_date = models.DateTimeField(auto_now_add=True)
    scheduled_time = models.DateTimeField(auto_now_add=True)
    delivered = models.BooleanField(default=False)

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Promo Control"
        verbose_name_plural = "Promo Control"
        get_latest_by = "creation_date"


class VideoUploadedNotification(models.Model):
    """Tells a subscriber that a channel uploaded a video."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="v_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    linked_video = models.ForeignKey(VideoPost, related_name="newly_uploaded_video", on_delete=models.CASCADE)
    notification_sent = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.linked_video.title} x @{self.receiver.user.username}"

    class Meta:
        verbose_name = "Uploaded Video Notification"
        verbose_name_plural = "Uploaded Video Notifications"
        constraints = [
            models.UniqueConstraint(fields=["receiver", "linked_video"], name="Video_Uploaded_Notification")
        ]


class LoungePostNotification(models.Model):
    """Tells a lounge member that a new thread was started in the lounge."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="l_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    post = models.ForeignKey(LoungePost, related_name="newly_created_thread_post", on_delete=models.CASCADE)
    linked_lounge_user = models.ForeignKey(
        UserProfile, related_name="newly_created_thread_lounge", on_delete=models.CASCADE
    )
    notification_sent = models.BooleanField(default=False)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Lounge Post Notification"
        verbose_name_plural = "Lounge Post Notifications"


class VideoCommentReplyNotification(models.Model):
    """Tells a comment author that someone replied to the comment."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="video_comment_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    reply_comment = models.ForeignKey(Comment, related_name="reply_comment", on_delete=models.CASCADE)
    replied_to = models.ForeignKey(Comment, related_name="replied_to_comment", on_delete=models.CASCADE)
    notification_sent = models.BooleanField(default=False)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Video Comment Reply Notification"
        verbose_name_plural = "Video Comment Reply Notifications"
        constraints = [
            models.UniqueConstraint(
                fields=["receiver", "reply_comment", "replied_to"], name="Video_Comment_Reply_Notification"
            )
        ]


class LoungePostReplyNotification(models.Model):
    """Tells a lounge post author that someone replied to the post."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="lpr_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    reply_comment = models.ForeignKey(LoungePost, related_name="reply_post", on_delete=models.CASCADE)
    notification_sent = models.BooleanField(default=False)
    replied_to = models.ForeignKey(LoungePost, related_name="replied_to_post", on_delete=models.CASCADE)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Lounge Post Reply Notification"
        verbose_name_plural = "Lounge Post Reply Notifications"
        constraints = [
            models.UniqueConstraint(
                fields=["receiver", "reply_comment", "replied_to"], name="Lounge_Post_Reply_Notification"
            )
        ]


class PromotionalNotification(models.Model):
    """One user's copy of a promotion."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="promo_receiver")
    title = models.TextField()
    message = models.TextField()
    image = models.FileField(upload_to=generate_thumbnail_path, null=True, blank=True)
    creation_date = models.DateTimeField(auto_now_add=True)
    notification_sent = models.BooleanField(default=False)
    viewed = models.BooleanField(default=False)

    def __str__(self):
        return self.message

    class Meta:
        verbose_name = "Promo"
        verbose_name_plural = "Promos"
        constraints = [models.UniqueConstraint(fields=["receiver", "message", "title"], name="Promo_Notification")]


class VideoLikeScheduledNotification(models.Model):
    """Tells a creator that a video was liked."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="vls_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    notification_sent = models.BooleanField(default=False)
    linked_video = models.ForeignKey(VideoPost, related_name="like_scheduled_video", on_delete=models.CASCADE)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Video Like Scheduled Notification"
        verbose_name_plural = "Video Like Scheduled Notifications"
        constraints = [
            models.UniqueConstraint(
                fields=["receiver", "message_json", "linked_video"], name="Video_Like_Schedule_Notification"
            )
        ]


class VideoCommentNotification(models.Model):
    """Tells a creator that someone commented on a video."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="vc_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    notification_sent = models.BooleanField(default=False)
    linked_comment = models.ForeignKey(Comment, related_name="newly_created_comment", on_delete=models.CASCADE)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Video Comment Notification"
        verbose_name_plural = "Video Comment Notifications"
        constraints = [
            models.UniqueConstraint(
                fields=["receiver", "message_json", "linked_comment"], name="Video_Comment_Notification"
            )
        ]


class VideoProcessedNotification(models.Model):
    """Tells a creator that a video finished encoding and ML processing."""

    receiver = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="vp_receiver")
    message_json = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    notification_sent = models.BooleanField(default=False)
    linked_video = models.ForeignKey(VideoPost, related_name="processed_video", on_delete=models.CASCADE)

    def __str__(self):
        return self.message_json

    class Meta:
        verbose_name = "Video Comment Notification"
        verbose_name_plural = "Video Comment Notifications"
        constraints = [
            models.UniqueConstraint(fields=["receiver", "linked_video"], name="Video_Processed_Notification")
        ]
