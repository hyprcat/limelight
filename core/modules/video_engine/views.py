import os

from django.conf import settings
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from modules.api import error_response, json_endpoint, make_response, redirect_to_cdn, s3_object
from modules.user_engine.manager import UserEngine
from modules.video_engine import manager
from modules.video_engine.manager import VideoEngineManager
from modules.video_engine.models import CommentDisLikes, CommentLikes, DisLikes, Likes


def text_endpoint(*required):
    """A JSON endpoint whose reply the client decodes from text (see modules.api.make_response)."""
    return json_endpoint(*required, as_text=True)


def body_token_endpoint(*required):
    """A JSON endpoint from before the Authorization header was used: the token is a body field."""
    return json_endpoint(*required, "token", header_token=False)


def media_folder(video_id):
    """Return the bucket folder of a video. Folder names are the video id without dashes."""
    return f"media/videos/{video_id.replace('-', '')}"


# Media
# ------------------------------------------------------------------------------


def get_thumbnail(_, video_id):
    """Redirect to a video's thumbnail on the CDN."""
    return redirect_to_cdn(f"{media_folder(video_id)}/thumbnail.jpeg")


def stream_original_video(_, video_id):
    """Redirect to the uploaded source file of a video on the CDN."""
    return redirect_to_cdn(f"{media_folder(video_id)}/original.mp4")


def stream_hls(_, video_id, resolution, file):
    """Serve one HLS playlist or segment of a transcoded video from S3."""
    s3_response, error = s3_object(f"{media_folder(video_id)}/{resolution}/{file}")
    if error:
        return error
    return HttpResponse(s3_response["Body"].read(), content_type="application/mp2t")


# Upload and creator studio
# ------------------------------------------------------------------------------


@csrf_exempt
@require_POST
def upload_video_DRAFT(request):
    """Append one chunk of a video upload to its file in the temporary input folder."""
    if UserEngine().get_logged_in_user(request.headers.get("Authorization")) is None:
        return error_response("Invalid Login credentials", 401)
    if "video" not in request.FILES:
        return error_response("Missing fields: video", 400)

    target_folder = os.path.join(settings.MEDIA_ROOT, "tmp", "input")
    os.makedirs(target_folder, exist_ok=True)

    upload = request.FILES["video"]
    with open(os.path.join(target_folder, upload.name), "ab") as destination:
        for chunk in upload.chunks():
            destination.write(chunk)

    return HttpResponse("File(s) uploaded!")


@json_endpoint("file_name", "token", header_token=False, as_text=True)
def save_video_draft(data):
    """Create a draft video from a file already uploaded through upload_video_DRAFT."""
    return VideoEngineManager().save_video_draft(data["file_name"], data["token"])


@csrf_exempt
@require_POST
def save_video_draft_I(request):
    """Save a draft's title, description, flags, topic and optional thumbnail. Multipart."""
    fields = ("video_id", "title", "description", "paid_promotion", "age_restriction", "language", "topic")
    data = {field: request.POST.get(field) for field in fields}
    data["token"] = request.headers.get("Authorization")
    if "thumbnail" in request.FILES:
        data["thumbnail"] = request.FILES["thumbnail"]
    return make_response(VideoEngineManager().save_draft_part_I(data))


@csrf_exempt
@require_POST
def save_thumbnail_api(request):
    """Replace a video's thumbnail. Multipart, fields `id` and `media`."""
    video_id = request.POST.get("id")
    if video_id is None or "media" not in request.FILES:
        return error_response("Missing fields: id, media", 400)
    return make_response(manager.save_thumbnail(video_id, request.FILES["media"]))


@json_endpoint("video_id", "token", header_token=False)
def update_video_status_view(data):
    """Change a video between public, draft, lounge-only, scheduled and unlisted."""
    return manager.update_video_status(data)


@json_endpoint("video_id")
def delete_video_view(data):
    """Delete one of the logged-in user's videos."""
    return manager.delete_video(data["video_id"], data["token"])


@text_endpoint("page_number")
def fetch_all_drafts(data):
    """List the logged-in creator's drafts."""
    return VideoEngineManager().get_all_drafts(data["token"], data["page_number"])


@text_endpoint("page_number")
def fetch_unlisted(data):
    """List the logged-in creator's unlisted videos."""
    return VideoEngineManager().get_all_unlisted(data["token"], data["page_number"])


@text_endpoint("page_number")
def fetch_lounge_only(data):
    """List the logged-in creator's lounge-only videos."""
    return VideoEngineManager().get_lounge_only(data["token"], data["page_number"])


@text_endpoint("page_number")
def fetch_all_videos(data):
    """List all of the logged-in creator's videos."""
    return VideoEngineManager().get_creator_videos(data["token"], data["page_number"])


@text_endpoint("page_number")
def fetch_scheduled_videos(data):
    """List the logged-in creator's scheduled videos."""
    return VideoEngineManager().get_scheduled_videos(data["token"], data["page_number"])


# Feeds and browsing
# ------------------------------------------------------------------------------


@text_endpoint()
def render_home_v2_api(data):
    """Build the home screen for the logged-in user."""
    return manager.render_home_v2(data["token"])


@text_endpoint()
def render_video_home(data):
    """Build the videos tab of the home screen."""
    return manager.render_videos_home(data["token"])


@text_endpoint()
def render_threads_home(data):
    """Build the threads tab of the home screen."""
    return manager.render_home_threads(data["token"])


@text_endpoint("page_number")
def fetch_videos(data):
    """Page through the recommended videos, optionally only or without short videos."""
    return VideoEngineManager().get_all_videos(
        data["token"],
        data["page_number"],
        exclude_short_videos=data.get("exclude_short_videos", False),
        only_short_videos=data.get("only_short_videos", False),
    )


@text_endpoint("page_number")
def fetch_subscribed_to_videos(data):
    """List videos from the channels the logged-in user is subscribed to."""
    return manager.get_subscribed_to_videos(data["token"], data["page_number"])


@text_endpoint("user_id", "page_number")
def fetch_creator_videos(data):
    """List a creator's public videos."""
    return VideoEngineManager().get_user_videos_id(data["user_id"], data["page_number"], data["token"])


@text_endpoint("page_number")
def get_watched_videos_api(data):
    """List the logged-in user's watch history."""
    return manager.get_watched_videos(page_number=data["page_number"], token=data["token"])


@json_endpoint("video_id", header_token=False)
def get_video_info(data):
    """Return a video's metadata."""
    return VideoEngineManager().video_metadata_to_json(data["video_id"])


def _top_videos(data, ranking):
    """Shared body of the top video charts, optionally filtered by place, category and length."""
    return ranking(
        data["page_number"],
        data.get("city"),
        data.get("country"),
        data.get("region"),
        data.get("category_id"),
        exclude_short_videos=data.get("exclude_short_videos", False),
        only_short_videos=data.get("only_short_videos", False),
    )


@text_endpoint("page_number")
def get_top_videos_day_view(data):
    """List the top videos of the day."""
    return _top_videos(data, manager.get_top_videos_day)


@text_endpoint("page_number")
def get_top_videos_week_view(data):
    """List the top videos of the week."""
    return _top_videos(data, manager.get_top_videos_week)


@text_endpoint("page_number")
def get_top_videos_month_view(data):
    """List the top videos of the month."""
    return _top_videos(data, manager.get_top_videos_month)


@text_endpoint("page_number")
def get_top_videos_year_view(data):
    """List the top videos of the year."""
    return _top_videos(data, manager.get_top_videos_year)


@text_endpoint("query", "page_number")
def get_search_videos(data):
    """Search videos."""
    return VideoEngineManager().search_videos(data["query"], data["page_number"])


@text_endpoint("query", "page_number")
def get_search_comments(data):
    """Search video comments."""
    return VideoEngineManager().search_comments(data["query"], data["page_number"], data["token"])


# Watch signals
# ------------------------------------------------------------------------------


@text_endpoint("video_id")
def set_impression_api(data):
    """Record that a video was shown to the logged-in user."""
    return manager.set_impression(data["token"], data["video_id"])


@text_endpoint("video_id")
def set_view_api(data):
    """Record a view of a video, with the watch details the client sends."""
    return manager.set_view(data["token"], data["video_id"], data)


# Video reactions
# ------------------------------------------------------------------------------


@body_token_endpoint("video_id")
def like_video_view(data):
    """Like a video."""
    return manager.set_like(data["video_id"], data["token"])


@body_token_endpoint("video_id")
def dislike_video_view(data):
    """Dislike a video."""
    return manager.set_dislike(data["video_id"], data["token"])


@body_token_endpoint("video_id")
def remove_like_video_view(data):
    """Remove the logged-in user's like from a video."""
    return manager.remove_like(data["video_id"], data["token"])


@body_token_endpoint("video_id")
def remove_dislike_video_view(data):
    """Remove the logged-in user's dislike from a video."""
    return manager.remove_dislike(data["video_id"], data["token"])


@body_token_endpoint("video_id")
def fetch_video_reaction_status(data):
    """Return the like and dislike counts of a video and the logged-in user's own reaction."""
    user = UserEngine().get_logged_in_user(data["token"])
    if user is None:
        return error_response("Invalid Login credentials", 401)
    video_id = data["video_id"]
    return {
        "like": VideoEngineManager().get_like_object(video_id, user.id) is not None,
        "dislike": VideoEngineManager().get_dislike_object(video_id, user.id) is not None,
        "total_likes": Likes.objects.filter(video__video_id=video_id).count(),
        "total_dislikes": DisLikes.objects.filter(video__video_id=video_id).count(),
    }


# Comments (shown as threads in the app)
# ------------------------------------------------------------------------------


@body_token_endpoint("video_id", "comment_string")
def add_comment_view(data):
    """Comment on a video, or reply under a root comment."""
    return manager.add_comment(data["video_id"], data["token"], data["comment_string"], data.get("root_comment_id"))


@body_token_endpoint("video_id", "comment_string")
def add_comment_view_v2(data):
    """Comment on a video, or reply to any comment in a thread."""
    return manager.add_comment_v2(
        data["video_id"], data["token"], data["comment_string"], data.get("parent_comment")
    )


@body_token_endpoint("comment_id")
def remove_comment_view(data):
    """Delete one of the logged-in user's comments."""
    return manager.remove_comment(data["comment_id"], data["token"])


@text_endpoint("video_id", "page_number", "root_comment_id")
def fetch_video_comments(data):
    """List a video's comments, or the replies under a root comment."""
    return manager.get_video_comments(data["video_id"], data["page_number"], data["root_comment_id"], data["token"])


@text_endpoint("post_id", "page_number", "is_root_comment")
def fetch_threaded_comments_view(data):
    """List a thread of comments with their nested replies."""
    return manager.fetch_threaded_comments(
        data["post_id"], data["page_number"], data["is_root_comment"], data["token"]
    )


@text_endpoint("post_id", "page_number")
def fetch_children_comments(data):
    """List the direct replies to a comment."""
    return manager.fetch_child_posts(data["post_id"], data["page_number"], data["token"])


@text_endpoint("video_id", "page_number")
def render_video_comment_tree(data):
    """Return a video's comments as a tree."""
    return manager.render_comment_tree(data["video_id"], data["page_number"], data["token"])


@text_endpoint("user_id", "page_number")
def render_threads_creator(data):
    """List the comment threads a user has written."""
    return manager.get_video_comments_users(data["token"], data["page_number"], data["user_id"])


@body_token_endpoint("comment_id")
def like_comment_view(data):
    """Like a comment."""
    return manager.set_comment_like(data["comment_id"], data["token"])


@body_token_endpoint("comment_id")
def dislike_comment_view(data):
    """Dislike a comment."""
    return manager.set_comment_dislike(data["comment_id"], data["token"])


@body_token_endpoint("comment_id")
def remove_like_comment_view(data):
    """Remove the logged-in user's like from a comment."""
    return manager.remove_comment_like(data["comment_id"], data["token"])


@body_token_endpoint("comment_id")
def remove_dislike_comment_view(data):
    """Remove the logged-in user's dislike from a comment."""
    return manager.remove_comment_dislike(data["comment_id"], data["token"])


@body_token_endpoint("comment_id")
def fetch_comment_reaction_status(data):
    """Return the like and dislike counts of a comment and the logged-in user's own reaction."""
    user = UserEngine().get_logged_in_user(data["token"])
    if user is None:
        return error_response("Invalid Login credentials", 401)
    comment_id = data["comment_id"]
    return {
        "like": VideoEngineManager().get_comment_like_object(comment_id, user.id) is not None,
        "dislike": VideoEngineManager().get_comment_dislike_object(comment_id, user.id) is not None,
        "total_likes": CommentLikes.objects.filter(comment_id=comment_id).count(),
        "total_dislikes": CommentDisLikes.objects.filter(comment_id=comment_id).count(),
    }


# Reports
# ------------------------------------------------------------------------------


@text_endpoint("video_id", "reason")
def report_video_view(data):
    """Report a video to the moderators."""
    return manager.report_video(data["token"], data["video_id"], data["reason"])


@text_endpoint("comment_id", "reason")
def report_comment_view(data):
    """Report a comment to the moderators."""
    return manager.report_comment(data["token"], data["comment_id"], data["reason"])


# Playlists
# ------------------------------------------------------------------------------


@body_token_endpoint("playlist_name", "playlist_description")
def create_playlist_view(data):
    """Create a playlist."""
    return manager.create_playlist(data["token"], data["playlist_name"], data["playlist_description"])


@body_token_endpoint("playlist_id", "playlist_name", "playlist_description")
def modify_playlist_view(data):
    """Rename a playlist or change its description."""
    return manager.modify_playlist(
        data["token"], data["playlist_id"], data["playlist_name"], data["playlist_description"]
    )


@body_token_endpoint("playlist_id")
def delete_playlist_view(data):
    """Delete a playlist."""
    return manager.delete_playlist(data["token"], data["playlist_id"])


@body_token_endpoint("playlist_id", "video_id")
def add_video_to_playlist_view(data):
    """Add a video to a playlist."""
    return manager.add_video_to_playlist(data["token"], data["video_id"], data["playlist_id"])


@body_token_endpoint("playlist_id", "video_id")
def remove_video_from_playlist_view(data):
    """Remove a video from a playlist."""
    return manager.remove_video_from_playlist(data["token"], data["video_id"], data["playlist_id"])


@text_endpoint("user_id", "page_number")
def get_all_playlists_view(data):
    """List a user's playlists."""
    return manager.get_all_playlists(data["token"], data["user_id"], data["page_number"])


@text_endpoint("playlist_id", "page_number")
def get_all_playlist_items_view(data):
    """List the videos in a playlist."""
    return manager.get_all_playlist_items(data["playlist_id"], data["page_number"])


@text_endpoint("video_id")
def quick_fetch_playlists_view(data):
    """List the logged-in user's playlists that already hold a video."""
    return manager.quick_fetch_playlist(data["token"], data["video_id"])


# Custom feeds
# ------------------------------------------------------------------------------


@text_endpoint()
def create_custom_feed_view(data):
    """Create a custom feed from topics and creators."""
    return manager.create_custom_feed(data["token"], data)


@text_endpoint("feed_id", "topics")
def add_topic_to_custom_feed_view(data):
    """Add topics to a custom feed."""
    return manager.add_topic_to_custom_feed(data["token"], data["feed_id"], data["topics"])


@text_endpoint("feed_id", "users")
def add_creators_to_custom_feed_view(data):
    """Add creators to a custom feed."""
    return manager.add_creators_to_custom_feed(data["token"], data["feed_id"], data["users"])


@text_endpoint("feed_id", "topic_id")
def remove_topic_from_custom_feed_view(data):
    """Remove a topic from a custom feed."""
    return manager.remove_topic_from_custom_feed(data["token"], data["feed_id"], data["topic_id"])


@text_endpoint("feed_id", "user_id")
def remove_creator_from_custom_feed_view(data):
    """Remove a creator from a custom feed."""
    return manager.remove_creator_from_custom_feed(data["token"], data["feed_id"], data["user_id"])


@text_endpoint("feed_id", "status")
def change_feed_visibility_view(data):
    """Make a custom feed public or private."""
    return manager.change_feed_visibility(data["token"], data["feed_id"], data["status"])


@text_endpoint("feed_id")
def delete_feed_view(data):
    """Delete a custom feed."""
    return manager.delete_feed(data["token"], data["feed_id"])


@text_endpoint("feed_id")
def log_feed_usage_view(data):
    """Record that the logged-in user started using a custom feed."""
    return manager.log_feed_usage(data["token"], data["feed_id"])


@text_endpoint("feed_id")
def remove_feed_usage_view(data):
    """Record that the logged-in user stopped using a custom feed."""
    return manager.remove_feed_usage(data["token"], data["feed_id"])


@text_endpoint("feed_id")
def set_impressions_to_feed_view(data):
    """Record that a custom feed was shown to the logged-in user."""
    return manager.set_impressions_to_feed(data["token"], data["feed_id"])
