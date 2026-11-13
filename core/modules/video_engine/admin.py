from django.contrib import admin
from modules.s3 import cdn_url
from modules.video_engine.manager import VideoEngineManager
from modules.video_engine.models import *
from unfold.admin import ModelAdmin
from django.utils.html import format_html


def find_key_by_value(value, topic_map):
    """Return the category name whose id list contains value, or None."""
    for key, values in topic_map.items():
        if value in values:
            return key
    return None


@admin.register(VideoPost)
class VideoPostAdmin(ModelAdmin):
    list_display = ( 'title', 'creator', 'creation_date', "topic_category_id",'topic_category' ,"gone_through_ml")
    list_filter = ('is_active', 'is_draft', 'is_unlisted', 'is_lounge_only', 'creation_date', 'creator')
    search_fields = ('title', 'creator__user__username')
    ordering = ('-creation_date',)
    readonly_fields = ('creation_date', 'metrics_last_updated', 'playback')
    fieldsets = (
        (None, {
            'fields': ('playback', 'video_id', 'title', 'video_file_original_name', 'video_file', 'thumbnail', 'creator', 'video_description', 'video_duration_seconds', 'language', 'creation_date')
        }),
        ('Metrics', {
            'fields': ('impressions', 'likes', 'dislikes', 'comments', 'views', 'video_xp', 'metrics_last_updated')
        }),
        ('Internal', {
            'fields': ('topic_id', 'topic_category_id', 'transcript', 'native_language_transcript', 'transcript_sentiment', 'description_sentiment', 'max_transcoded_resolution')
        }),
        ('Meta', {
            'fields': ('video_height', 'video_width', 'video_fps', 'video_frame_count', 'video_codec_info', 'video_format', 'video_bitrate')
        }),
        ('Audio Meta', {
            'fields': ('audio_fps', 'audio_channels', 'audio_bitrate')
        }),
        ('Video Tags', {
            'fields': ('ml_processing_happening', 'ml_processing_contains_error', 'ml_processing_error_reason', 'is_processing', 'encoder_contains_error', 'encoder_error_reason', 'is_encoded', 'is_active', 'is_advertisement', 'is_draft', 'is_unlisted', 'is_lounge_only', 'is_age_restricted', 'is_scheduled', 'notification_sent', 'contains_paid_promotion', 'gone_through_ml')
        }),
        ('Dates', {
            'fields': ('scheduled_date',)
        }),
    )


    def topic_category(self, obj):
        """Show the category name for the video's topic_category_id."""
        if obj.topic_category_id == -1:
            return "Not Categorised Yet"
        return find_key_by_value(obj.topic_category_id, VideoEngineManager().TOPIC_MAP)

    topic_category.short_description = 'Category'

    def playback(self, obj):
        """Embed a player for the original file, served from CloudFront."""
        if obj.video_file:
            formatted = "".join(str(obj.video_id).split("-"))
            key = f"media/videos/{formatted}/original.mp4"
            video_url = cdn_url(key)
            return format_html('<video width="320" height="240" controls><source src="{}" type="video/mp4">Your browser does not support the video tag.</video>', video_url)
        return "No video file"

    playback.short_description = 'Video Playback'

    def get_readonly_fields(self, request, obj=None):
        """Lock video_id and creator once the video exists."""
        if obj:
            return self.readonly_fields + ('video_id', 'creator')
        return self.readonly_fields


@admin.register(VideoImpressions)
class VideoImpressionsAdmin(ModelAdmin):
    list_display = ('video', 'impression_on', 'times_impressed_again', 'creation_date')
    search_fields = ('video__title', 'impression_on__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(VideoViews)
class VideoViewsAdmin(ModelAdmin):
    list_display = ('video', 'viewed_by', 'view_time_seconds', 'view_percentage', 'retention_percentage', 'times_rewatched', 'first_viewed', 'last_rewatch')
    search_fields = ('video__title', 'viewed_by__user__username')
    list_filter = ('first_viewed', 'last_rewatch')
    ordering = ('-first_viewed',)

@admin.register(VideoHashtags)
class VideoHashtagsAdmin(ModelAdmin):
    list_display = ('hashtag_string', 'video', 'creation_date')
    search_fields = ('hashtag_string', 'video__title')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(VideoDescriptionMentions)
class VideoDescriptionMentionsAdmin(ModelAdmin):
    list_display = ('mentioned_user', 'video', 'creation_date')
    search_fields = ('mentioned_user__user__username', 'video__title')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)


@admin.register(Likes)
class LikesAdmin(ModelAdmin):
    list_display = ('video', 'liked_by', 'creation_date')
    search_fields = ('video__title', 'liked_by__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(DisLikes)
class DisLikesAdmin(ModelAdmin):
    list_display = ('video', 'disliked_by', 'creation_date')
    search_fields = ('video__title', 'disliked_by__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(Comment)
class CommentAdmin(ModelAdmin):
    list_display = ('video', 'commented_by', 'comment_depth', 'is_reply', 'creation_date')
    search_fields = ('video__title', 'commented_by__user__username', 'comment')
    list_filter = ('creation_date', 'is_reply')
    ordering = ('-creation_date',)

@admin.register(CommentLikes)
class CommentLikesAdmin(ModelAdmin):
    list_display = ('comment', 'liked_by', 'creation_date')
    search_fields = ('comment__comment', 'liked_by__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(CommentDisLikes)
class CommentDisLikesAdmin(ModelAdmin):
    list_display = ('comment', 'disliked_by', 'creation_date')
    search_fields = ('comment__comment', 'disliked_by__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(CommentMentions)
class CommentMentionsAdmin(ModelAdmin):
    list_display = ('mentioned_user', 'comment', 'creation_date')
    search_fields = ('mentioned_user__user__username', 'comment__comment')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(Playlist)
class PlaylistAdmin(ModelAdmin):
    list_display = ('playlist_id', 'name', 'created_by', 'views', 'creation_date')
    search_fields = ('name', 'created_by__user__username')
    list_filter = ('creation_date',)
    ordering = ('-creation_date',)

@admin.register(PlaylistItem)
class PlaylistItemAdmin(ModelAdmin):
    list_display = ('video', 'playlist', 'added_at')
    search_fields = ('video__title', 'playlist__name')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(WatchLater)
class WatchLaterAdmin(ModelAdmin):
    list_display = ('video', 'user', 'added_at')
    search_fields = ('video__title', 'user__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(CustomFeed)
class CustomFeedAdmin(ModelAdmin):
    list_display = ('feed_title', 'owner', 'is_public', 'total_topics', 'total_creators', 'feed_impressions', 'creation_date')
    search_fields = ('feed_title', 'owner__user__username')
    list_filter = ('is_public', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(CustomFeedTopics)
class CustomFeedTopicsAdmin(ModelAdmin):
    list_display = ('related_feed', 'topic_id', 'added_at')
    search_fields = ('related_feed__feed_title',)
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(CustomFeedCreators)
class CustomFeedCreatorsAdmin(ModelAdmin):
    list_display = ('related_feed', 'creator', 'added_at')
    search_fields = ('related_feed__feed_title', 'creator__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(CustomFeedUsage)
class CustomFeedUsageAdmin(ModelAdmin):
    list_display = ('related_feed', 'being_used_by', 'added_at')
    search_fields = ('related_feed__feed_title', 'being_used_by__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(CustomFeedImpressions)
class CustomFeedImpressionsAdmin(ModelAdmin):
    list_display = ('related_feed', 'viewed_by', 'views', 'added_at')
    search_fields = ('related_feed__feed_title', 'viewed_by__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(ReportedVideos)
class ReportedVideosAdmin(ModelAdmin):
    list_display = ('video', 'reported_by', 'reason', 'added_at')
    search_fields = ('video__title', 'reported_by__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)

@admin.register(ReportedComment)
class ReportedCommentAdmin(ModelAdmin):
    list_display = ('comment', 'reported_by', 'reason', 'added_at')
    search_fields = ('comment__comment', 'reported_by__user__username')
    list_filter = ('added_at',)
    ordering = ('-added_at',)