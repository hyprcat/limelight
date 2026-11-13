from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from modules.api import error_response, json_endpoint, make_response, redirect_to_cdn
from modules.lounge_engine.manager import LoungeManager
from modules.lounge_engine.models import LoungeDislike, LoungeLike
from modules.user_engine.manager import UserEngine


def endpoint(*required):
    """Lounge endpoints carry the session token in the body, next to the other fields."""
    return json_endpoint(*required, header_token=False)


# Lounge layout: categories hold sections, sections hold posts
# ------------------------------------------------------------------------------


@endpoint("token")
def create_category(data):
    """Create a category in the logged-in creator's lounge."""
    return LoungeManager().create_category(data["token"], data)


@endpoint("token")
def modify_category(data):
    """Change a category."""
    return LoungeManager().modify_category(data["token"], data)


@endpoint("token")
def delete_category(data):
    """Delete a category."""
    return LoungeManager().delete_category(data["token"], data)


@endpoint("token")
def create_section(data):
    """Create a section inside a category."""
    return LoungeManager().create_section(data["token"], data)


@endpoint("token")
def modify_section(data):
    """Change a section."""
    return LoungeManager().modify_section(data["token"], data)


@endpoint("token")
def delete_section(data):
    """Delete a section."""
    return LoungeManager().delete_section(data["token"], data)


@endpoint("token")
def modify_lounge_details(data):
    """Change the logged-in creator's lounge details."""
    return LoungeManager().modify_lounge_details(data["token"], data)


@endpoint()
def change_lounge_visibility(data):
    """Switch the logged-in creator's lounge between public and private."""
    return LoungeManager().change_lounge_visibility(data.get("token"))


@endpoint("user_id")
def fetch_available_categories(data):
    """List the categories of a user's lounge."""
    return LoungeManager().available_categories(data["user_id"])


@endpoint("user_id", "token")
def render_lounge(data):
    """Return a user's lounge as the logged-in user is allowed to see it."""
    return LoungeManager().render_lounge(data["user_id"], data["token"])


# Membership
# ------------------------------------------------------------------------------


@endpoint("page_number")
def get_user_invites(data):
    """List the lounge invites waiting for the logged-in user."""
    return LoungeManager().fetch_lounge_invites(data.get("token"), data["page_number"])


@endpoint()
def accept_lounge_invite(data):
    """Accept an invite to a lounge."""
    return LoungeManager().accept_lounge_request(data.get("lounge_id"), data.get("token"))


@endpoint()
def deny_lounge_invite(data):
    """Decline an invite to a lounge."""
    return LoungeManager().deny_lounge_request(data.get("lounge_id"), data.get("token"))


@endpoint("lounge_id", "token")
def leave_lounge(data):
    """Leave a lounge."""
    return LoungeManager().leave_lounge(data["lounge_id"], data["token"])


# Posts
# ------------------------------------------------------------------------------


@csrf_exempt
@require_POST
def create_lounge_post(request):
    """Post in a section, or reply to a post. Multipart, with an optional `attachment` image."""
    data = {
        "token": request.POST.get("token"),
        "text": request.POST.get("text"),
        "parent_post_id": request.POST.get("parent_post_id"),
        "section_id": request.POST.get("section_id"),
    }
    if "attachment" in request.FILES:
        data["attachment"] = request.FILES["attachment"]
    return make_response(LoungeManager().create_lounge_post(data["token"], data))


@endpoint("post_id", "token")
def remove_post(data):
    """Delete one of the logged-in user's posts."""
    return LoungeManager().delete_lounge_post(data["token"], data["post_id"])


def get_media_url(_, post_id):
    """Redirect to a post's image attachment on the CDN."""
    return redirect_to_cdn(f"media/lounge_posts/{post_id}/media.jpg")


@endpoint("section_id", "page_number")
def fetch_section_posts(data):
    """List the posts in a section."""
    return LoungeManager().fetch_section_posts(data["section_id"], data["page_number"], data.get("token"))


@endpoint("post_id", "page_number")
def fetch_child_posts(data):
    """List the direct replies to a post."""
    return LoungeManager().fetch_child_posts(data["post_id"], data["page_number"], data.get("token"))


@endpoint("post_id", "page_number")
def fetch_total_posts(data):
    """List every reply under a post."""
    return LoungeManager().get_total_comments(data["post_id"], data["page_number"], data.get("token"))


@json_endpoint("post_id", "page_number", "is_root_comment", "token", header_token=False, as_text=True)
def fetch_threaded_comments_view(data):
    """List a thread of posts with their nested replies."""
    return LoungeManager().fetch_threaded_comments(
        data["post_id"], data["page_number"], data["is_root_comment"], data["token"]
    )


@endpoint()
def set_post_impression(data):
    """Record that a post was shown to the logged-in user."""
    return LoungeManager().set_lounge_post_impression(data.get("post_id"), data.get("token"))


@endpoint("post_id", "reason", "token")
def report_comment_view(data):
    """Report a post to the moderators."""
    return LoungeManager().report_post(data["token"], data["post_id"], data["reason"])


# Post reactions
# ------------------------------------------------------------------------------


@endpoint("post_id", "token")
def like_post_view(data):
    """Like a post."""
    return LoungeManager().set_like(data["post_id"], data["token"])


@endpoint("post_id", "token")
def dislike_post_view(data):
    """Dislike a post."""
    return LoungeManager().set_dislike(data["post_id"], data["token"])


@endpoint("post_id", "token")
def remove_like(data):
    """Remove the logged-in user's like from a post."""
    return LoungeManager().remove_like(data["post_id"], data["token"])


@endpoint("post_id", "token")
def remove_dislike(data):
    """Remove the logged-in user's dislike from a post."""
    return LoungeManager().remove_dislike(data["post_id"], data["token"])


@endpoint("post_id", "token")
def fetch_post_reaction_status(data):
    """Return the like and dislike counts of a post and the logged-in user's own reaction."""
    logged_in_user = UserEngine().get_logged_in_user(data["token"])
    if logged_in_user is None:
        return error_response("Invalid Login credentials", 401)
    post = LoungeManager().get_lounge_post_obj(data["post_id"])
    if post is None:
        return error_response("Post not found", 404)
    participant = LoungeManager().get_lounge_participant_obj(
        user_profile=UserEngine().get_user_profile(logged_in_user), lounge=post.associated_lounge_section.lounge
    )
    return {
        "like": LoungeManager().get_post_like_obj(post, participant) is not None,
        "dislike": LoungeManager().get_post_dislike_obj(post, participant) is not None,
        "total_likes": LoungeLike.objects.filter(post=post).count(),
        "total_dislikes": LoungeDislike.objects.filter(post=post).count(),
    }


# Discovery and search
# ------------------------------------------------------------------------------


@endpoint()
def render_lounge_home(data):
    """Build the lounges home screen."""
    return LoungeManager().render_lounge_home(data.get("token"))


@endpoint("page_number")
def get_top_lounges(data):
    """List the top lounges."""
    return LoungeManager().get_top_lounges(data["page_number"])


@endpoint("page_number")
def get_top_lounge_posts(data):
    """List the top posts across lounges."""
    return LoungeManager().get_top_lounge_posts(data["page_number"], data.get("token"))


@endpoint("page_number")
def get_top_user_joined_lounges(data):
    """List the top lounges the logged-in user has joined."""
    return LoungeManager().get_top_user_joined_lounges(data.get("token"), data["page_number"])


@endpoint("page_number")
def get_top_user_joined_lounge_posts(data):
    """List the top posts from the lounges the logged-in user has joined."""
    return LoungeManager().get_top_user_joined_lounge_posts(data.get("token"), data["page_number"])


@endpoint("query", "page_number", "token")
def search_users(data):
    """Search users."""
    return LoungeManager().search_users(data["query"], data["page_number"], data["token"])


@json_endpoint("query", "page_number", "token", header_token=False, as_text=True)
def fetch_search_posts(data):
    """Search lounge posts."""
    return LoungeManager().search_lounge_posts(data["query"], data["page_number"], data["token"])
