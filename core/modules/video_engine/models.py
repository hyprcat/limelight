import uuid
import os
import requests
import logging

from django.conf import settings
from django.db import models

from modules.user_engine.models import UserProfile
from celery import shared_task


def generate_upload_path(instance, x):
    """Storage path of a video's original file: videos/<video id without dashes>/original.mp4."""
    return os.path.join(f'videos/{"".join(str(instance.video_id).split("-"))}/', "original.mp4")


def generate_thumbnail_path(instance, x):
    """Storage path of a video's thumbnail: videos/<video id without dashes>/thumbnail.jpeg."""
    return os.path.join(f'videos/{"".join(str(instance.video_id).split("-"))}/', "thumbnail.jpeg")


class VideoPost(models.Model):
    """An uploaded video with its counters, ML output, media metadata and state flags."""

    # FUNDAMENTAL
    video_id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    thumbnail = models.FileField(upload_to=generate_thumbnail_path, null=True, blank=True)
    title = models.CharField(max_length=150, null=False)
    video_file_original_name = models.TextField()
    video_file = models.FileField(upload_to=generate_upload_path, null=True, blank=True)
    video_description = models.TextField(max_length=4000, null=True, blank=True)
    video_duration_seconds = models.BigIntegerField(null=True, blank=True)
    creator = models.ForeignKey(UserProfile, related_name="video_owner", on_delete=models.CASCADE)
    # METRICS
    impressions = models.PositiveBigIntegerField(default=0)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    comments = models.PositiveBigIntegerField(default=0)
    views = models.PositiveBigIntegerField(default=0)
    video_xp = models.PositiveBigIntegerField(default=0)
    # INTERNAL
    topic_id = models.IntegerField(default=-1)
    topic_category_id = models.IntegerField(default=-1)
    language = models.CharField(max_length=64)
    transcript = models.TextField(null=True, blank=True)
    native_language_transcript = models.TextField(null=True, blank=True)
    transcript_sentiment = models.IntegerField(default=0)
    description_sentiment = models.IntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)
    max_transcoded_resolution = models.BigIntegerField(default=0)
    # META
    video_height = models.PositiveBigIntegerField(default=0)
    video_width = models.PositiveBigIntegerField(default=0)
    video_fps = models.PositiveBigIntegerField(default=0)
    video_frame_count = models.PositiveBigIntegerField(default=0)
    video_codec_info = models.CharField(max_length=5, null=True, blank=True)
    video_format = models.CharField(max_length=5, null=True, blank=True)
    video_bitrate = models.FloatField(default=0)
    # AUDIO META
    audio_fps = models.PositiveBigIntegerField(default=0)
    audio_channels = models.PositiveBigIntegerField(default=0)
    audio_bitrate = models.PositiveBigIntegerField(default=0)

    # VIDEO TAGS
    ml_processing_happening = models.BooleanField(default=False)
    ml_processing_contains_error = models.BooleanField(default=False)
    ml_processing_error_reason = models.TextField()

    is_processing = models.BooleanField(default=False)
    encoder_contains_error = models.BooleanField(default=False)
    encoder_error_reason = models.TextField()
    is_encoded = models.BooleanField(default=False)
    is_active = models.BooleanField(default=False)
    is_advertisement = models.BooleanField(default=False)
    is_draft = models.BooleanField(default=True)
    is_unlisted = models.BooleanField(default=False)
    is_lounge_only = models.BooleanField(default=False)
    is_age_restricted = models.BooleanField(default=False)
    is_scheduled = models.BooleanField(default=False)
    notification_sent = models.BooleanField(default=False)
    contains_paid_promotion = models.BooleanField(default=False)
    gone_through_ml = models.BooleanField(default=False)
    # DATES
    scheduled_date = models.DateTimeField(default=None, null=True, blank=True)
    metrics_last_updated = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Video"
        verbose_name_plural = "Videos"



class VideoImpressions(models.Model):
    video = models.ForeignKey(VideoPost, related_name="impressed_video", on_delete=models.CASCADE)
    impression_on = models.ForeignKey(UserProfile, related_name="impressed_viewer", on_delete=models.CASCADE)
    times_impressed_again = models.PositiveBigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Video Impression"
        verbose_name_plural = "Video Impressions"


class VideoViews(models.Model):
    video = models.ForeignKey(VideoPost, related_name="viewed_video", on_delete=models.CASCADE)
    viewed_by = models.ForeignKey(UserProfile, related_name="viewer", on_delete=models.CASCADE)
    view_time_seconds = models.PositiveBigIntegerField(default=0)
    view_percentage = models.PositiveBigIntegerField(default=0)
    retention_percentage = models.PositiveBigIntegerField(default=0)
    times_rewatched = models.PositiveBigIntegerField(default=0)
    first_viewed = models.DateTimeField(auto_now_add=True)
    last_rewatch = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Video View"
        verbose_name_plural = "Video Views"

class VideoHashtags(models.Model):
    hashtag_string = models.TextField()
    video = models.ForeignKey(VideoPost, related_name="tagged_video_h", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Video Hashtag"
        verbose_name_plural = "Video Hashtags"

class VideoDescriptionMentions(models.Model):
    mentioned_user = models.ForeignKey(UserProfile, related_name="mentioned_in_desc", on_delete=models.CASCADE)
    video = models.ForeignKey(VideoPost, related_name="mentioned_from", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Video Description Mention"
        verbose_name_plural = "Video Description Mentions"


class Likes(models.Model):
    video = models.ForeignKey(VideoPost, related_name="liked_video", on_delete=models.CASCADE)
    liked_by = models.ForeignKey(UserProfile, related_name="liked_by", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Video Like"
        verbose_name_plural = "Video Likes"
        constraints = [models.UniqueConstraint(fields=["video", "liked_by"], name="like_relation")]

    def __str__(self):
        return self.video.title



class DisLikes(models.Model):
    video = models.ForeignKey(VideoPost, related_name="disliked_video", on_delete=models.CASCADE)
    disliked_by = models.ForeignKey(UserProfile, related_name="disliked_by", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Video Dislike"
        verbose_name_plural = "Video Dislikes"
        constraints = [models.UniqueConstraint(fields=["video", "disliked_by"], name="dislike_relation")]

    def __str__(self):
        return self.video.title




class Comment(models.Model):
    comment_id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    video = models.ForeignKey(VideoPost, related_name="comment", on_delete=models.CASCADE)
    comment = models.TextField(max_length=700, null=False, blank=False)
    commented_by = models.ForeignKey(UserProfile, related_name="commented_by", on_delete=models.CASCADE)
    replies = models.PositiveBigIntegerField(default=0)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    topic_id = models.IntegerField(default=-1)
    topic_category_id = models.IntegerField(default=-1)
    comment_sentiment = models.IntegerField(default=0)
    comment_depth = models.PositiveBigIntegerField(default=1)
    root_comment = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="base_comment"
    )
    parent_comment = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="threaded_comment"
    )
    is_reply = models.BooleanField(default=False)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.comment

    class Meta:
        verbose_name = "Video Thread"
        verbose_name_plural = "Video Threads"


class CommentLikes(models.Model):
    comment = models.ForeignKey(Comment, related_name="liked_comment", on_delete=models.CASCADE)
    liked_by = models.ForeignKey(UserProfile, related_name="comment_liked_by", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.comment.comment

    class Meta:
        verbose_name = "Comment Like"
        verbose_name_plural = "Comment Likes"
        constraints = [models.UniqueConstraint(fields=["comment", "liked_by"], name="like_comment")]



class CommentDisLikes(models.Model):
    comment = models.ForeignKey(Comment, related_name="disliked_comment", on_delete=models.CASCADE)
    disliked_by = models.ForeignKey(UserProfile, related_name="comment_disliked_by", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.comment.comment

    class Meta:
        verbose_name = "Comment Dislike"
        verbose_name_plural = "Comment Dislikes"
        constraints = [models.UniqueConstraint(fields=["comment", "disliked_by"], name="dislike_comment")]


class CommentMentions(models.Model):
    mentioned_user = models.ForeignKey(UserProfile, related_name="mentioned_in_comment", on_delete=models.CASCADE)
    comment = models.ForeignKey(Comment, related_name="mentioned_comment", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.comment.comment

    class Meta:
        verbose_name = "Comment Mention"
        verbose_name_plural = "Comment Mentions"


class Playlist(models.Model):
    playlist_id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    name = models.CharField(max_length=120, null=False, blank=False)
    description = models.TextField()
    creation_date = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(UserProfile, related_name="playlist_creator", on_delete=models.CASCADE)
    views = models.BigIntegerField(default=0)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Playlist"
        verbose_name_plural = "Playlists"

class PlaylistItem(models.Model):
    video = models.ForeignKey(VideoPost, related_name="in_playlist", on_delete=models.CASCADE)
    playlist = models.ForeignKey("Playlist", related_name="associated_playlist", on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Playlist Item"
        verbose_name_plural = "Playlist Items"

class WatchLater(models.Model):
    video = models.ForeignKey(VideoPost, related_name="in_watch_later", on_delete=models.CASCADE)
    user = models.ForeignKey(UserProfile, related_name="parent_user", on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title

    class Meta:
        verbose_name = "Watch Later Item"
        verbose_name_plural = "Watch Later Items"


class CustomFeed(models.Model):
    feed_id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    feed_title = models.TextField()
    feed_description = models.TextField()
    is_public = models.BooleanField(default=False)
    owner = models.ForeignKey(UserProfile, related_name="feed_owner", on_delete=models.CASCADE)
    total_topics = models.PositiveIntegerField(default=0)
    total_creators = models.PositiveIntegerField(default=0)
    feed_impressions = models.PositiveIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)


    def __str__(self):
        return self.feed_title

    class Meta:
        verbose_name = "Custom Feed"
        verbose_name_plural = "Custom Feeds"


class CustomFeedTopics(models.Model):
    related_feed = models.ForeignKey(CustomFeed, related_name="related_feed_x", on_delete=models.CASCADE)
    topic_id = models.IntegerField(default=-1)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.related_feed.feed_title + f" {self.topic_id}"

    class Meta:
        verbose_name = "Feed Topic"
        verbose_name_plural = "Feed Topics"

class CustomFeedCreators(models.Model):
    related_feed = models.ForeignKey(CustomFeed, related_name="related_feed_y", on_delete=models.CASCADE)
    creator = models.ForeignKey(UserProfile, related_name="feed_creator", on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.related_feed.feed_title + f" {self.creator.user.username}"

    class Meta:
        verbose_name = "Feed Creator"
        verbose_name_plural = "Feed Creators"

class CustomFeedUsage(models.Model):
    related_feed = models.ForeignKey(CustomFeed, related_name="related_feed_z", on_delete=models.CASCADE)
    being_used_by = models.ForeignKey(UserProfile, related_name="feed_being_used_by", on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.related_feed.feed_title + f" {self.being_used_by.user.username}"

    class Meta:
        verbose_name = "Feed Usage"
        verbose_name_plural = "Feed Usage"

class CustomFeedImpressions(models.Model):
    related_feed = models.ForeignKey(CustomFeed, related_name="related_feed_a", on_delete=models.CASCADE)
    viewed_by = models.ForeignKey(UserProfile, related_name="feed_viewed_by", on_delete=models.CASCADE)
    views = models.PositiveBigIntegerField(default=0)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.related_feed.feed_title + f" {self.viewed_by.user.username}"

    class Meta:
        verbose_name = "Feed Impression"
        verbose_name_plural = "Feed Impressions"

class ReportedVideos(models.Model):
    video = models.ForeignKey(VideoPost, related_name="reported_video", on_delete=models.CASCADE)
    reported_by = models.ForeignKey(UserProfile, related_name="v_reported_by", on_delete=models.CASCADE)
    reason = models.TextField()
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.video.title
    
    class Meta:
        verbose_name = "Reported Video"
        verbose_name_plural = "Reported Videos"

class ReportedComment(models.Model):
    comment = models.ForeignKey(Comment, related_name="reported_comment", on_delete=models.CASCADE)
    reported_by = models.ForeignKey(UserProfile, related_name="c_reported_by", on_delete=models.CASCADE)
    reason = models.TextField()
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.comment.comment
    
    class Meta:
        verbose_name = "Reported Thread"
        verbose_name_plural = "Reported Threads"


class VideoCommunicator:
    """HTTP client for the separate transcoder and ML runner service."""

    def __endpoints__(self):
        self.LIMELIGHT_VIDEO = settings.VIDEO_SERVICE_URL
        self.TRANSCODER_ENDPOINT = "transcoder/"

    def __meta__(self):
        self.VERSION = 0.6
        self.BUILD = "BETA"

    def __init__(self) -> None:
        self.__meta__()
        self.__endpoints__()
        logging.info(f"VIDEO COMMUNICATOR {self.VERSION} {self.BUILD}")

    def make_POST_request(self, api_endpoint, body):
        """POST a JSON body. Returns the response, or a status -101 dictionary when the host is unreachable."""
        try:
            return requests.post(api_endpoint, json=body)
        except requests.exceptions.ConnectionError:
            return {"status": -101, "message": "Cannot connect to Host."}

    def make(self) -> str:
        """Return the base URL of the transcoder API."""
        return self.LIMELIGHT_VIDEO + self.TRANSCODER_ENDPOINT

    def make_url(self, endpoint):
        """Return the full URL of a transcoder endpoint."""
        return self.make() + endpoint


@shared_task
def add_to_encoder_queue(video_id):
    """Celery task: ask the runner service to start encoding a video."""
    api_endpoint = VideoCommunicator().make_url("start_encoding_task")
    response = VideoCommunicator().make_POST_request(api_endpoint, {"video_id": str(video_id)})
    return response


@shared_task
def add_to_ml_queue(video_id):
    """Celery task: ask the runner service to start ML processing of a video."""
    api_endpoint = VideoCommunicator().make_url("start_ml_task")
    response = VideoCommunicator().make_POST_request(api_endpoint, {"video_id": str(video_id)})
    return response
