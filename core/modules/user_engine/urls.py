from django.urls import path

from modules.user_engine import views

subscriptions = [
    path("subscribe_channel", views.subscribe_channel, name="subscribe_channel"),
    path("unsubscribe_channel", views.unsubscribe_channel, name="unsubscribe_channel"),
    path("subscription_status", views.subscription_status, name="subscription_status"),
    path("update_channel_details", views.update_channel_details, name="update_channel_details"),
    path("update_profile_details", views.update_profile_details, name="update_profile_details"),
]

fundamentals = [
    path("create_user", views.create_user_api, name="create_user"),
    path("create_user_profile", views.create_user_profile, name="create_user_profile"),
    path("get_logged_in_user", views.get_logged_in_user, name="get_logged_in_user"),
    path("get_media_url/<str:user_name>", views.get_media_url, name="get_media_url"),
    path("get_banner/<str:user_name>", views.get_banner, name="get_banner"),
    path("validate_google_id_token", views.validate_google_id_token, name="google"),
    path("validate_apple_id_token", views.validate_apple_id_token, name="apple"),
    path("apple_callback", views.apple_callback, name="apple_callback"),
    path("update_geo_location", views.update_geo_location, name="update_geo_location"),
    path("get_user_info", views.get_user_info, name="get_user_info"),
    path("start_reset_pipeline", views.start_reset_pipeline, name="start_reset_pipeline"),
    path("verify_otp", views.verify_otp, name="verify_otp"),
    path("reset_password", views.reset_password, name="reset_password"),
]

user_profile = [
    path("update_profile_picture", views.update_profile_picture, name="update_profile_picture"),
    path("update_profile_banner", views.update_profile_banner, name="update_profile_banner"),
    path("delete_user_profile_picture", views.delete_user_profile_picture, name="delete_user_profile_picture"),
    path("delete_user_profile_banner", views.delete_user_profile_banner, name="delete_user_profile_banner"),
    path("recheck_token", views.recheck_token, name="recheck_token"),
    path("get_september_contest_details", views.get_september_contest_details, name="get_september_contest_details"),
    path("check_ban", views.check_ban, name="check_ban"),
]

batch_users = [
    path("get_star_creators", views.get_star_creators, name="get_star_creators"),
    path("get_top_users_day_view", views.get_top_users_day_view, name="get_top_users_day_view"),
    path("get_top_users_week_view", views.get_top_users_week_view, name="get_top_users_week_view"),
    path("get_top_users_month_view", views.get_top_users_month_view, name="get_top_users_month_view"),
    path("get_subscribed_to_api", views.get_subscribed_to_api, name="get_subscribed_to_api"),
]

apple_compliance = [
    path("check_block", views.check_block, name="check_block"),
    path("unblock_user", views.unblock_user, name="unblock_user"),
    path("block_user", views.block_user, name="block_user"),
    path("report_user", views.report_user, name="report_user"),
    path("get_blocked_users", views.get_blocked_users, name="get_blocked_users"),
    path("check_user_account_removal_request", views.check_user_account_removal_request, name="check_user_account_removal_request"),
    path("add_user_account_removal_request", views.add_user_account_removal_request, name="add_user_account_removal_request"),
]

urlpatterns = subscriptions + fundamentals + user_profile + batch_users + apple_compliance
