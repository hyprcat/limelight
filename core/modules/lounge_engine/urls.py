from django.urls import path

from modules.lounge_engine import views

category = [
    path("create_category", views.create_category, name="create_category"),
    path("modify_category", views.modify_category, name="modify_category"),
    path("delete_category", views.delete_category, name="delete_category"),
]

section = [
    path("create_section", views.create_section, name="create_section"),
    path("modify_section", views.modify_section, name="modify_section"),
    path("delete_section", views.delete_section, name="delete_section"),
]

fundamentals = [
    path("render_lounge", views.render_lounge, name="render_lounge"),
    path("fetch_available_categories", views.fetch_available_categories, name="fetch_available_categories"),
    path("fetch_section_posts", views.fetch_section_posts, name="fetch_section_posts"),
    path("fetch_child_posts", views.fetch_child_posts, name="fetch_child_posts"),
    path("fetch_total_posts", views.fetch_total_posts, name="fetch_total_posts"),
    path("get_media_url/<str:post_id>", views.get_media_url, name="get_media_url"),
    path("get_user_invites", views.get_user_invites, name="get_user_invites"),
    path("modify_lounge_details", views.modify_lounge_details, name="modify_lounge_details"),
]

posts = [
    path("like_post_view", views.like_post_view, name="like_post_view"),
    path("dislike_post_view", views.dislike_post_view, name="dislike_post_view"),
    path("remove_like", views.remove_like, name="remove_like"),
    path("remove_dislike", views.remove_dislike, name="remove_dislike"),
    path("create_lounge_post", views.create_lounge_post, name="create_lounge_post"),
    path("remove_post", views.remove_post, name="remove_post"),
    path("fetch_post_reaction_status", views.fetch_post_reaction_status, name="fetch_post_reaction_status"),
    path("fetch_threaded_comments_view", views.fetch_threaded_comments_view, name="fetch_threaded_comments_view"),
    path("change_lounge_visibility", views.change_lounge_visibility, name="change_lounge_visibility"),
    path("accept_lounge_invite", views.accept_lounge_invite, name="accept_lounge_invite"),
    path("deny_lounge_invite", views.deny_lounge_invite, name="deny_lounge_invite"),
    path("report_comment_view", views.report_comment_view, name="report_comment_view"),
    path("set_post_impression", views.set_post_impression, name="set_post_impression"),
    path("leave_lounge", views.leave_lounge, name="leave_lounge"),
]

main = [
    path("get_top_lounges", views.get_top_lounges, name="get_top_lounges"),
    path("get_top_lounge_posts", views.get_top_lounge_posts, name="get_top_lounge_posts"),
    path("get_top_user_joined_lounges", views.get_top_user_joined_lounges, name="get_top_user_joined_lounges"),
    path(
        "get_top_user_joined_lounge_posts",
        views.get_top_user_joined_lounge_posts,
        name="get_top_user_joined_lounge_posts",
    ),
    path("render_lounge_home", views.render_lounge_home, name="render_lounge_home"),
]

search = [
    path("search_users", views.search_users, name="search_users"),
    path("fetch_search_posts", views.fetch_search_posts, name="fetch_search_posts"),
]

urlpatterns = category + section + fundamentals + posts + main + search
