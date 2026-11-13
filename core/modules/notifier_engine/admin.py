from django.contrib import admin
from modules.notifier_engine.models import *
from unfold.admin import ModelAdmin


@admin.register(VideoUploadedNotification)
class VideoUploadedNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'linked_video', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'linked_video__title')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(LoungePostNotification)
class LoungePostNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'post', 'linked_lounge_user', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'post__text', 'linked_lounge_user__user__username')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(VideoCommentReplyNotification)
class VideoCommentReplyNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'reply_comment', 'replied_to', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'reply_comment__comment', 'replied_to__comment')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(LoungePostReplyNotification)
class LoungePostReplyNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'reply_comment', 'replied_to', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'reply_comment__text', 'replied_to__text')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)


@admin.register(PromotionNotificationWrapper)
class PromotionalNotificationWrapperAdmin(ModelAdmin):
    list_display = ('title', 'message', 'delivered', 'scheduled_time', 'creation_date')
    search_fields = ('title',)
    list_filter = ('creation_date', 'scheduled_time')
    ordering = ('-creation_date',)


@admin.register(PromotionalNotification)
class PromotionalNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'title', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'title')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(VideoLikeScheduledNotification)
class VideoLikeScheduledNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'linked_video', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'linked_video__title')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(VideoCommentNotification)
class VideoCommentNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'linked_comment', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'linked_comment__comment')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)

@admin.register(VideoProcessedNotification)
class VideoProcessedNotificationAdmin(ModelAdmin):
    list_display = ('receiver', 'linked_video', 'viewed', 'notification_sent', 'creation_date')
    search_fields = ('receiver__user__username', 'linked_video__title')
    list_filter = ('viewed', 'notification_sent', 'creation_date')
    ordering = ('-creation_date',)
