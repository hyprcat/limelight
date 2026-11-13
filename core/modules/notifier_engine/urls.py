from django.urls import path

from modules.notifier_engine import views

urlpatterns = [
    path("render_lounge_notifications", views.render_lounge_notifications, name="render_lounge_notifications"),
    path("render_replies", views.render_replies, name="render_replies"),
    path("render_subscriptions", views.render_subscriptions, name="render_subscriptions"),
    path("render_for_you", views.render_for_you, name="render_for_you"),
    path("mark_notification_as_seen", views.mark_notification_as_seen, name="mark_notification_as_seen"),
    path("get_unread_notification_count", views.get_unread_notification_count, name="get_unread_notification_count"),
]
