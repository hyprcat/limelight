from django.contrib import admin
from modules.analytics_engine.models import *
from unfold.admin import ModelAdmin


@admin.register(ViewDuration_VIDEO)
class ViewDuration_VIDEOAdmin(ModelAdmin):
    list_display = ('log_date', 'log_type', 'video', 'average_seconds_watched', 'average_view_percentage', 'total_views')
    search_fields = ('video__title',)
    list_filter = ('log_date', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'log_type', 'video', 'average_seconds_watched', 'average_view_percentage', 'total_views', 'most_views_location')
        }),
        ('Metrics', {
            'fields': ('audience_retention_percentage', 'bounce_rate', 'conversion_rate')
        }),
    )
    readonly_fields = ('log_date',)

@admin.register(VideoMetricsLog)
class VideoMetricsLogAdmin(ModelAdmin):
    list_display = ('log_date', 'log_type', 'video', 'impressions', 'likes', 'dislikes', 'comments', 'views',"xp_growth_percentage")
    search_fields = ('video__title',)
    list_filter = ('log_date', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'log_type', 'video', 'impressions', 'likes', 'dislikes', 'comments', 'views', 'video_xp',"xp_growth_percentage")
        }),
    )
    readonly_fields = ('log_date',)

@admin.register(VideoXPDiffLog)
class VideoXPDiffLogAdmin(ModelAdmin):
    list_display = ('video', 'day_usage_difference', 'week_usage_difference', 'month_usage_difference', 'yearly_usage_difference', 'logged_at')
    search_fields = ('video__title',)
    list_filter = ('logged_at',)
    fieldsets = (
        (None, {
            'fields': ('video', 'day_usage_difference', 'week_usage_difference', 'month_usage_difference', 'yearly_usage_difference', 'logged_at')
        }),
    )
    readonly_fields = ('logged_at',)

@admin.register(SubscribersMetricLog)
class SubscribersMetricLogAdmin(ModelAdmin):
    list_display = ('log_date', 'log_type', 'channel', 'subscriber_gain', 'subscriber_lost', 'total_subscribers', 'net_subscribers')
    search_fields = ('channel__name',)
    list_filter = ('log_date', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'log_type', 'channel', 'subscriber_gain', 'subscriber_lost', 'total_subscribers', 'net_subscribers', 'subscriber_growth_percentage')
        }),
    )
    readonly_fields = ('log_date',)

@admin.register(LoungeMetricLog)
class LoungeMetricLogAdmin(ModelAdmin):
    list_display = ('log_date', 'log_type', 'lounge', 'lounge_xp', 'lounge_level', 'total_members',"xp_growth_percentage")
    search_fields = ('lounge__name',)
    list_filter = ('log_date', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'log_type', 'lounge', 'lounge_xp', 'lounge_level', 'total_members', 'total_categories', 'lounge_tiers',"xp_growth_percentage")
        }),
    )
    readonly_fields = ('log_date',)

@admin.register(LoungePostMetricLog)
class LoungePostMetricLogAdmin(ModelAdmin):
    list_display = ('log_date', 'log_type', 'lounge_post', 'xp', 'impressions', 'likes', 'dislikes', 'replies',"xp_growth_percentage")
    search_fields = ('lounge_post__text',)
    list_filter = ('log_date', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'log_type', 'lounge_post', 'xp', 'impressions', 'likes', 'dislikes', 'replies',"xp_growth_percentage")
        }),
    )
    readonly_fields = ('log_date',)

@admin.register(UserTopicRelations)
class UserTopicRelationsAdmin(ModelAdmin):
    list_display = ('log_date', 'user', 'topic_id', 'topic_category_id', 'likes', 'dislikes', 'comments', 'views')
    search_fields = ('user__user__username',)
    list_filter = ('log_date',)
    fieldsets = (
        (None, {
            'fields': ('log_date', 'relation_id', 'user', 'topic_id', 'topic_category_id', 'likes', 'dislikes', 'comments', 'views', 'positive_comments_made', 'negative_comments_made', 'favoritism_weight')
        }),
    )
    readonly_fields = ('log_date', 'relation_id')

@admin.register(ChannelMetrics)
class ChannelMetricsAdmin(ModelAdmin):
    list_display = ('log_date', 'aggregation_type', 'log_type', 'channel', 'impressions', 'likes', 'dislikes', 'comments', 'views')
    search_fields = ('channel__name',)
    list_filter = ('log_date', 'aggregation_type', 'log_type')
    fieldsets = (
        (None, {
            'fields': ('log_date', 'aggregation_type', 'log_type', 'channel', 'impressions', 'likes', 'dislikes', 'comments', 'views', 'video_xp',"xp_growth_percentage")
        }),
    )
    readonly_fields = ('log_date',)


@admin.register(SeptemberContest)
class SeptemberContestAdmin(ModelAdmin):
    list_display = ('get_user', 'subscriber_count', 'start_date', 'end_date', 'creation_date')
    search_fields = ('user__user__username',)
    list_filter = ('subscriber_count',)

    def get_user(self, obj):
        """Show the contestant as @username."""
        return "@" + obj.user.user.username

    get_user.short_description = 'Username'
    get_user.admin_order_field = 'user__user__username'


@admin.register(SeptemberContestDetailsModifier)
class SeptemberContestDetailsModifierAdmin(ModelAdmin):
    list_display = ('start_date', 'end_date', 'creation_date')
    search_fields = ('creation_date',)
    list_filter = ('creation_date',)
