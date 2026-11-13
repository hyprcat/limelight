from django.contrib import admin
from unfold.admin import ModelAdmin

from modules.lounge_engine.models import (
    LoungePost,
    LoungeLike,
    LoungeDislike,
    LoungePostMentions,
    LoungePostLogs,
    LoungePostImpressions,
    LoungePostHashtags,
    ReportedPost,
    UserPasswordReset,
)


@admin.register(LoungePost)
class LoungePostAdmin(ModelAdmin):
    list_display = ('text', 'associated_lounge_section', 'created_by', 'xp', 'likes', 'dislikes', 'replies', 'creation_date')
    search_fields = ('text', 'created_by__member__user__username')
    list_filter = ('associated_lounge_section', 'creation_date')
    fieldsets = (
        (None, {
            'fields': ('id', 'associated_lounge_section', 'created_by', 'text', 'attachment')
        }),
        ('Metrics', {
            'fields': ('xp', 'likes', 'dislikes', 'replies', 'topic_id', 'topic_category_id', 'post_sentiment', 'impressions', 'is_advertisement')
        }),
        ('Post Hierarchy', {
            'fields': ('root_post', 'parent_post', 'post_depth')
        }),
        ('Timestamps', {
            'fields': ('metrics_last_updated', 'creation_date')
        }),
    )
    readonly_fields = ('id', 'metrics_last_updated', 'creation_date')

@admin.register(LoungeLike)
class LoungeLikeAdmin(ModelAdmin):
    list_display = ('post', 'liked_by', 'creation_date')
    search_fields = ('post__text', 'liked_by__member__user__username')
    list_filter = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('post', 'liked_by', 'creation_date')
        }),
    )
    readonly_fields = ('creation_date',)

@admin.register(LoungeDislike)
class LoungeDislikeAdmin(ModelAdmin):
    list_display = ('post', 'disliked_by', 'creation_date')
    search_fields = ('post__text', 'disliked_by__member__user__username')
    list_filter = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('post', 'disliked_by', 'creation_date')
        }),
    )
    readonly_fields = ('creation_date',)

@admin.register(LoungePostMentions)
class LoungePostMentionsAdmin(ModelAdmin):
    list_display = ('mentioned_user', 'mentioned_in_comments', 'creation_date')
    search_fields = ('mentioned_user__member__user__username', 'mentioned_in_comments__text')
    list_filter = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('mentioned_user', 'mentioned_in_comments', 'creation_date')
        }),
    )
    readonly_fields = ('creation_date',)

@admin.register(LoungePostLogs)
class LoungePostLogsAdmin(ModelAdmin):
    list_display = ('linked_post', 'day_difference', 'weekly_difference', 'monthly_difference', 'day_update_date', 'week_update_date', 'month_update_date')
    search_fields = ('linked_post__text',)
    list_filter = ('day_update_date', 'week_update_date', 'month_update_date')
    fieldsets = (
        (None, {
            'fields': ('linked_post', 'day_difference', 'weekly_difference', 'monthly_difference', 'day_update_date', 'week_update_date', 'month_update_date')
        }),
    )
    readonly_fields = ('day_update_date', 'week_update_date', 'month_update_date')

@admin.register(LoungePostImpressions)
class LoungePostImpressionsAdmin(ModelAdmin):
    list_display = ('post', 'viewed_by', 'creation_date')
    search_fields = ('post__text', 'viewed_by__user__username')
    list_filter = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('post', 'viewed_by', 'creation_date')
        }),
    )
    readonly_fields = ('creation_date',)

@admin.register(LoungePostHashtags)
class LoungePostHashtagsAdmin(ModelAdmin):
    list_display = ('hashtag_string', 'associated_leaf', 'created_date')
    search_fields = ('hashtag_string', 'associated_leaf__text')
    list_filter = ('created_date',)
    fieldsets = (
        (None, {
            'fields': ('hashtag_string', 'associated_leaf', 'created_date')
        }),
    )
    readonly_fields = ('created_date',)

@admin.register(ReportedPost)
class ReportedPostAdmin(ModelAdmin):
    list_display = ('post', 'reported_by', 'reason', 'added_at')
    search_fields = ('post__text', 'reported_by__user__username', 'reason')
    list_filter = ('added_at',)
    fieldsets = (
        (None, {
            'fields': ('post', 'reported_by', 'reason', 'added_at')
        }),
    )
    readonly_fields = ('added_at',)

@admin.register(UserPasswordReset)
class UserPasswordResetAdmin(ModelAdmin):
    list_display = ('user_email', 'user_verification_code', 'created_at', 'is_authenicated', 'expires')
    search_fields = ('user_email',)
    list_filter = ('created_at', 'expires', 'is_authenicated')
    fieldsets = (
        (None, {
            'fields': ('user_email', 'user_verification_code', 'created_at', 'is_authenicated', 'expires')
        }),
    )
    readonly_fields = ('created_at',)
