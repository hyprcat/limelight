import logging
import math
import os
from datetime import datetime, timedelta
from itertools import chain

from django.conf import settings
from django.core.exceptions import ObjectDoesNotExist
from django.core.files.base import File
from django.core.paginator import Paginator
from django.db import IntegrityError
from django.db.models import F, OuterRef, Subquery
from django.utils import timezone

from modules.analytics_engine.models import LogType, VideoMetricsLog
from modules.user_engine.manager import UserEngine
from modules.user_engine.models import ChannelSubscribers, UserGeolocations, UserProfile
from modules.video_engine.models import *


def build_response(message):
    """Wrap a message in the response dictionary every endpoint returns."""
    return {"status": 200, "message": message}


def read_tmp_file(file_name):
    """Open an uploaded file from MEDIA_ROOT/tmp/input for binary reading."""
    targetFolder = os.path.join(settings.MEDIA_ROOT, "tmp", "input")
    media_url = os.path.join(targetFolder, file_name)
    return open(media_url, "rb")




def decode_bool(value):
    """Turn the string "true" into True and anything else into False."""
    return value == "true"


def update_or_create_object(model, filter_params, update_params=None):
    """Update the row matching filter_params, or create it when it is missing.

    Returns the object, or None when the row exists and there is nothing to update.
    """
    try:
        obj = model.objects.get(**filter_params)
        if update_params:
            for key, value in update_params.items():
                setattr(obj, key, value)
            obj.save()
            return obj
    except ObjectDoesNotExist:
        try:
            return model.objects.create(**filter_params)
        except IntegrityError as e:
            raise Exception(f"IntegrityError: {e}")
    except Exception as e:
        raise Exception(f"Error: {e}")


def set_impression(token, video_id):
    """Record that the logged in user was shown a video and bump its impression count."""
    logged_in_user = UserEngine().get_logged_in_user(token)
    video_obj = get_video(video_id)
    user_profile = UserEngine().get_user_profile(logged_in_user)
    filter_params = {"video": video_obj, "impression_on": user_profile}
    update_params = {"times_impressed_again": F("times_impressed_again") + 1}
    obj = update_or_create_object(VideoImpressions, filter_params, update_params)
    if obj is not None:
        video_obj.impressions += 1
        video_obj.save()
    return build_response("Impression set successfully.")


def set_view(token, video_id, parameters):
    """Record watch progress for the logged in user.

    A watch above 85% counts as a rewatch. The video's view count is refreshed
    once the watch passes 55%.
    """
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        video_obj = get_video(video_id)

        user_profile = UserEngine().get_user_profile(logged_in_user)
        filter_params = {"video": video_obj, "viewed_by": user_profile}
        last_watch_percentage = math.ceil(
            (parameters.get("view_time_seconds", 0) / video_obj.video_duration_seconds) * 100
        )
        update_params = {
            "view_time_seconds": parameters.get("view_time_seconds", 0),
            "view_percentage": last_watch_percentage,
            "times_rewatched": F("times_rewatched") + 1 if last_watch_percentage > 85 else F("times_rewatched"),
            "last_rewatch": datetime.now(),
        }
        obj = update_or_create_object(VideoViews, filter_params, update_params)
        if obj and last_watch_percentage > 55:
            video_obj.views = VideoViews.objects.filter(video=video_obj).count()
            video_obj.save()
        return build_response("sucess.")
    except Exception as e:
        return build_response(f"Can't set view. Error: {e}")


def get_object(object_id, model):
    """Fetch a VideoPost by video_id, or a comment by comment_id for any other model."""
    try:
        if model == VideoPost:
            return model.objects.get(video_id=object_id)
        else:
            return model.objects.get(comment_id=object_id)
    except model.DoesNotExist:
        raise ObjectDoesNotExist(f"{model.__name__} not found")


def set_reaction(object_id, token, reaction_type, model, reaction_model, opposite_reaction_model, action_name):
    """Toggle a like or dislike on a video or comment.

    A second call with the same reaction removes it. An existing opposite
    reaction is deleted. The counters on the target are kept in step.
    """
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        obj = get_object(object_id, model)
        model_name = "video" if model == VideoPost else "comment"

        opposite_reaction_type = "Like" if reaction_type == "Dislike" else "Dislike"
        reaction_field = f"{reaction_type.lower()}s"
        opposite_field = f"{opposite_reaction_type.lower()}s"

        opposite_reaction = opposite_reaction_model.objects.filter(
            **{f"{opposite_reaction_type.lower()}d_by": user_profile, model_name: obj}
        ).first()

        reaction_obj, created = reaction_model.objects.get_or_create(
            **{f"{reaction_type.lower()}d_by": user_profile, model_name: obj}
        )

        update_fields = [reaction_field]
        if opposite_reaction:
            setattr(obj, opposite_field, F(opposite_field) - 1)
            opposite_reaction.delete()
            update_fields.append(opposite_field)

        if created:
            setattr(obj, reaction_field, F(reaction_field) + 1)
        else:
            setattr(obj, reaction_field, F(reaction_field) - 1)
            reaction_obj.delete()

        obj.save(update_fields=update_fields)

    except IntegrityError as e:
        return build_response(f"IntegrityError: {e}")

    except Exception as e:
        return build_response(f"Can't set {reaction_type}. Error: {e}")

    return build_response("success")


def set_like(video_id, token):
    """Toggle the logged in user's like on a video."""
    return set_reaction(video_id, token, "Like", VideoPost, Likes, DisLikes, "liked")


def set_dislike(video_id, token):
    """Toggle the logged in user's dislike on a video."""
    return set_reaction(video_id, token, "Dislike", VideoPost, DisLikes, Likes, "disliked")


def set_comment_like(comment_id, token):
    """Toggle the logged in user's like on a comment."""
    return set_reaction(comment_id, token, "Like", Comment, CommentLikes, CommentDisLikes, "liked")


def set_comment_dislike(comment_id, token):
    """Toggle the logged in user's dislike on a comment."""
    return set_reaction(comment_id, token, "Dislike", Comment, CommentDisLikes, CommentLikes, "disliked")


def remove_reaction(object_id, token, reaction_type, model, reaction_model):
    """Delete the logged in user's like or dislike and lower the counter on the target."""
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        obj = get_object(object_id, model)
        model_name = "video" if model == VideoPost else "comment"
        reaction_field = f"{reaction_type.lower()}s"
        reaction_obj = reaction_model.objects.filter(
            **{f"{reaction_type.lower()}d_by": user_profile, model_name: obj}
        ).first()
        if reaction_obj:
            setattr(obj, reaction_field, F(reaction_field) - 1)
            reaction_obj.delete()
            obj.save()
        return build_response("success")
    except IntegrityError as e:
        return build_response(f"IntegrityError: {e}")
    except Exception as e:
        return build_response(f"Can't remove {reaction_type}. Error: {e}")


def remove_like(video_id, token):
    """Remove the logged in user's like from a video."""
    return remove_reaction(video_id, token, "Like", VideoPost, Likes)


def remove_dislike(video_id, token):
    """Remove the logged in user's dislike from a video."""
    return remove_reaction(video_id, token, "Dislike", VideoPost, DisLikes)


def remove_comment_like(comment_id, token):
    """Remove the logged in user's like from a comment."""
    return remove_reaction(comment_id, token, "Like", Comment, CommentLikes)


def remove_comment_dislike(comment_id, token):
    """Remove the logged in user's dislike from a comment."""
    return remove_reaction(comment_id, token, "Dislike", Comment, CommentDisLikes)


def get_comment_object(comment_id):
    """Return the comment with this id, or None."""
    return Comment.objects.filter(comment_id=comment_id).first()


def get_video_comments(video_id, page_number, root_comment_id=None, token=None):
    """Page through a video's top level comments, or the replies under one root comment, newest first."""
    if root_comment_id is None:
        comment_qs = Comment.objects.filter(video__video_id=video_id, comment_depth=1).order_by("-creation_date")
    else:
        comment_qs = Comment.objects.filter(root_comment__comment_id=root_comment_id).order_by("-creation_date")
    return VideoEngineManager().token_paginator(
        comment_qs, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
    )


def make_actual_threads(comment_id, token):
    """Build a thread for one comment: the comment, then each ancestor up to the top, with the linked video."""
    current_post = Comment.objects.filter(comment_id=comment_id).get()
    result = {
        "linked_video": VideoEngineManager().video_metadata_to_json(current_post.video.video_id),
        "posts": [],
    }

    while True:
        result["posts"].append(VideoEngineManager().comment_metadata_to_json_obj(current_post, token))
        if current_post.parent_comment is not None:
            current_post = current_post.parent_comment
        elif current_post.root_comment is not None:
            current_post = current_post.root_comment
        else:
            break

    return result


def _comments_as_threads(comment_qs, page_number, token):
    """Paginate comments and expand every comment on the page into its full thread."""
    result = VideoEngineManager().token_paginator(
        comment_qs, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
    )

    threads = []
    for i in result["data"]:
        threads.append(make_actual_threads(i["id"], token))

    new_result = result.copy()
    new_result["data"] = threads
    return new_result


def get_video_comments_users(token, page_number, user_id):
    """Page through the threads a user has commented in, newest comment first."""
    try:
        if token is None:
            raise Exception("Can't get user")

        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        user_profile = UserEngine().get_user_profile_with_id(user_id)

        comment_qs = Comment.objects.filter(commented_by=user_profile).order_by("-creation_date")
        return _comments_as_threads(comment_qs, page_number, token)
    except Exception as e:
        return build_response(f"Error fetching comments: {str(e)}")


def get_top_threads(token, page_number):
    """Page through all video threads, deepest comments first."""
    try:
        if token is None:
            raise Exception("Can't get user")

        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        comment_qs = Comment.objects.order_by("-comment_depth")
        return _comments_as_threads(comment_qs, page_number, token)
    except Exception as e:
        return build_response(f"Error fetching comments: {str(e)}")


def video_metadata_to_json_obj(video: VideoPost):
    """Serialise a VideoPost into the dictionary the clients receive."""
    m = {
        "id": str(video.video_id),
        "thumbnail": video.thumbnail.name,
        "title": video.title,
        "video_file_original_name": video.video_file_original_name,
        "video_file": video.video_file.name,
        "video_description": video.video_description,
        "video_creator": UserEngine().to_json(video.creator.user, video.creator),
        "video_duration_seconds": video.video_duration_seconds,
        "impressions": video.impressions,
        "likes": video.likes,
        "dislikes": video.dislikes,
        "comments": video.comments,
        "views": video.views,
        "video_xp": video.video_xp,
        "creation_date": str(video.creation_date),
        "is_advertisement": video.is_advertisement,
        "is_draft": video.is_draft,
        "is_unlisted": video.is_unlisted,
        "is_lounge_only": video.is_lounge_only,
        "is_age_restricted": video.is_age_restricted,
        "is_scheduled": video.is_scheduled,
        "scheduled_date": video.scheduled_date,
        "contains_paid_promotion": video.contains_paid_promotion,
        "topic_id": video.topic_id,
        "topic_category_id": video.topic_category_id,
        "language": video.language,
        "transcript": video.transcript,
        "native_transcript": video.native_language_transcript,
        "transcript_sentiment": video.transcript_sentiment,
        "description_sentiment": video.description_sentiment,
        "metrics_last_updated": str(video.metrics_last_updated),
        "is_active": video.is_active,
        "is_encoded": video.is_encoded,
        "is_processing": video.is_processing,
        "gone_through_ml": video.gone_through_ml,
        "max_transcoded_resolution": video.max_transcoded_resolution,
        "video_width": video.video_width,
        "video_height": video.video_height,
    }
    return m


def comment_to_dict(comment_obj):
    """Serialise a Comment into the dictionary the clients receive."""
    return {
        "id": str(comment_obj.comment_id),
        "video_id": str(comment_obj.video.video_id),
        "comment": comment_obj.comment,
        "commented_by": UserEngine().get_user_info(comment_obj.commented_by.user),
        "replies": comment_obj.replies,
        "likes": comment_obj.likes,
        "dislikes": comment_obj.dislikes,
        "comment_sentiment": comment_obj.comment_sentiment,
        "root_comment_id": str(comment_obj.root_comment.comment_id) if comment_obj.root_comment else None,
        "is_reply": comment_obj.is_reply,
        "creation_date": comment_obj.creation_date.isoformat(),
        "comment_depth": comment_obj.comment_depth,
        "parent_comment_id": str(comment_obj.parent_comment.comment_id) if comment_obj.parent_comment else None,
    }


def get_video(video_id):
    """Return the video with this id, or None."""
    return VideoPost.objects.filter(video_id=video_id).first()


def save_thumbnail(id, media):
    """Replace a video's thumbnail file."""
    # NOTE: there is no ownership check here. Anyone who knows a video id can replace its thumbnail.
    video = get_video(id)
    try:
        if video is not None:
            video.thumbnail = media
            video.save()
            return build_response("saved thumbnail")
        else:
            return build_response("Video does not exists.")
    except Exception as e:
        return build_response(f"Error saving thumbnail: {str(e)}")


def delete_video(id, token):
    """Delete a video. Only its creator may do this."""
    try:
        video = get_video(id)
        if video:
            logged_in_user = UserEngine().get_logged_in_user(token)
            if logged_in_user is None or logged_in_user != video.creator.user:
                return build_response("can't delete video: Not Authorized.")

            parent_user = video.creator
            if video.is_active:
                parent_user.associated_channel.videos_count -= 1
                parent_user.associated_channel.save(update_fields=["videos_count"])

            video.delete()

            return build_response("Deleted video")
        else:
            return build_response("Video does not exist.")
    except ObjectDoesNotExist:
        return build_response("Video not found.")
    except IntegrityError as e:
        logging.error(f"IntegrityError in delete_video: {e}")
        return build_response("Error deleting video. Please try again.")
    except Exception as e:
        logging.error(f"Unexpected error in delete_video: {e}")
        return build_response("Error deleting video. Please try again.")




def update_video_status(data):
    """Set a video's visibility flags (public, draft, lounge only, scheduled, unlisted). Creator only."""
    try:
        video = get_video(data["video_id"])
        logged_in_user = UserEngine().get_logged_in_user(data["token"])
        if logged_in_user == video.creator.user:
            video.is_active = data["public"]
            video.is_draft = data["draft"]
            video.is_lounge_only = data["lounge-only"]
            video.is_scheduled = data["scheduled"]
            video.is_unlisted = data["unlisted"]
            # NOTE: the channel's video count goes up on every call with public set,
            # including calls for a video that is already public.
            if data["public"]:
                video.creator.associated_channel.videos_count += 1
                video.creator.associated_channel.save()
            if data["scheduled"] and data["scheduled_date"] != "":
                date_string = data["scheduled_date"]
                date_format = "%Y-%m-%d %H:%M"
                try:
                    date_obj = datetime.strptime(date_string, date_format)
                    video.scheduled_date = date_obj
                except ValueError as ve:
                    return build_response(f"Invalid date format: {ve}")
            video.save()
            return build_response("success")
        else:
            return build_response("can't change status: Not Authorized.")
    except Exception as e:
        return build_response(f"can't change status ERROR : {e}.")


def add_comment(
    video_id,
    token,
    comment_string,
    root_comment=None,
):
    """Add a comment to a video, or a reply under a root comment (first version of the comment API)."""
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        logged_in_user = UserEngine().get_user_profile_with_id(logged_in_user.id)
        video_obj = get_video(video_id)

        if root_comment:
            root_comment_obj = get_comment_object(root_comment)
            comment_obj = Comment.objects.create(
                video=video_obj,
                commented_by=logged_in_user,
                comment=comment_string,
                root_comment=root_comment_obj,
                is_reply=True,
            )
            root_comment_obj.replies += 1
            root_comment_obj.save()

        else:
            comment_obj = Comment.objects.create(
                video=video_obj,
                comment=comment_string,
                commented_by=logged_in_user,
            )

        if comment_obj:
            video_obj.comments += 1
            video_obj.save()

    except ObjectDoesNotExist:
        return build_response("Video / Root comment not found")
    except IntegrityError as e:
        return build_response(f"IntegrityError: {e}")
    except Exception as e:
        return build_response(f"Can't set comment. Error: {e}")
    return build_response("success")


def remove_comment(comment_id, token):
    """Delete the logged in user's own comment and recount replies and the video's comments."""
    # NOTE: when the caller does not own the comment nothing is deleted, but the response is still "success".
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        if logged_in_user is None:
            raise Exception("Auth failed in remove comment")

        comment_obj = get_comment_object(comment_id)
        video_obj = comment_obj.video
        if comment_obj.commented_by.user == logged_in_user:
            root_comment = comment_obj.root_comment
            parent_comment = comment_obj.parent_comment
            comment_obj.delete()
            if root_comment is not None:
                root_comment.replies = Comment.objects.filter(root_comment=comment_obj.root_comment).count()
                root_comment.save()

            if parent_comment:
                parent_comment.replies = Comment.objects.filter(parent_comment=comment_obj.parent_comment).count()
                parent_comment.save()

            video_obj.comments = Comment.objects.filter(video=video_obj).count()
            video_obj.save()

    except ObjectDoesNotExist:
        return build_response("Video / Root comment not found")
    except IntegrityError as e:
        return build_response(f"IntegrityError: {e}")
    except Exception as e:
        return build_response(f"Can't set comment. Error: {e}")
    return build_response("success")


def add_comment_v2(video_id, token, comment_string, parent_comment=None):
    """Add a comment or a threaded reply to a video and notify the video creator or the parent's author."""
    logged_in_user = UserEngine().get_logged_in_user(token)
    if logged_in_user is None:
        raise Exception("Auth failed in add commment v2")

    user_profile = UserEngine().get_user_profile(logged_in_user)
    if user_profile:
        video_obj = get_video(video_id)
        comment_obj = Comment()

        comment_obj.comment = comment_string
        comment_obj.commented_by = user_profile
        comment_obj.video = video_obj

        if parent_comment is not None:
            parent_obj = get_comment_object(parent_comment)
            parent_obj.replies += 1
            # NOTE: a reply to a top level comment keeps root_comment empty,
            # because the parent has no root of its own.
            comment_obj.root_comment = parent_obj.root_comment
            comment_obj.parent_comment = parent_obj
            comment_obj.comment_depth = parent_obj.comment_depth + 1
            parent_obj.save()

        comment_obj.save()
        video_obj.comments += 1
        video_obj.save()
        from modules.notifier_engine.manager import notifierAgent

        if parent_comment is not None:
            notifierAgent.register_video_comment_reply_notification(
                replied_to_comment=parent_obj, reply_comment=comment_obj
            )
        else:
            notifierAgent.register_video_comment_created_notification(comment_obj.video.creator, comment_obj)

        return build_response("success")
    else:
        raise Exception("Auth failed in add commment v2")


def render_comment_tree(video_id, page_number, token=None):
    """Page through the replies (depth 3 or less) whose root comment belongs to this video, oldest first."""
    try:
        root_video = get_video(video_id)
        if root_video is None:
            raise Exception("Root Video cannot be none")

        qs = Comment.objects.filter(video=root_video).values("comment_id")
        qs2 = Comment.objects.filter(root_comment__in=qs, comment_depth__lte=3).order_by("creation_date")
        return VideoEngineManager().token_paginator(
            qs2, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
        )

    except Exception as e:
        return build_response(f"Error in rendering comment tree:  {str(e)}")


def get_comment_children(comment, depth, current_depth=1):
    """Collect a comment's direct replies, then follow the first reply downwards until depth is reached."""
    children = Comment.objects.none()

    if current_depth <= depth:
        direct_replies = Comment.objects.filter(parent_comment=comment)

        first_node = direct_replies.first()

        if first_node is not None:
            current_depth = first_node.comment_depth
            children = direct_replies | get_comment_children(first_node, depth, current_depth + 1)

    return children


def fetch_child_posts(post_id, page_number, token=None):
    """Page through the replies below a comment, up to 3 levels down, shallowest first."""
    try:
        parent_obj = get_comment_object(post_id)
        if parent_obj is None:
            raise Exception("Parent not found.")

        max_depth = parent_obj.comment_depth + 3
        child_comments = get_comment_children(parent_obj, max_depth, parent_obj.comment_depth)
        ordered_comments = child_comments.order_by("comment_depth")
        return VideoEngineManager().token_paginator(
            ordered_comments, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
        )
    except Exception as e:
        return build_response(f"error occured while fetching children posts:  {str(e)}")


def fetch_threaded_comments(
    post_id,
    page_number,
    is_root_comment,
    token=None,
):
    """Page through the replies to a comment, most liked first."""
    comment_obj = get_comment_object(post_id)
    if is_root_comment:
        comment_qs = Comment.objects.filter(root_comment=comment_obj).order_by("-likes")
    else:
        comment_qs = Comment.objects.filter(parent_comment=comment_obj).order_by("-likes")

    return VideoEngineManager().token_paginator(
        comment_qs, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
    )


def create_playlist(token, playlist_name, playlist_description):
    """Create a playlist owned by the logged in user."""
    try:
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Authenication Failed")

        user_profile = user_control_obj.get_user_profile(logged_in_user)

        playlist_obj = Playlist()
        playlist_obj.name = playlist_name
        playlist_obj.description = playlist_description
        playlist_obj.created_by = user_profile
        playlist_obj.save()

        return build_response("Playlist successfully created.")

    except Exception as e:
        return build_response(f"Error while creating playlist: {str(e)}")


def modify_playlist(token, playlist_id, playlist_name, playlist_description):
    """Rename a playlist or change its description. Owner only."""
    try:
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(token)

        try:
            playlist_obj = Playlist.objects.get(playlist_id=playlist_id)
            if logged_in_user == playlist_obj.created_by.user:
                playlist_obj.name = playlist_name if playlist_name is not None else playlist_obj.name
                playlist_obj.description = (
                    playlist_description if playlist_description is not None else playlist_obj.description
                )
                playlist_obj.save()
                return build_response("Successfully modified playlist.")
            else:
                raise Exception("Not Authorized")
        except ObjectDoesNotExist:
            return build_response("Error while modifying playlist: Playlist not found.")

    except Exception as e:
        return build_response(f"Error while modifying playlist: {str(e)}")


def delete_playlist(token, playlist_id):
    """Delete a playlist. Owner only."""
    try:
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(token)

        try:
            playlist_obj = Playlist.objects.get(playlist_id=playlist_id)
            if logged_in_user == playlist_obj.created_by.user:
                playlist_obj.delete()
                return build_response("Successfully deleted playlist.")

            else:
                raise Exception("Not Authorized")
        except ObjectDoesNotExist:
            raise Exception("Authorization failed.")

    except Exception as e:
        return build_response(f"Error while deleting playlist: {str(e)}")


def get_all_playlists(token, user_id, page_number):
    """Page through a user's playlists, newest first. Uses user_id when given, otherwise the token's user."""
    if user_id is None and token is None:
        raise Exception("No Valid Parameters")

    if page_number is None or page_number < 1:
        raise Exception("invalid Page number")

    user_control_obj = UserEngine()
    if user_id is not None:
        user = user_control_obj.get_user_profile_with_id(user_id)
    else:
        logged_in_user = user_control_obj.get_logged_in_user(token)
        user = user_control_obj.get_user_profile(logged_in_user)

    playlist_qs = Playlist.objects.filter(created_by=user).order_by("-creation_date")

    return VideoEngineManager().paginator(playlist_qs, page_number, playlist_to_json)


def get_all_playlist_items(playlist_id, page_number):
    """Page through the videos in a playlist in the order they were added."""
    if playlist_id is None:
        raise Exception("Playlist ID can't be null")

    if page_number is None or page_number < 1:
        raise Exception("invalid Page number")

    playlist_obj = Playlist.objects.get(playlist_id=playlist_id)
    playlist_items_qs = PlaylistItem.objects.filter(playlist=playlist_obj).order_by("added_at")
    return VideoEngineManager().paginator(playlist_items_qs, page_number, playlist_item_to_json)


def quick_fetch_playlist(token, video_id):
    """List the logged in user's playlists that already contain a video."""
    if token is None:
        raise Exception("Invalid Token")

    video_obj = get_video(video_id)
    if video_obj is None:
        raise Exception("Video doesn't exists")

    user_control_obj = UserEngine()
    logged_in_user = user_control_obj.get_logged_in_user(token)
    user = user_control_obj.get_user_profile(logged_in_user)

    playlist_qs = Playlist.objects.filter(created_by=user)
    existing_qs = PlaylistItem.objects.filter(playlist__in=playlist_qs, video=video_obj).values("playlist")

    result_qs = Playlist.objects.filter(playlist_id__in=existing_qs)
    return VideoEngineManager().paginator(result_qs, 1, playlist_to_json)


def playlist_to_json(playlist: Playlist):
    """Serialise a playlist, with its video count and the id of its first video ("none" when empty)."""
    try:
        first_video_id = str(PlaylistItem.objects.filter(playlist=playlist).first().video.video_id)
    except AttributeError:
        first_video_id = "none"

    return {
        "playlist_id": str(playlist.playlist_id),
        "name": playlist.name,
        "description": playlist.description,
        "creation_date": str(playlist.creation_date),
        "created_by": UserEngine().to_json(playlist.created_by.user, playlist.created_by),
        "views": playlist.views,
        "first_video": first_video_id,
        "video_count": PlaylistItem.objects.filter(playlist=playlist).count(),
    }


def playlist_item_to_json(item: PlaylistItem):
    """Serialise a playlist item with its video and its playlist."""
    return {
        "video": video_metadata_to_json_obj(item.video),
        "playlist": playlist_to_json(item.playlist),
        "added_at": str(item.added_at),
    }


def add_video_to_playlist(token, video_id, playlist_id):
    """Add a video to a playlist. Playlist owner only."""
    try:
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(token)

        try:
            playlist_obj = Playlist.objects.get(playlist_id=playlist_id)
            if logged_in_user == playlist_obj.created_by.user:
                try:
                    video = get_video(video_id)
                    PlaylistItem.objects.create(playlist=playlist_obj, video=video)
                    return build_response("Successfully added video to playlist.")
                except Exception as e:
                    return build_response(f"Error while adding video to playlist: {str(e)}")

            else:
                return build_response("Error while adding video to playlist: Not authorized.")
        except ObjectDoesNotExist:
            return build_response("Error while adding video to playlist: Playlist not found.")

    except Exception as e:
        return build_response(f"Error while adding video to playlist: {str(e)}")


def remove_video_from_playlist(token, video_id, playlist_id):
    """Remove a video from a playlist. Playlist owner only."""
    try:
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(token)

        try:
            playlist_obj = Playlist.objects.get(playlist_id=playlist_id)
            if logged_in_user == playlist_obj.created_by.user:
                try:
                    video = get_video(video_id)
                    item_obj = PlaylistItem.objects.filter(video=video, playlist=playlist_obj).first()
                    item_obj.delete()
                    return build_response("Successfully remove video from playlist.")
                except Exception as e:
                    return build_response(f"Error while removing video from playlist: {str(e)}")

            else:
                return build_response("Error while removing video from playlist: Not authorized.")
        except ObjectDoesNotExist:
            return build_response("Error while removing video from playlist: Playlist not found.")

    except Exception as e:
        return build_response(f"Error while removing video from playlist: {str(e)}")


def _get_top_videos(
    log_type,
    window_days,
    page_number,
    city,
    country,
    region,
    category_id,
    exclude_short_videos,
    only_short_videos,
    exclude_short_below_seconds=120,
    active_only=True,
):
    """Rank videos by the XP in their metrics logs of one type, inside a time window.

    Candidates are videos with a VideoMetricsLog of log_type dated within the last
    window_days. They can be narrowed to a topic category (a TOPIC_MAP name) and to
    creators located in a city, country or region. The order is the XP of each
    video's highest log in the window, highest first.
    """
    start_date = datetime.now() - timedelta(days=window_days)
    end_date = datetime.now()
    logs = VideoMetricsLog.objects.filter(log_type=log_type, log_date__range=(start_date, end_date)).order_by(
        "-video_xp"
    )
    video_qs = VideoPost.objects.filter(video_id__in=logs.values("video__video_id"))

    if category_id:
        category_tags = VideoEngineManager().TOPIC_MAP[category_id]
        video_qs = video_qs.filter(topic_category_id__in=category_tags)

    if city:
        geo_qs = UserGeolocations.objects.filter(city=city)
    elif country:
        geo_qs = UserGeolocations.objects.filter(country=country)
    elif region:
        geo_qs = UserGeolocations.objects.filter(region=region)
    else:
        geo_qs = None

    if geo_qs is not None:
        user_qs = UserProfile.objects.filter(user__in=geo_qs.values("user__user"))
        video_qs = video_qs.filter(creator__in=user_qs)

    if active_only:
        video_qs = video_qs.filter(is_active=True)

    video_qs = video_qs.annotate(
        video_xpl=Subquery(logs.filter(video__video_id=OuterRef("video_id")).values("video_xp")[:1])
    ).order_by("-video_xpl")

    # A short video is a vertical one (taller than wide) under the duration limit.
    if exclude_short_videos:
        video_qs = video_qs.exclude(
            video_height__gt=F("video_width"), video_duration_seconds__lt=exclude_short_below_seconds
        ).all()
    elif only_short_videos:
        video_qs = video_qs.filter(video_height__gt=F("video_width"), video_duration_seconds__lt=120).all()

    return VideoEngineManager().paginator(video_qs, page_number, video_metadata_to_json_obj)


def get_top_videos_day(page_number, city=None, country=None, region=None, category_id=None, exclude_short_videos = False, only_short_videos = False):
    """Top videos by daily XP logs from the last 2 days."""
    # NOTE: the daily ranking excludes short videos under 60 seconds. The other windows use 120.
    return _get_top_videos(
        LogType.DAY, 2, page_number, city, country, region, category_id, exclude_short_videos, only_short_videos,
        exclude_short_below_seconds=60,
    )


def get_top_videos_week(page_number, city=None, country=None, region=None, category_id=None, exclude_short_videos= False, only_short_videos = False):
    """Top videos by weekly XP logs from the last 9 days."""
    return _get_top_videos(
        LogType.WEEK, 9, page_number, city, country, region, category_id, exclude_short_videos, only_short_videos
    )


def get_top_videos_month(page_number, city=None, country=None, region=None, category_id=None, exclude_short_videos= False, only_short_videos = False):
    """Top videos by monthly XP logs from the last 34 days."""
    return _get_top_videos(
        LogType.MONTH, 34, page_number, city, country, region, category_id, exclude_short_videos, only_short_videos
    )


def get_top_videos_year(page_number, city=None, country=None, region=None, category_id=None, exclude_short_videos= False, only_short_videos = False):
    """Top videos by yearly XP logs from the last 368 days."""
    # NOTE: the yearly ranking is the only one that does not filter on is_active.
    return _get_top_videos(
        LogType.YEAR, 368, page_number, city, country, region, category_id, exclude_short_videos, only_short_videos,
        active_only=False,
    )


def get_watched_videos(page_number, token):
    """Page through the videos the logged in user has watched."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        # NOTE: the last_rewatch ordering is lost in the id lookup below, so the result has no defined order.
        watched_qs = VideoViews.objects.filter(viewed_by=user_profile).order_by("-last_rewatch").values("video")
        video_qs = VideoPost.objects.filter(video_id__in=watched_qs.values("video_id"))
        return VideoEngineManager().paginator(video_qs, page_number, video_metadata_to_json_obj)
    except Exception as e:
        return build_response(f"Error while fetching watched videos: {str(e)}")


def get_subscribed_to_videos(token, page_number,exclude_short_videos=False):
    """Page through active videos from the channels the logged in user subscribes to."""
    if token is None:
        raise Exception("Token cannot be empty")

    logged_in_user = UserEngine().get_logged_in_user(token)
    if not logged_in_user:
        raise Exception("No logged in user found.")

    user_profile = UserEngine().get_user_profile(logged_in_user)
    subscribed_to_qs = ChannelSubscribers.objects.filter(subscribed_by=user_profile).order_by("-creation_date")
    user_qs = UserProfile.objects.filter(user__in=subscribed_to_qs.values("channel__owner__user"))
    video_qs = VideoPost.objects.filter(creator__in=user_qs, is_active=True)

    if exclude_short_videos:
        video_qs = video_qs.exclude(video_height__gt=F("video_width"), video_duration_seconds__lt=120).all()
    return VideoEngineManager().paginator(video_qs, page_number, video_metadata_to_json_obj)


def get_short_videos(token, page_number):
    """Page through active short videos: vertical and under 120 seconds."""
    if token is None:
        raise Exception("Token cannot be empty")

    logged_in_user = UserEngine().get_logged_in_user(token)
    if not logged_in_user:
        raise Exception("No logged in user found.")

    video_qs = VideoPost.objects.filter(
        is_active=True, video_height__gt=F("video_width"), video_duration_seconds__lt=120
    )

    return VideoEngineManager().paginator(video_qs, page_number, video_metadata_to_json_obj)


def render_home_threads(token):
    """Build the threads tab of the home screen: lounges, lounge threads and video threads."""
    if token is None:
        raise Exception("Token cannot be empty")

    logged_in_user = UserEngine().get_logged_in_user(token)
    if not logged_in_user:
        raise Exception("No logged in user found.")

    from modules.lounge_engine.manager import LoungeManager
    top_lounges = LoungeManager().get_top_lounges(1)["data"]
    top_lounge_posts = LoungeManager().get_top_lounge_posts(token=token, page_number=1)["data"]
    top_lounge_user_joined = LoungeManager().get_top_user_joined_lounges(token, 1)["data"]
    top_lounge_posts_user_joined = LoungeManager().get_top_user_joined_lounge_posts(token, 1)["data"]

    x = len(top_lounges)
    y = len(top_lounge_posts)
    z = len(top_lounge_user_joined)
    o = len(top_lounge_posts_user_joined)

    section_data = []
    section_data.append({
        "label": "top_lounges",
        "type": "user_type_2",
        "title": "Best lounges across platform",
        "data": top_lounges[:12] if x > 12 else top_lounges,
    })

    section_data.append({
        "label": "top_lounge_posts_user_joined_full",
        "type": "lounge_threads_full",
        "title": "Top threads from your lounges",
        "data": top_lounge_posts_user_joined[:12] if o > 12 else top_lounge_posts_user_joined,
    })

    top_video_threads = get_top_threads(token=token, page_number=1)["data"]
    a = len(top_video_threads)

    section_data.append({
        "label": "top_video_threads",
        "type": "video_threads",
        "title": "Threads discussing videos",
        "data": top_video_threads[:12] if a > 12 else top_video_threads,
    })

    section_data.append({
        "label": "top_lounges_posts_full",
        "type": "lounge_threads_full",
        "title": "Best threads",
        "data": top_lounge_posts[:14] if y > 14 else top_lounge_posts,
    })

    return build_response(section_data)


def render_videos_home(token):
    """Build the videos tab of the home screen: recommendations, subscriptions, then one row per topic category."""
    if token is None:
        raise Exception("Token cannot be empty")

    logged_in_user = UserEngine().get_logged_in_user(token)
    if not logged_in_user:
        raise Exception("No logged in user found.")

    section_data = []

    section_data.append({
        "label": "top_videos",
        "type": "videos",
        "title": "Best picks for you",
        "data": VideoEngineManager().get_all_videos(token, 1, exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "subscriptions",
        "type": "videos",
        "title": "From your subscriptions",
        "data": get_subscribed_to_videos(token, 1, exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "News",
        "type": "videos",
        "title": "What's happening around the world ",
        "data": get_top_videos_day(page_number=1, category_id="News")["data"],
    })

    section_data.append({
        "label": "gaming",
        "type": "videos",
        "title": "Eat. Sleep. Game. Repeat",
        "data": get_top_videos_day(page_number=1, category_id="Gaming", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "music",
        "type": "videos",
        "title": "Chill out and groove on!",
        "data": get_top_videos_day(page_number=1, category_id="Music", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "food_and_dining",
        "type": "videos",
        "title": "What's cookin?",
        "data": get_top_videos_day(page_number=1, category_id="Food and Dining", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "entertainment",
        "type": "videos",
        "title": "Videos to get you out of boredom",
        "data": get_top_videos_day(page_number=1, category_id="Entertainment", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "science_and_technology",
        "type": "videos",
        "title": "Innovations, Inventions and Technology",
        "data": get_top_videos_day(
            page_number=1, category_id="Science and Technology", exclude_short_videos=True
        )["data"],
    })

    section_data.append({
        "label": "movies",
        "type": "videos",
        "title": "Movies and Web series",
        "data": get_top_videos_day(page_number=1, category_id="Movies", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "people",
        "type": "videos",
        "title": "Discover new people and hear their stories",
        "data": get_top_videos_day(page_number=1, category_id="People", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "sports_and_fitness",
        "type": "videos",
        "title": "To keep you active",
        "data": get_top_videos_day(page_number=1, category_id="Sports and Fitness", exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "travel",
        "type": "videos",
        "title": "Explore new places and moments",
        "data": get_top_videos_day(page_number=1, category_id="Travel", exclude_short_videos=True)["data"],
    })

    return build_response(section_data)


def render_home_v2(token):
    """Build the main home screen as an ordered list of sections.

    Each section has a label, a type the app uses to pick a layout, a title and
    its data: star creators, short videos, recommended videos, lounges, lounge
    threads, subscriptions and two banners.
    """
    if token is None:
        raise Exception("Token cannot be empty")

    logged_in_user = UserEngine().get_logged_in_user(token)
    if not logged_in_user:
        raise Exception("No logged in user found.")

    from modules.lounge_engine.manager import LoungeManager
    top_lounges = LoungeManager().get_top_lounges(1)["data"]
    top_lounge_posts = LoungeManager().get_top_lounge_posts(token=token, page_number=1)["data"]
    top_lounge_user_joined = LoungeManager().get_top_user_joined_lounges(token, 1)["data"]
    top_lounge_posts_user_joined = LoungeManager().get_top_user_joined_lounge_posts(token, 1)["data"]

    x = len(top_lounges)
    y = len(top_lounge_posts)
    z = len(top_lounge_user_joined)
    o = len(top_lounge_posts_user_joined)

    section_data = []

    section_data.append({
        "label": "stars",
        "type": "users",
        "title": "Meet our Limelight Stars",
        "data": UserEngine().get_star_creators(token, page_number=1)["data"],
    })

    section_data.append({
        "label": "short_videos",
        "type": "videos_short",
        "title": "Best short videos",
        "data": get_short_videos(token, 1)["data"],
    })

    section_data.append({
        "label": "top_videos",
        "type": "videos",
        "title": "Best picks for you",
        "data": VideoEngineManager().get_all_videos(token, 1, exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "top_lounges",
        "type": "user_type_2",
        "title": "Top lounges across platform",
        "data": top_lounges[:12] if x > 12 else top_lounges,
    })

    section_data.append({
        "label": "home_survey_banner",
        "type": "half_size_banner",
        "contains_url": True,
        "url": "https://docs.google.com/forms/d/e/1FAIpQLScGOLT6TGyj56ydTF8ABHswjr5waztR0dF2xSJ16DMiidwXqg/viewform",
        "title": "Participate in our survey.",
        "description": "What do you think about the platform now?",
        "CTA_label": "Open survey",
        "color": "ffffff00",
        "use_dark_text": True,
        "background_link": "https://i.ibb.co/kXYGH5M/survey-banner.gif",
    })

    section_data.append({
        "label": "top_lounges_posts",
        "type": "lounge_threads",
        "title": "Top threads from lounges",
        "data": top_lounge_posts[:4] if y > 4 else top_lounge_posts,
    })

    section_data.append({
        "label": "subscriptions",
        "type": "videos",
        "title": "From your subscriptions",
        "data": get_subscribed_to_videos(token, 1, exclude_short_videos=True)["data"],
    })

    section_data.append({
        "label": "top_lounges_user_joined",
        "type": "user_type_2",
        "title": "Top lounges you're part of",
        "data": top_lounge_user_joined[:12] if z > 12 else top_lounge_user_joined,
    })

    section_data.append({
        "label": "top_lounge_posts_user_joined",
        "type": "lounge_threads",
        "title": "Top threads you might like",
        "data": top_lounge_posts_user_joined[:4] if o > 4 else top_lounge_posts_user_joined,
    })

    section_data.append({
        "label": "sept_contest_banner",
        "type": "half_size_banner",
        "contains_url": False,
        "title": "Made for creators. \nBy Creators.",
        "description": "We are just getting started. Check out our cool features like lounges and more.",
        "url": "sept_contest_banner",
        "color": "FFC0CB",
        "use_dark_text": False,
        "background_link": "https://i.giphy.com/xTiTnKWy93eMa6Mhl6.webp",
    })

    return build_response(section_data)


def create_custom_feed(token, data):
    """Create a custom feed for the logged in user from a name, description, topics and creators."""
    if token is None:
        raise Exception("Empty Token")
    logged_in_user = UserEngine().get_logged_in_user(token)

    if not logged_in_user:
        raise Exception("No logged in user.")

    user_profile = UserEngine().get_user_profile(logged_in_user)
    if user_profile:
        feed = CustomFeed()
        feed.feed_title = data["feed_name"]
        feed.feed_description = data["description"]
        feed.is_public = data["is_public"]
        feed.owner = user_profile
        feed.save()

        x = add_topic_to_custom_feed(token, feed.feed_id, data["topics"])["message"]
        y = add_creators_to_custom_feed(token, feed.feed_id, data["creators"])["message"]
        if x == y and x == "success":
            return build_response("success")
        else:
            feed.delete()
            return build_response("Feed has been created but Could'nt add topics / creators to the feed.")
    else:
        raise Exception("User profile error")


def add_topic_to_custom_feed(token, feed_id, topics):
    """Add topic ids to a custom feed. Feed owner only."""
    if token is None:
        raise Exception("Empty Token")
    logged_in_user = UserEngine().get_logged_in_user(token)

    if not logged_in_user:
        raise Exception("No logged in user.")
    user_profile = UserEngine().get_user_profile(logged_in_user)
    feed_obj = get_feed_object(feed_id)

    if not feed_obj:
        raise Exception("Feed does not exists.")

    if feed_obj.owner != user_profile:
        raise Exception("Not Authorised")

    for topic in topics:
        obj = get_feed_topic_object(feed_obj, topic)
        if not obj:
            feed_topic_obj = CustomFeedTopics()
            feed_topic_obj.topic_id = topic
            feed_topic_obj.related_feed = feed_obj
            feed_topic_obj.save()

    feed_obj.total_topics += len(topics)
    feed_obj.save()

    return build_response("success")


def add_creators_to_custom_feed(token, feed_id, users):
    """Add creators, given as user ids, to a custom feed. Feed owner only."""
    if token is None:
        raise Exception("Empty Token")
    logged_in_user = UserEngine().get_logged_in_user(token)

    if not logged_in_user:
        raise Exception("No logged in user.")

    user_profile = UserEngine().get_user_profile(logged_in_user)
    feed_obj = get_feed_object(feed_id)

    if not feed_obj:
        raise Exception("Feed does not exists.")

    if feed_obj.owner != user_profile:
        raise Exception("Not Authorised")

    for user in users:
        obj = get_feed_creator_object(feed_obj, user)
        if not obj:
            feed_creator_obj = CustomFeedCreators()
            feed_creator_obj.creator = UserEngine().get_user_profile_with_id(user)
            feed_creator_obj.related_feed = feed_obj
            feed_creator_obj.save()

    feed_obj.total_creators += len(users)
    feed_obj.save()

    return build_response("success")


def remove_topic_from_custom_feed(token, feed_id, topic_id):
    """Remove one topic from a custom feed. Feed owner only."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        if feed_obj.owner != user_profile:
            raise Exception("Not Authorised")

        feed_topic_obj = get_feed_topic_object(feed_obj, topic_id)

        if not feed_topic_obj:
            raise Exception("Topic does not exist in this feed.")

        feed_obj.total_topics -= 1
        feed_obj.save()

        feed_topic_obj.delete()

        return build_response("removed topic from feed")

    except Exception as e:
        return build_response(f"Error while remove_topic_from_custom_feed: {str(e)}")


def remove_creator_from_custom_feed(token, feed_id, user_id):
    """Remove one creator from a custom feed. Feed owner only."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        if feed_obj.owner != user_profile:
            raise Exception("Not Authorised")

        feed_creator_obj = get_feed_creator_object(feed_obj, user_id)

        if not feed_creator_obj:
            raise Exception("Creator does not exist in this feed.")

        feed_obj.total_creators -= 1
        feed_obj.save()

        feed_creator_obj.delete()

        return build_response("removed creator from feed")

    except Exception as e:
        return build_response(f"Error while remove_creator_from_custom_feed: {str(e)}")


def change_feed_visibility(token, feed_id, status):
    """Make a custom feed public or private. Feed owner only."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        if feed_obj.owner != user_profile:
            raise Exception("Not Authorised")

        feed_obj.is_public = status
        feed_obj.save()
        return build_response("modified feed visibily status")

    except Exception as e:
        return build_response(f"Error while change_feed_visibility: {str(e)}")


def delete_feed(token, feed_id):
    """Delete a custom feed. Feed owner only."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        if feed_obj.owner != user_profile:
            raise Exception("Not Authorised")

        feed_obj.delete()

        return build_response("Feed deleted")
    except Exception as e:
        return build_response(f"Error while delete_feed: {str(e)}")


def log_feed_usage(token, feed_id):
    """Record that the logged in user has started using a custom feed."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        usage = CustomFeedUsage()
        usage.related_feed = feed_obj
        usage.being_used_by = user_profile
        usage.save()

        return build_response("Logged feed usage")
    except Exception as e:
        return build_response(f"Error while log_feed_usage: {str(e)}")


def remove_feed_usage(token, feed_id):
    """Record that the logged in user has stopped using a custom feed."""
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        feed_usage_obj = get_feed_usage_obj(feed_obj, user_profile)

        if not feed_usage_obj:
            raise Exception("usage object does not exists")

        feed_usage_obj.delete()

        return build_response("removed feed usage")

    except Exception as e:
        return build_response(f"Error while remove_feed_usage: {str(e)}")


def set_impressions_to_feed(token, feed_id):
    """Count a view of a custom feed.

    A user's first view adds one to the feed's impressions. Later views add to
    that user's own view count for the feed.
    """
    try:
        if token is None:
            raise Exception("Empty Token")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if not logged_in_user:
            raise Exception("No logged in user.")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        feed_obj = get_feed_object(feed_id)

        if not feed_obj:
            raise Exception("Feed does not exists.")

        feed_impression_obj, status = get_or_create_feed_impression_obj(feed_obj, user_profile)
        if not status:
            feed_impression_obj.views += 1
            feed_impression_obj.save()

        if status:
            feed_obj.feed_impressions += 1
            feed_obj.save()
        return build_response("set impressions to feed")
    except Exception as e:
        return build_response(f"Error while set_impressions_to_feed: {str(e)}")


def get_feed_object(feed_id):
    """Return the custom feed with this id, or None."""
    try:
        return CustomFeed.objects.filter(feed_id=feed_id).first()
    except Exception as e:
        return build_response(f"Error while get_feed_object: {str(e)}")


def get_feed_topic_object(feed_obj, topic_id):
    """Return the row linking a topic to a feed, or None."""
    try:
        return CustomFeedTopics.objects.filter(related_feed=feed_obj, topic_id=topic_id).first()
    except Exception as e:
        return build_response(f"Error while get_feed_topic_object: {str(e)}")


def get_feed_creator_object(feed_obj, creator):
    """Return the row linking a creator to a feed, or None."""
    try:
        return CustomFeedCreators.objects.filter(related_feed=feed_obj, creator=creator).first()
    except Exception as e:
        return build_response(f"Error while get_feed_creator_object: {str(e)}")


def get_feed_usage_obj(feed_obj, being_used_by):
    """Return the row recording that a user uses a feed, or None."""
    try:
        return CustomFeedUsage.objects.filter(related_feed=feed_obj, being_used_by=being_used_by).first()
    except Exception as e:
        return build_response(f"Error while get_feed_creator_object: {str(e)}")


def get_or_create_feed_impression_obj(feed_obj, viewed_by):
    """Return (impression row, created) for a user and a feed."""
    try:
        return CustomFeedImpressions.objects.get_or_create(related_feed=feed_obj, viewed_by=viewed_by)
    except Exception as e:
        return build_response(f"Error while get_feed_impression_obj: {str(e)}")


def report_video(token, video_id, reason):
    """File a report against a video on behalf of the logged in user."""
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        logged_in_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        video_obj = get_video(video_id)

        reported_obj = ReportedVideos()
        reported_obj.video = video_obj
        reported_obj.reason = reason
        reported_obj.reported_by = logged_in_profile

        reported_obj.save()
        return build_response("success")
    except Exception as e:
        return build_response(f"Error while reporting video: {str(e)}")


def report_comment(token, comment_id, reason):
    """File a report against a comment on behalf of the logged in user."""
    try:
        logged_in_user = UserEngine().get_logged_in_user(token)
        logged_in_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        comment_obj = get_comment_object(comment_id)

        reported_obj = ReportedComment()
        reported_obj.comment = comment_obj
        reported_obj.reason = reason
        reported_obj.reported_by = logged_in_profile

        reported_obj.save()
        return build_response("success")
    except Exception as e:
        return build_response(f"Error while reporting comment: {str(e)}")


class VideoEngineManager:
    """Uploads, drafts, listings, search, the recommended feed and the paginators."""

    def __meta__(self):
        self.VERSION = 1
        self.MAX_OBJECT_LIMIT = 14
        self.BUILD = "LEGACY"

        # Home screen category name -> the topic_category_id values stored on videos.
        self.TOPIC_MAP = {
            "News": [1, 12],
            "Gaming": [9],
            "Music": [11],
            "Food and Dining": [8],
            "Entertainment": [0, 14, 5],
            "Education": [10],
            "Science and Technology": [15],
            "Movies": [6],
            "People": [2, 4, 13, 18],
            "Sports and Fitness": [16, 7],
            "Travel": [17, 3],
        }

    def __init__(self):
        """Set the version, the page size and the topic map."""
        self.__meta__()

    def save_video_draft_alternate(self, video, auth_key):
        """Create a draft video from an uploaded file object."""
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(auth_key)

        video_post = VideoPost()
        video_post.video_file = video
        video_post.video_file_original_name = str(timezone.now())
        video_post.title = "Newly uploaded video"
        video_post.creator = user_control_obj.get_user_profile(logged_in_user)
        video_post.save()
        return self.video_metadata_to_json(video_id=video_post.video_id)

    def save_video_draft(self, tmp_file_name, auth_key):
        """Create a draft video from a file already uploaded to the tmp folder."""
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(auth_key)

        video_post = VideoPost()
        with read_tmp_file(file_name=tmp_file_name) as f:
            video_post.video_file = File(f, name=os.path.basename(tmp_file_name))
            video_post.video_file_original_name = tmp_file_name
            video_post.title = tmp_file_name
            video_post.creator = user_control_obj.get_user_profile(logged_in_user)
            video_post.save()
        return self.video_metadata_to_json(video_id=video_post.video_id)

    def save_draft_part_I(self, data):
        """Save a draft's title, description, flags and thumbnail. Creator only."""
        user_control_obj = UserEngine()
        logged_in_user = user_control_obj.get_logged_in_user(data["token"])
        video_post = get_video(data["video_id"])
        if video_post.creator.user == logged_in_user:
            video_post.title = data["title"]
            video_post.video_description = data["description"]

            # Music is the only category set from the upload form.
            if data["topic"] == "Music":
                video_post.topic_category_id = self.TOPIC_MAP[data["topic"]][0]

            video_post.contains_paid_promotion = decode_bool(data["paid_promotion"])
            video_post.is_age_restricted = decode_bool(data["age_restriction"])

            thumbnail = os.path.join(
                settings.MEDIA_ROOT, "videos", "".join(str(video_post.video_id).split("-")), "thumbnail.jpeg"
            )
            if "thumbnail" in data and os.path.exists(thumbnail):
                os.remove(thumbnail)

            video_post.thumbnail = (
                data["thumbnail"]
                if "thumbnail" in data and data["thumbnail"] is not None
                else video_post.thumbnail
            )
            video_post.save()
            return build_response("success")

    def get_like_object(self, video_id, user_id):
        """Return the user's like on a video, or None."""
        return Likes.objects.filter(video=video_id, liked_by__user__id=user_id).first()

    def get_dislike_object(self, video_id, user_id):
        """Return the user's dislike on a video, or None."""
        return DisLikes.objects.filter(video=video_id, disliked_by__user__id=user_id).first()

    def get_comment_like_object(self, comment_id, user_id):
        """Return the user's like on a comment, or None."""
        return CommentLikes.objects.filter(comment_id=comment_id, liked_by__user__id=user_id).first()

    def get_comment_dislike_object(self, comment_id, user_id):
        """Return the user's dislike on a comment, or None."""
        return CommentDisLikes.objects.filter(comment_id=comment_id, disliked_by__user__id=user_id).first()

    def get_user_videos(self, token, page_number, filter_kwargs):
        """Page through the logged in user's own videos matching filter_kwargs, newest first."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            if logged_in_user is not None:
                video_qs = VideoPost.objects.filter(creator__user=logged_in_user, **filter_kwargs).order_by(
                    "-creation_date"
                )
                return self.paginator(video_qs, page_number, video_metadata_to_json_obj)
            else:
                return build_response("Not authenticated.")
        except Exception as e:
            return build_response(f"Error fetching videos: {str(e)}")

    def get_user_videos_id(self, id, page_number, token):
        """Page through a user's videos, newest first. Other users only see the active ones."""
        try:
            user = UserEngine().get_user_profile_with_id(id)
            if user is not None:
                # NOTE: without a token video_qs is never set, and the except below returns an error response.
                if token:
                    logged_in_user = UserEngine().get_logged_in_user(token)
                    if logged_in_user == user.user:
                        video_qs = VideoPost.objects.filter(creator=user).order_by("-creation_date")
                    else:
                        video_qs = VideoPost.objects.filter(creator=user, is_active=True).order_by("-creation_date")

                return self.paginator(video_qs, page_number, video_metadata_to_json_obj)
            else:
                return build_response("Not authenticated.")
        except Exception as e:
            return build_response(f"Error fetching videos: {str(e)}")

    def search_videos(self, query, page_number):
        """Page through active videos whose title, description or transcript contains the query."""
        first_qs = VideoPost.objects.filter(title__icontains=query).all()
        second_qs = VideoPost.objects.filter(video_description__icontains=query).all()
        third_qs = VideoPost.objects.filter(transcript__icontains=query).all()

        video_qs = first_qs | second_qs | third_qs
        video_qs = video_qs.filter(is_active=True)
        return self.paginator(video_qs, page_number, video_metadata_to_json_obj)

    def search_comments(self, query, page_number, token):
        """Page through comments whose text contains the query."""
        first_qs = Comment.objects.filter(comment__icontains=query)
        return VideoEngineManager().token_paginator(
            first_qs, page_number, VideoEngineManager().comment_metadata_to_json_obj, token
        )

    def get_all_drafts(self, token, page_number):
        """Page through the logged in user's drafts."""
        return self.get_user_videos(token, page_number, {"is_draft": True})

    def get_all_unlisted(self, token, page_number):
        """Page through the logged in user's unlisted videos."""
        return self.get_user_videos(token, page_number, {"is_unlisted": True})

    def get_lounge_only(self, token, page_number):
        """Page through the logged in user's lounge only videos."""
        return self.get_user_videos(token, page_number, {"is_lounge_only": True})

    def get_creator_videos(self, token, page_number):
        """Page through all of the logged in user's videos."""
        return self.get_user_videos(token, page_number, {})

    def get_scheduled_videos(self, token, page_number):
        """Page through the logged in user's scheduled videos."""
        return self.get_user_videos(token, page_number, {"is_scheduled": True})

    def get_all_videos(self,token, page_number, exclude_short_videos=False, only_short_videos=False):
        """The recommended feed ("Best picks for you").

        Active videos the user has not watched come first, highest video XP first.
        Videos the user has already watched follow, also highest XP first.
        """
        if token is None:
            raise Exception("token invalid")
        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("No logged in user")

        user_profile = UserEngine().get_user_profile(logged_in_user)
        viewed_qs = VideoViews.objects.filter(viewed_by = user_profile).all()
        main_qs = VideoPost.objects.filter(is_active=True).exclude(video_id__in = viewed_qs.values('video__video_id'))
        # NOTE: the watched list is not filtered on is_active, so a watched video
        # that was later made a draft or unlisted still appears at the end.
        qs_2 = VideoPost.objects.filter(video_id__in = viewed_qs.values("video__video_id"))

        main_qs_ordered = main_qs.order_by('-video_xp')
        qs_2_ordered = qs_2.order_by('-video_xp')

        if exclude_short_videos:
            qs_2_ordered = qs_2_ordered.exclude(video_height__gt=F('video_width'),
                                            video_duration_seconds__lt=120).all()

            main_qs_ordered = main_qs_ordered.exclude(video_height__gt=F('video_width'),
                            video_duration_seconds__lt=120).all()
        elif only_short_videos:
            qs_2_ordered = qs_2_ordered.filter(video_height__gt=F('video_width'),
                                            video_duration_seconds__lt=120).all()
            main_qs_ordered = main_qs_ordered.filter(video_height__gt=F('video_width'),
                            video_duration_seconds__lt=120).all()

        result_qs = list(chain(main_qs_ordered, qs_2_ordered))
        return self.paginator(
            result_qs,
            page_number,
            video_metadata_to_json_obj,
        )

    def video_metadata_to_json(self, video_id):
        """Serialise the video with this id."""
        video = get_video(video_id)
        return video_metadata_to_json_obj(video)

    def get_top_two_commentors(self, comment):
        """Return the two most liked direct replies to a comment."""
        comment_qs = Comment.objects.filter(parent_comment=comment).order_by("-likes")[:2]
        return comment_qs

    def comment_metadata_to_json_obj(self, comment, token):
        """Serialise a comment. With a token, add the top repliers and the caller's reaction state."""
        m = comment_to_dict(comment)
        if token:
            logged_in_user = UserEngine().get_logged_in_user(token)
            temp = [comment_to_dict(i)["commented_by"] for i in self.get_top_two_commentors(comment)]

            m["top_comments_by"] = list({v["user_id"]: v for v in temp}.values())
            m["reaction_status"] = {
                "like": self.get_comment_like_object(comment.comment_id, logged_in_user.id) is not None,
                "dislike": self.get_comment_dislike_object(comment.comment_id, logged_in_user.id) is not None,
                "total_likes": CommentLikes.objects.filter(comment_id=comment.comment_id).count(),
                "total_dislikes": CommentDisLikes.objects.filter(comment_id=comment.comment_id).count(),
            }
        return m

    def paginator(self, query_set, page_number, serializer):
        """Return one page of a query set, MAX_OBJECT_LIMIT items long, serialised with serializer(obj).

        A page number past the end returns status -131.
        """
        pagination_obj = Paginator(query_set, self.MAX_OBJECT_LIMIT)
        total_pages = pagination_obj.page_range[-1]
        if page_number > total_pages:
            return {"status": -131, "message": f"Page number does not exists. (total pages available : {total_pages})"}
        response = {
            "page_number": page_number,
            "total_pages": total_pages,
            "data": [serializer(obj) for obj in pagination_obj.get_page(page_number)],
        }

        return response

    def token_paginator(
        self,
        query_set,
        page_number,
        serialiser,
        token=None,
    ):
        """Same as paginator, but the serialiser is called as serialiser(obj, token)."""
        pagination_obj = Paginator(query_set, self.MAX_OBJECT_LIMIT)
        total_pages = pagination_obj.page_range[-1]
        if page_number > total_pages:
            return {"status": -131, "message": f"Page number does not exists. (total pages available : {total_pages})"}
        response = {
            "page_number": page_number,
            "total_pages": total_pages,
            "data": [serialiser(obj, token) for obj in pagination_obj.get_page(page_number)],
        }

        return response
