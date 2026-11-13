# LimeLight creator studio

A Flutter web app where creators signed in, uploaded videos and managed their drafts on a large screen.
It was the first client written for the platform, back when the project was called Code Arrow, which is why the Dart package is still named `code_arrow_creator_studio`.

Work on it ran from October 2023 to mid 2024. Uploading later moved into the mobile app and the studio was retired.
It is published as it was, with the folders tidied. It is not maintained and may not build against current Flutter releases.

## What it does

| Feature | Where |
| --- | --- |
| Sign up, log in, and create a profile with a picture, bio, age and gender. | `lib/screens/login/`, `lib/blocs/signup/`, `lib/engines/user_engine.dart` |
| Route guard that checks the stored session before showing the studio. | `lib/screens/route_guard.dart`, `lib/blocs/route_guard/` |
| Home shell with a side drawer. Dashboard, Content and Analytics are built. Lounge, Comments, Subtitles, Earn, Customisation, Settings and Help are empty placeholders. | `lib/screens/home/home.dart` |
| Video upload in chunks of up to 50 MB with a progress bar, then a draft is created. | `lib/screens/home/main_screen/upload_file_card.dart`, `lib/blocs/home/upload_video/` |
| Draft editor in two steps: title, description, thumbnail, paid promotion, age restriction, language and topic, then visibility (public, draft, unlisted, lounge members only) and scheduling. | `lib/screens/home/content/edit_draft/`, `lib/blocs/content/edit_draft/` |
| List of drafts and uploaded videos with pagination, preview and delete. | `lib/screens/home/content/all_drafts/`, `lib/widgets/video_data_row.dart`, `lib/blocs/content/drafts/` |
| Video preview player and miniplayer. | `lib/widgets/video_player.dart`, `lib/widgets/full_screen_video_player.dart`, `lib/widgets/miniplayer.dart` |
| Analytics page layout with charts for watch time, views, likes, dislikes, impressions and retention. The numbers are placeholders. It was never wired to the backend. | `lib/screens/home/analytics/` |
| Light and dark theme, responsive breakpoints for phone, tablet and desktop widths. | `lib/main.dart` |

## Structure

```
lib/
  main.dart      entry point, theme, routes (/, /home, /user_profile, /404)
  defaults/      constants (API base URL, topic list), colours, text styles
  blocs/         flutter_bloc state per screen (bloc, event, state)
  engines/       API clients (user, video), media URLs, models
  screens/       login, home shell, content, analytics
  widgets/       shared widgets and players
web/             Flutter web shell
```

State is held in blocs. The session token is kept in `flutter_secure_storage` and loaded in `lib/main.dart`.

## How it talks to the backend

It calls the Django API in [`../core`](../core) with `dio`. The token is sent in the request body.

| Client | Endpoints |
| --- | --- |
| `lib/engines/user_engine.dart` | `user_eng/create_user`, `user_engine/login/`, `user_eng/create_user_profile`, `user_eng/get_logged_in_user` |
| `lib/engines/video_engine.dart` | `video_engine/save_video_draft`, `save_video_draft_I`, `get_video_info`, `update_video_status`, `delete_video`, and the paginated draft lists |
| `lib/engines/media_urls.dart` | `video_engine/upload_video_DRAFT`, `video_engine/stream/<id>`, `video_engine/get_thumbnail/<id>`, `user_eng/get_media_url/<username>` |

These are the early versions of the endpoints. The backend moved on after the studio was retired, so some calls will not match [`../core`](../core) as published.

## Configure and build

You need Flutter 3.13 or newer from 2023 or 2024 (Dart 3.1). The code was last checked with `flutter analyze` on Flutter 3.24.3, which reports no errors.

The API base URL defaults to `http://127.0.0.1:8000/`. Change it at build time:

```
flutter pub get
flutter run -d chrome --dart-define=LIMELIGHT_API_URL=http://127.0.0.1:8000/
```

Only the `web/` platform folder is kept. The fullscreen player imports `dart:html`, so the app runs on the web only.
The `macos/`, `windows/` and `linux/` folders in the private repository were unmodified Flutter templates. `flutter create --platforms=macos,windows,linux .` brings them back.

There are no secrets or service keys in this app.
