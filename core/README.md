# LimeLight Core

The API server of LimeLight Social, a video platform for creators. The mobile app and the creator studio talk to this service. It holds accounts, channels, videos, comments, playlists, lounges (a creator's community space), notifications and the analytics that rank all of them.

This is code from 2023 and 2024, published as it was. It last ran in production in October 2024 and is not maintained. It was tidied for reading before publication: dead code removed, files renamed, comments added. That pass was not tested, so expect to fix things if you try to run it. Known holes are marked in the code with `NOTE:` comments.

## What is in here

Django 4.2 on Postgres, with Celery and Redis for background work, S3 and CloudFront for media, SendGrid for email, Firebase for push notifications and Google sign-in, and django-unfold for the admin. The project started from the cookiecutter-django template, which is where `config/`, `compose/` and `limelight_core/` come from.

```
config/                 settings, root urls, Celery app
limelight_core/         template leftovers: the User model, allauth adapters, templates, static files
modules/
  api.py                the endpoint decorator and response helpers every view uses
  s3.py                 the S3 client and CDN URL helper
  user_engine/          accounts, profiles, channels, subscriptions, blocks, lounge membership models
  video_engine/         videos, uploads, comments, reactions, playlists, feeds, search
  lounge_engine/        lounge categories, sections, posts, invites
  notifier_engine/      in-app notifications and push delivery
  analytics_engine/     XP, levels, metric logs, the admin dashboard
compose/, docker-compose-*.yml, appspec.yml, scripts/    deployment
```

Each engine has the same shape. `views.py` parses the request and calls `manager.py`, which holds the logic and builds the reply. `models.py` holds the tables, `tasks.py` the Celery tasks, `urls.py` the routes.

## How requests work

Almost every endpoint is a POST with a JSON body. `modules/api.py` has the decorator (`json_endpoint`) that checks the method, parses the body, returns 400 when a required field is missing, and passes the handler a dict.

Authentication is a DRF token (`rest_framework.authtoken`). Newer endpoints read it from the `Authorization` header, as the bare key with no `Token ` prefix. Older endpoints read it from a `token` field in the body. The Auth column below says which. Some list endpoints accept a missing token and return the logged-out view.

Replies are JSON objects built by the managers. Most carry `status` and `message` in the body, and many errors are reported there with an HTTP 200. Some endpoints send their JSON with a `text/html` content type because the mobile client decodes those as text. Both habits were kept so the client in `../app` still matches.

Login, logout, registration and password change come from dj-rest-auth under `/user_engine/` (see `config/urls.py`). The engine's own account routes are under `/user_eng/`.

## Endpoints

The four engines have 146 routes. Count them with `grep -c "views\." modules/*/urls.py`.

### Accounts and channels: `modules/user_engine/urls.py`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| POST | `/user_eng/subscribe_channel` | Subscribe the logged-in user to a channel. | token in header |
| POST | `/user_eng/unsubscribe_channel` | Unsubscribe the logged-in user from a channel. | token in header |
| POST | `/user_eng/subscription_status` | Return whether a user is subscribed to a channel. | none |
| POST | `/user_eng/update_channel_details` | Update the logged-in user's channel details. | token in header |
| POST | `/user_eng/update_profile_details` | Update the logged-in user's profile fields. | token in header |
| POST | `/user_eng/create_user` | Create an account with a username, email and password. | none |
| POST | `/user_eng/create_user_profile` | Create or update the logged-in user's profile. Multipart, with an optional `media` picture. | token in header |
| POST | `/user_eng/get_logged_in_user` | Return the account and profile that a session token belongs to. | token in body |
| GET | `/user_eng/get_media_url/<str:user_name>` | Stream a user's profile picture from S3. | none |
| GET | `/user_eng/get_banner/<str:user_name>` | Redirect to a user's profile banner on the CDN. | none |
| POST | `/user_eng/validate_google_id_token` | Log in, or sign up, with a Firebase ID token from Google sign-in. | identity token in body |
| POST | `/user_eng/validate_apple_id_token` | Log in, or sign up, with an identity token from Sign in with Apple. | identity token in body |
| POST | `/user_eng/apple_callback` | Hand Apple's web sign-in callback back to the Android app through an intent URL. | none |
| POST | `/user_eng/update_geo_location` | Store the location the client reports for the logged-in user. | token in header |
| POST | `/user_eng/get_user_info` | Return another user's public profile, with block and subscription state for the caller. | token in header |
| POST | `/user_eng/start_reset_pipeline` | Email a one-time code to start a password reset. | none |
| POST | `/user_eng/verify_otp` | Check the one-time code from the reset email. | none |
| POST | `/user_eng/reset_password` | Set a new password once the one-time code has been verified. | none |
| POST | `/user_eng/update_profile_picture` | Replace the logged-in user's profile picture. Multipart, file field `media`. | token in header |
| POST | `/user_eng/update_profile_banner` | Replace the logged-in user's profile banner. Multipart, file field `media`. | token in header |
| POST | `/user_eng/delete_user_profile_picture` | Remove the logged-in user's profile picture. | token in header |
| POST | `/user_eng/delete_user_profile_banner` | Remove the logged-in user's profile banner. | token in header |
| POST | `/user_eng/recheck_token` | Check that the session token is still valid. | token in header |
| POST | `/user_eng/get_september_contest_details` | Return the September creator contest details for the logged-in user. | token in header |
| POST | `/user_eng/check_ban` | Return whether a user is banned. | none |
| POST | `/user_eng/get_star_creators` | List the creators picked as LimeLight Stars. | token in header |
| POST | `/user_eng/get_top_users_day_view` | List the top creators of the day. | token in header |
| POST | `/user_eng/get_top_users_week_view` | List the top creators of the week. | token in header |
| POST | `/user_eng/get_top_users_month_view` | List the top creators of the month. | token in header |
| POST | `/user_eng/get_subscribed_to_api` | List the channels the logged-in user is subscribed to. | token in header |
| POST | `/user_eng/check_block` | Return whether the logged-in user has blocked a user. | token in header |
| POST | `/user_eng/unblock_user` | Remove a block the logged-in user placed. | token in header |
| POST | `/user_eng/block_user` | Block a user for the logged-in user. | token in header |
| POST | `/user_eng/report_user` | Report a user to the moderators. | token in header |
| POST | `/user_eng/get_blocked_users` | List the users the logged-in user has blocked. | token in header |
| POST | `/user_eng/check_user_account_removal_request` | Return whether the logged-in user has a pending account deletion request. | token in header |
| POST | `/user_eng/add_user_account_removal_request` | Ask for the logged-in user's account to be deleted. | token in header |

### Videos: `modules/video_engine/urls.py`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| GET | `/video_engine/get_thumbnail/<str:video_id>` | Redirect to a video's thumbnail on the CDN. | none |
| POST | `/video_engine/upload_video_DRAFT` | Append one chunk of a video upload to its file in the temporary input folder. | token in header |
| GET | `/video_engine/stream/<str:video_id>/<str:resolution>/<str:file>` | Serve one HLS playlist or segment of a transcoded video from S3. | none |
| GET | `/video_engine/stream_original_video/<str:video_id>` | Redirect to the uploaded source file of a video on the CDN. | none |
| POST | `/video_engine/save_video_draft` | Create a draft video from a file already uploaded through upload_video_DRAFT. | token in body |
| POST | `/video_engine/save_video_draft_I` | Save a draft's title, description, flags, topic and optional thumbnail. Multipart. | token in header |
| POST | `/video_engine/save_thumbnail` | Replace a video's thumbnail. Multipart, fields `id` and `media`. | none |
| POST | `/video_engine/fetch_all_drafts` | List the logged-in creator's drafts. | token in header |
| POST | `/video_engine/fetch_unlisted` | List the logged-in creator's unlisted videos. | token in header |
| POST | `/video_engine/fetch_lounge_only` | List the logged-in creator's lounge-only videos. | token in header |
| POST | `/video_engine/fetch_all_videos` | List all of the logged-in creator's videos. | token in header |
| POST | `/video_engine/fetch_scheduled_videos` | List the logged-in creator's scheduled videos. | token in header |
| POST | `/video_engine/fetch_subscribed_to_videos` | List videos from the channels the logged-in user is subscribed to. | token in header |
| POST | `/video_engine/update_video_status` | Change a video between public, draft, lounge-only, scheduled and unlisted. | token in body |
| POST | `/video_engine/delete_video` | Delete one of the logged-in user's videos. | token in header |
| POST | `/video_engine/fetch_videos` | Page through the recommended videos, optionally only or without short videos. | token in header |
| POST | `/video_engine/fetch_creator_videos` | List a creator's public videos. | token in header |
| POST | `/video_engine/get_video_info` | Return a video's metadata. | none |
| POST | `/video_engine/fetch_video_comments` | List a video's comments, or the replies under a root comment. | token in header |
| POST | `/video_engine/fetch_children_comments` | List the direct replies to a comment. | token in header |
| POST | `/video_engine/render_video_comment_tree` | Return a video's comments as a tree. | token in header |
| POST | `/video_engine/report_video` | Report a video to the moderators. | token in header |
| POST | `/video_engine/report_comment` | Report a comment to the moderators. | token in header |
| POST | `/video_engine/render_home_v2_api` | Build the home screen for the logged-in user. | token in header |
| POST | `/video_engine/render_video_home` | Build the videos tab of the home screen. | token in header |
| POST | `/video_engine/render_threads_home` | Build the threads tab of the home screen. | token in header |
| POST | `/video_engine/set_impression` | Record that a video was shown to the logged-in user. | token in header |
| POST | `/video_engine/set_view` | Record a view of a video, with the watch details the client sends. | token in header |
| POST | `/video_engine/like_video_view` | Like a video. | token in body |
| POST | `/video_engine/dislike_video_view` | Dislike a video. | token in body |
| POST | `/video_engine/like_comment_view` | Like a comment. | token in body |
| POST | `/video_engine/dislike_comment_view` | Dislike a comment. | token in body |
| POST | `/video_engine/remove_like_video_view` | Remove the logged-in user's like from a video. | token in body |
| POST | `/video_engine/remove_dislike_video_view` | Remove the logged-in user's dislike from a video. | token in body |
| POST | `/video_engine/remove_like_comment_view` | Remove the logged-in user's like from a comment. | token in body |
| POST | `/video_engine/remove_dislike_comment_view` | Remove the logged-in user's dislike from a comment. | token in body |
| POST | `/video_engine/add_comment_view` | Comment on a video, or reply under a root comment. | token in body |
| POST | `/video_engine/add_comment_view_v2` | Comment on a video, or reply to any comment in a thread. | token in body |
| POST | `/video_engine/fetch_threaded_comments` | List a thread of comments with their nested replies. | token in header |
| POST | `/video_engine/remove_comment_view` | Delete one of the logged-in user's comments. | token in body |
| POST | `/video_engine/fetch_video_reaction_status` | Return the like and dislike counts of a video and the logged-in user's own reaction. | token in body |
| POST | `/video_engine/fetch_comment_reaction_status` | Return the like and dislike counts of a comment and the logged-in user's own reaction. | token in body |
| POST | `/video_engine/create_playlist_view` | Create a playlist. | token in body |
| POST | `/video_engine/modify_playlist_view` | Rename a playlist or change its description. | token in body |
| POST | `/video_engine/delete_playlist` | Delete a playlist. | token in body |
| POST | `/video_engine/add_video_to_playlist` | Add a video to a playlist. | token in body |
| POST | `/video_engine/remove_video_from_playlist` | Remove a video from a playlist. | token in body |
| POST | `/video_engine/get_all_playlists` | List a user's playlists. | token in header |
| POST | `/video_engine/get_all_playlist_items` | List the videos in a playlist. | none |
| POST | `/video_engine/quick_fetch_playlists_view` | List the logged-in user's playlists that already hold a video. | token in header |
| POST | `/video_engine/get_top_videos_day_view` | List the top videos of the day. | none |
| POST | `/video_engine/get_top_videos_week_view` | List the top videos of the week. | none |
| POST | `/video_engine/get_top_videos_month_view` | List the top videos of the month. | none |
| POST | `/video_engine/get_top_videos_year_view` | List the top videos of the year. | none |
| POST | `/video_engine/get_watched_videos_api` | List the logged-in user's watch history. | token in header |
| POST | `/video_engine/render_threads_creator` | List the comment threads a user has written. | token in header |
| POST | `/video_engine/create_custom_feed_view` | Create a custom feed from topics and creators. | token in header |
| POST | `/video_engine/add_topic_to_custom_feed_view` | Add topics to a custom feed. | token in header |
| POST | `/video_engine/add_creators_to_custom_feed_view` | Add creators to a custom feed. | token in header |
| POST | `/video_engine/remove_topic_from_custom_feed_view` | Remove a topic from a custom feed. | token in header |
| POST | `/video_engine/remove_creator_from_custom_feed_view` | Remove a creator from a custom feed. | token in header |
| POST | `/video_engine/change_feed_visibility_view` | Make a custom feed public or private. | token in header |
| POST | `/video_engine/delete_feed_view` | Delete a custom feed. | token in header |
| POST | `/video_engine/log_feed_usage_view` | Record that the logged-in user started using a custom feed. | token in header |
| POST | `/video_engine/remove_feed_usage_view` | Record that the logged-in user stopped using a custom feed. | token in header |
| POST | `/video_engine/set_impressions_to_feed_view` | Record that a custom feed was shown to the logged-in user. | token in header |
| POST | `/video_engine/get_search_videos` | Search videos. | none |
| POST | `/video_engine/get_search_comments` | Search video comments. | token in header |

### Lounges: `modules/lounge_engine/urls.py`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| POST | `/lounge_engine/create_category` | Create a category in the logged-in creator's lounge. | token in body |
| POST | `/lounge_engine/modify_category` | Change a category. | token in body |
| POST | `/lounge_engine/delete_category` | Delete a category. | token in body |
| POST | `/lounge_engine/create_section` | Create a section inside a category. | token in body |
| POST | `/lounge_engine/modify_section` | Change a section. | token in body |
| POST | `/lounge_engine/delete_section` | Delete a section. | token in body |
| POST | `/lounge_engine/render_lounge` | Return a user's lounge as the logged-in user is allowed to see it. | token in body |
| POST | `/lounge_engine/fetch_available_categories` | List the categories of a user's lounge. | none |
| POST | `/lounge_engine/fetch_section_posts` | List the posts in a section. | token in body |
| POST | `/lounge_engine/fetch_child_posts` | List the direct replies to a post. | token in body |
| POST | `/lounge_engine/fetch_total_posts` | List every reply under a post. | token in body |
| GET | `/lounge_engine/get_media_url/<str:post_id>` | Redirect to a post's image attachment on the CDN. | none |
| POST | `/lounge_engine/get_user_invites` | List the lounge invites waiting for the logged-in user. | token in body |
| POST | `/lounge_engine/modify_lounge_details` | Change the logged-in creator's lounge details. | token in body |
| POST | `/lounge_engine/like_post_view` | Like a post. | token in body |
| POST | `/lounge_engine/dislike_post_view` | Dislike a post. | token in body |
| POST | `/lounge_engine/remove_like` | Remove the logged-in user's like from a post. | token in body |
| POST | `/lounge_engine/remove_dislike` | Remove the logged-in user's dislike from a post. | token in body |
| POST | `/lounge_engine/create_lounge_post` | Post in a section, or reply to a post. Multipart, with an optional `attachment` image. | token in body |
| POST | `/lounge_engine/remove_post` | Delete one of the logged-in user's posts. | token in body |
| POST | `/lounge_engine/fetch_post_reaction_status` | Return the like and dislike counts of a post and the logged-in user's own reaction. | token in body |
| POST | `/lounge_engine/fetch_threaded_comments_view` | List a thread of posts with their nested replies. | token in body |
| POST | `/lounge_engine/change_lounge_visibility` | Switch the logged-in creator's lounge between public and private. | token in body |
| POST | `/lounge_engine/accept_lounge_invite` | Accept an invite to a lounge. | token in body |
| POST | `/lounge_engine/deny_lounge_invite` | Decline an invite to a lounge. | token in body |
| POST | `/lounge_engine/report_comment_view` | Report a post to the moderators. | token in body |
| POST | `/lounge_engine/set_post_impression` | Record that a post was shown to the logged-in user. | token in body |
| POST | `/lounge_engine/leave_lounge` | Leave a lounge. | token in body |
| POST | `/lounge_engine/get_top_lounges` | List the top lounges. | none |
| POST | `/lounge_engine/get_top_lounge_posts` | List the top posts across lounges. | token in body |
| POST | `/lounge_engine/get_top_user_joined_lounges` | List the top lounges the logged-in user has joined. | token in body |
| POST | `/lounge_engine/get_top_user_joined_lounge_posts` | List the top posts from the lounges the logged-in user has joined. | token in body |
| POST | `/lounge_engine/render_lounge_home` | Build the lounges home screen. | token in body |
| POST | `/lounge_engine/search_users` | Search users. | token in body |
| POST | `/lounge_engine/fetch_search_posts` | Search lounge posts. | token in body |

### Notifications: `modules/notifier_engine/urls.py`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| POST | `/notifier_engine/render_lounge_notifications` | List the logged-in user's notifications about lounge posts. | token in body |
| POST | `/notifier_engine/render_replies` | List the logged-in user's notifications about replies. | token in body |
| POST | `/notifier_engine/render_subscriptions` | List the logged-in user's notifications from subscribed channels. | token in body |
| POST | `/notifier_engine/render_for_you` | List the logged-in user's "For you" notifications. | token in body |
| POST | `/notifier_engine/mark_notification_as_seen` | Mark one notification as seen. | token in body |
| POST | `/notifier_engine/get_unread_notification_count` | Return how many notifications the logged-in user has not seen. | token in body |

## Data model

- `user_engine/models.py`: `UserProfile` (one per account, holds XP, level and ranks), `Channel`, `ChannelSubscribers`, `UserGeolocations`, `BlockedProfiles`, `ReportedUser`, `UserAccountRemovalRequest`, `LimeLightStars` (creators picked in the admin). The lounge structure also lives here: `Lounge`, `LoungeCategories`, `LoungeSections`, `LoungeParticipants`, `LoungeAccess` (invites).
- `video_engine/models.py`: `VideoPost` is the centre. It carries the upload state, the encoding and ML flags, the transcript, sentiment, `topic_id` and `topic_category_id` that the video service fills in, and `video_xp`. Around it: `VideoViews`, `VideoImpressions`, `Likes`, `DisLikes`, `Comment` (threaded, with its own likes and dislikes), `Playlist`, `PlaylistItem`, `CustomFeed` and its topic, creator, usage and impression tables, and the report tables.
- `lounge_engine/models.py`: `LoungePost` (threaded), its likes, dislikes, impressions and logs, `ReportedPost`, and `UserPasswordReset` (the one-time codes for password reset).
- `notifier_engine/models.py`: one table per kind of notification, plus `PromotionNotificationWrapper`, the admin form that sends a broadcast.
- `analytics_engine/models.py`: metric logs per video, channel, lounge and lounge post, `UserTopicRelations`, the growth counters the admin dashboard plots, and the tables of the September 2024 creator contest.

## Uploading and playing a video

1. The client sends the file in chunks to `/video_engine/upload_video_DRAFT`. Each chunk is appended to a file under `MEDIA_ROOT/tmp/input`.
2. `/video_engine/save_video_draft` turns that file into a `VideoPost` draft and stores the original in S3 as `media/videos/<video id without dashes>/original.mp4`.
3. The video service in `../video` shares this database. Every three minutes it queues each video that is not yet encoded or not yet through the ML pipeline. The core API also has two Celery tasks that ask the video service to start right away (`add_to_encoder_queue` and `add_to_ml_queue` in `video_engine/models.py`), but nothing calls them.
4. The video service writes HLS renditions to the same S3 folder and fills in the transcript, sentiment and topic fields on the row.
5. Playback goes through `/video_engine/stream/<video_id>/<resolution>/<file>`, which reads the playlist or segment from S3 and returns it (`stream_hls` in `video_engine/views.py`). Thumbnails and the original file are redirects to CloudFront.

## How ranking and recommendations work

There is no learned recommender here. Ranking is a score called XP, computed by rule, and the feeds sort by it.

**Video XP** (`AnalyticsEngine.calculate_xp_VIDEO` in `analytics_engine/manager.py`, weights at the top of the class): likes, twice the comments, a tenth of the views, a quarter of the channel's subscribers, plus terms for watch time, view percentage, retention, bounce rate and conversion rate. As the code stands the five watch terms are always zero, because the row they read is looked up with a `log_type` that is never set. A `NOTE:` marks the spot.

**The recommended feed** (`VideoEngineManager.get_all_videos` in `video_engine/manager.py`, behind `/video_engine/fetch_videos`): active videos the user has not watched, highest XP first, then the videos they have watched, highest XP first. Watch history is the only personal signal. Pages hold 14 videos.

**Top videos** (`_get_top_videos`, same file): videos ordered by their best XP in a `VideoMetricsLog` window of a day, week, month or year. The list can be narrowed to a category and to creators in a city, country or region. Categories are the `TOPIC_MAP` table in the same file, which groups the 19 category ids the video service assigns into 11 names.

**Top creators** (`UserEngine._get_top_users` in `user_engine/manager.py`): channels ordered by XP from `ChannelMetrics`. `update_user_rankings` in the same file writes each user's day, week and month rank.

**Levels** (`generate_level` in `analytics_engine/manager.py`): level 1 below 100 XP, then one level for each doubling.

**User and topic** (`update_user_topic_relations`, same file): for each user, counts of views, likes, dislikes and comments per topic, stored in `UserTopicRelations`. This data feeds the user's XP. The feeds do not read it.

**Custom feeds** (`video_engine/manager.py`): a user can save a set of topics and creators as a feed and the service stores it and counts its use. No code builds a video list from one.

**Lounge invites** (`set_lounge_invites` in `lounge_engine/tasks.py`): a viewer with at least 4 views of a creator's videos and a mean watch percentage at or above the threshold gets an invite to that creator's lounge.

## Analytics

`analytics_engine/tasks.py` holds five scheduled tasks, set up in `CELERY_BEAT_SCHEDULE` in `config/settings/base.py`.

- `analytics_realtime_tasks`, every 5 minutes: recomputes view metrics and XP for every video, then XP and level for every user, channel, lounge and lounge post, then the contest standings and the user rankings.
- `analytics_daily_tasks`, `analytics_weekly_tasks`, `analytics_monthly_tasks`, `analytics_yearly_tasks`: append snapshot rows (`VideoMetricsLog`, `SubscribersMetricLog`, `ChannelMetrics`, lounge logs) with the growth against the previous snapshot. The daily task also writes the counters the admin dashboard plots.

Every loop walks every row, so the cost grows with the size of the tables.

The admin home page (`analytics_engine/dashboard.py`) shows those counters: users, videos, threads, reports, the encoding and ML backlog, and videos per category.

## Other background jobs

- `notifier_engine/tasks.py` `notification_sender`, every 120 seconds: retries unsent pushes from the last 3 days, notifies subscribers of new videos, sends admin broadcasts, and tells creators when a video has finished processing.
- `lounge_engine/tasks.py` `generate_lounge_logs` daily, `set_lounge_invites` every 10 minutes, `clean_up_password_resets` every 10 seconds.

## Deployment

Production ran on AWS EC2 through CodeDeploy. `appspec.yml` runs the scripts in `scripts/`, which write the `.env` file from two SSM parameters and start `docker-compose-production.yml`: Django under gunicorn with uvicorn workers, Postgres, Redis, a Celery worker, Celery beat, and Traefik for TLS. The Dockerfiles and start scripts are in `compose/`.

## Configuration

Copy `.env.example` to `.env`. It lists every variable the settings read. Production also needs a Firebase service account key file, at the path in `FIREBASE_CREDENTIALS_FILE`. No credentials are in this repository.

## Things you will notice

- The route prefixes `user_eng/` and `user_engine/` both exist. Path names such as `upload_video_DRAFT`, `save_video_draft_I` and the `_view` suffixes are as the client calls them.
- Some field names are misspelt (`is_authenicated`, `assoicated_lounge`, the JSON key `is_advertisor`). Renaming them needs a migration or a client release, so they stay.
- `lounge_engine/migrations/` has many migrations that only change one default, because that default is evaluated at import time (`UserPasswordReset.expires`).
- The engines have no tests.
