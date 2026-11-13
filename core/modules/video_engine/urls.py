from django.urls import path

from modules.video_engine import views

video_urls = [
    path("get_thumbnail/<str:video_id>", views.get_thumbnail, name="get_thumbnail"),
    path("upload_video_DRAFT", views.upload_video_DRAFT, name="upload_video_DRAFT"),
    path("stream/<str:video_id>/<str:resolution>/<str:file>", views.stream_hls, name="stream"),
    path("stream_original_video/<str:video_id>", views.stream_original_video, name="stream_og"),
]

creator_studio = [
    path("save_video_draft", views.save_video_draft, name="save_video_draft"),
    path("save_video_draft_I", views.save_video_draft_I, name="save_video_draft_I"),
    path("save_thumbnail", views.save_thumbnail_api, name="save_thumbnail"),
    path("fetch_all_drafts", views.fetch_all_drafts, name="fetch_all_drafts"),
    path("fetch_unlisted", views.fetch_unlisted, name="fetch_unlisted"),
    path("fetch_lounge_only", views.fetch_lounge_only, name="fetch_lounge_only"),
    path("fetch_all_videos", views.fetch_all_videos, name="fetch_all_videos"),
    path("fetch_scheduled_videos", views.fetch_scheduled_videos, name="fetch_scheduled_videos"),
    path("fetch_subscribed_to_videos", views.fetch_subscribed_to_videos, name="fetch_subscribed_to_videos"),
    path("update_video_status", views.update_video_status_view, name="update_video_status"),
    path("delete_video", views.delete_video_view, name="delete_video"),
]

general = [
    path("fetch_videos", views.fetch_videos, name="fetch_videos"),
    path("fetch_creator_videos", views.fetch_creator_videos, name="fetch_creator_videos"),
    path("get_video_info", views.get_video_info, name="get_video_info"),
    path("fetch_video_comments", views.fetch_video_comments, name="fetch_video_comments"),
    path("fetch_children_comments", views.fetch_children_comments, name="fetch_children_comments"),
    path("render_video_comment_tree", views.render_video_comment_tree, name="render_video_comment_tree"),
    path("report_video", views.report_video_view, name="report_video"),
    path("report_comment", views.report_comment_view, name="report_comment"),
    path("render_home_v2_api", views.render_home_v2_api, name="render_home_v2_api"),
    path("render_video_home", views.render_video_home, name="render_video_home"),
    path("render_threads_home", views.render_threads_home, name="render_threads_home"),
]

actions = [
    path("set_impression", views.set_impression_api, name="set_impression_api"),
    path("set_view", views.set_view_api, name="set_view_api"),
    path("like_video_view", views.like_video_view, name="like_video_view"),
    path("dislike_video_view", views.dislike_video_view, name="dislike_video_view"),
    path("like_comment_view", views.like_comment_view, name="like_comment_view"),
    path("dislike_comment_view", views.dislike_comment_view, name="dislike_comment_view"),
    path("remove_like_video_view", views.remove_like_video_view, name="remove_like_video_view"),
    path("remove_dislike_video_view", views.remove_dislike_video_view, name="remove_dislike_video_view"),
    path("remove_like_comment_view", views.remove_like_comment_view, name="remove_like_comment_view"),
    path("remove_dislike_comment_view", views.remove_dislike_comment_view, name="remove_dislike_comment_view"),
    path("add_comment_view", views.add_comment_view, name="add_comment_view"),
    path("add_comment_view_v2", views.add_comment_view_v2, name="add_comment_view_v2"),
    path("fetch_threaded_comments", views.fetch_threaded_comments_view, name="fetch_threaded_comments_view"),
    path("remove_comment_view", views.remove_comment_view, name="remove_comment_view"),
    path("fetch_video_reaction_status", views.fetch_video_reaction_status, name="fetch_video_reaction_status"),
    path("fetch_comment_reaction_status", views.fetch_comment_reaction_status, name="fetch_comment_reaction_status"),
]

playlists = [
    path("create_playlist_view", views.create_playlist_view, name="create_playlist_view"),
    path("modify_playlist_view", views.modify_playlist_view, name="modify_playlist_view"),
    path("delete_playlist", views.delete_playlist_view, name="delete_playlist"),
    path("add_video_to_playlist", views.add_video_to_playlist_view, name="add_video_to_playlist"),
    path("remove_video_from_playlist", views.remove_video_from_playlist_view, name="remove_video_from_playlist"),
    path("get_all_playlists", views.get_all_playlists_view, name="get_all_playlists"),
    path("get_all_playlist_items", views.get_all_playlist_items_view, name="get_all_playlist_items"),
    path("quick_fetch_playlists_view", views.quick_fetch_playlists_view, name="quick_fetch_playlists_view"),
]

videos = [
    path("get_top_videos_day_view", views.get_top_videos_day_view, name="get_top_videos_day_view"),
    path("get_top_videos_week_view", views.get_top_videos_week_view, name="get_top_videos_week_view"),
    path("get_top_videos_month_view", views.get_top_videos_month_view, name="get_top_videos_month_view"),
    path("get_top_videos_year_view", views.get_top_videos_year_view, name="get_top_videos_year_view"),
    path("get_watched_videos_api", views.get_watched_videos_api, name="get_watched_videos_api"),
    path("render_threads_creator", views.render_threads_creator, name="render_threads_creator"),
]

custom_feeds = [
    path("create_custom_feed_view", views.create_custom_feed_view, name="create_custom_feed_view"),
    path("add_topic_to_custom_feed_view", views.add_topic_to_custom_feed_view, name="add_topic_to_custom_feed_view"),
    path("add_creators_to_custom_feed_view", views.add_creators_to_custom_feed_view, name="add_creators_to_custom_feed_view"),
    path("remove_topic_from_custom_feed_view", views.remove_topic_from_custom_feed_view, name="remove_topic_from_custom_feed_view"),
    path("remove_creator_from_custom_feed_view", views.remove_creator_from_custom_feed_view, name="remove_creator_from_custom_feed_view"),
    path("change_feed_visibility_view", views.change_feed_visibility_view, name="change_feed_visibility_view"),
    path("delete_feed_view", views.delete_feed_view, name="delete_feed_view"),
    path("log_feed_usage_view", views.log_feed_usage_view, name="log_feed_usage_view"),
    path("remove_feed_usage_view", views.remove_feed_usage_view, name="remove_feed_usage_view"),
    path("set_impressions_to_feed_view", views.set_impressions_to_feed_view, name="set_impressions_to_feed_view"),
]

search = [
    path("get_search_videos", views.get_search_videos, name="get_search_videos"),
    path("get_search_comments", views.get_search_comments, name="get_search_comments"),
]

urlpatterns = video_urls + creator_studio + general + actions + playlists + videos + custom_feeds + search
