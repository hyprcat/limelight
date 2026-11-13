# LimeLight app

The LimeLight Social mobile app for Android and iOS, written in Flutter and Dart.
People watched videos, posted threads, joined creator lounges and uploaded their own videos with it.

Work on it started in November 2023 and the last release shipped in October 2024. It is published as it was, with the folders tidied.
It is not maintained and may not build against current Flutter releases.

## What it does

| Feature | Where |
| --- | --- |
| Sign in with email and password, Google or Apple. Sign up, onboarding slides, password reset by emailed OTP. | `lib/screens/authentication/`, `lib/bloc/sign_in/`, `lib/logics/services/auth_repository.dart` |
| Home with five tabs: local hub, threads and videos, new thread, notifications, discover. | `lib/screens/home/home.dart`, `lib/v1_300/`, `lib/v1_200/discover/` |
| Video player. Plays HLS from the backend at 144p to 1440p, picks the ladder from the video's height, and falls back to the original upload when a video is not transcoded yet. | `lib/widgets/video_players/better_player_widget.dart`, `lib/defaults/utils.dart` |
| Watch page with likes, dislikes, threaded comments, replies, reporting, playlists and follow-up videos. A miniplayer keeps the video on screen while browsing. | `lib/screens/video_player/`, `lib/widgets/miniplayer/`, `lib/bloc/videos/` |
| Short vertical videos with a swipe feed. | `lib/v1_200/shorts/`, `lib/v1_200/cards/` |
| Video upload. Picks a file, uploads it in chunks, saves a draft, then collects title, description, thumbnail, topic and visibility. | `lib/screens/upload_video/`, `lib/bloc/content/` |
| Lounges: a creator's community space with categories, sections, image and text posts, threaded replies, reactions and invites. | `lib/screens/settings/lounges/`, `lib/screens/lounges/`, `lib/logics/engines/lounge_engine.dart` |
| Notifications in four feeds (for you, subscriptions, threads, lounges) and push notifications through Firebase Cloud Messaging. | `lib/screens/notifications/`, `lib/logics/engines/notifier_engine.dart`, `lib/logics/services/push_notification_service.dart` |
| Search across videos, users and lounge posts. | `lib/screens/search/`, `lib/bloc/search/` |
| Discover: trending videos and top creators for the world, your country, region or city, over a week, month or year. | `lib/v1_200/discover/`, `lib/bloc/trending_home/` |
| Channel and profile pages with levels, leagues, experience points, subscribers and channel metrics. | `lib/screens/settings/channel/`, `lib/screens/settings/main/`, `lib/screens/settings/widgets/channel_metrics.dart` |
| Playlists, watch history, subscriptions, blocked users. | `lib/screens/settings/playlist/`, `lib/screens/settings/watch_history/`, `lib/screens/settings/subscriptions/` |
| Settings, data access and account deletion requests, user and content reporting, a screen for banned accounts. | `lib/screens/settings/main/`, `lib/widgets/fundamentals/report_screen.dart`, `lib/widgets/ban_screen.dart` |
| The September 2024 referral contest. | `lib/screens/settings/contests/`, `lib/bloc/contests/` |

Some screens from earlier versions are still in the tree but no longer reachable from the navigation of the last build:
the lounges home and invite screens (`lib/screens/lounges/`), the leaderboards (`lib/screens/leaderboards/`, `lib/v1_200/leaderboards/`),
the trending page (`lib/screens/trending/`), custom feeds (`lib/screens/home/custom_feeds/`), the drafts list (`lib/screens/upload_video/all_drafts/`),
the lounge notifications feed, the about page and the Hazel AI settings page. They are kept because they were real, shipped work.

## Structure

```
lib/
  main.dart            entry point: Firebase, Hive, notifications, location, initial route
  firebase_options.dart
  defaults/            constants, colours, text styles, global state, helpers
  bloc/                one flutter_bloc per screen or action (bloc, event, state)
  logics/
    engines/           API clients, one per backend module, plus media_urls.dart
    models/            data classes parsed from the API (some cached with Hive)
    repos/             paginated collections the blocs hold
    services/          auth session and push notifications
  screens/             the screens, grouped by area
  widgets/             shared widgets, buttons, the video player, the miniplayer
  v1_200/              the 1.200 redesign: discover, shorts, new cards
  v1_300/              work for 1.300: local hub, threads and video feed, inline cards
android/ ios/ web/     platform projects with permissions, icons and splash screens
```

Navigation uses named routes in `lib/main.dart` (`/`, `/home`, `/banned`, `/user_details`, `/sept_contest_banner`) and
`persistent_bottom_nav_bar` for the tabs in `lib/screens/home/home.dart`. Screens push each other directly.

State is held in blocs under `lib/bloc/`. A few cross-screen values (the current player, the miniplayer, the signed-in user)
are global `ValueNotifier`s in `lib/defaults/global.dart`.

`v1_200` and `v1_300` are named after the app versions they were written for. The flag `isExperimental` in
`lib/defaults/constants.dart` switches the 1.200 layout on. It was on in the last build.

## How it talks to the backend

The app calls the Django API in [`../core`](../core) over HTTPS with `dio`. The session token is stored with
`flutter_secure_storage` and sent in the `authorization` header.

| Client | Backend prefix | Used for |
| --- | --- | --- |
| `lib/logics/engines/user_engine.dart` | `user_eng/`, `user_engine/` | login, sign up, profiles, channels, subscriptions, blocking, location, account deletion |
| `lib/logics/engines/video_engine.dart` | `video_engine/` | feeds, video info, comments, reactions, search, views and impressions, drafts |
| `lib/logics/engines/playlist_engine.dart` | `video_engine/` | playlists |
| `lib/logics/engines/lounge_engine.dart` | `lounge_engine/` | lounges, sections, posts, invites |
| `lib/logics/engines/notifier_engine.dart` | `notifier_engine/` | notification feeds and unread count |
| `lib/logics/engines/media_urls.dart` | `video_engine/`, `user_eng/`, `lounge_engine/` | thumbnail, HLS stream, original video, upload, profile picture and banner URLs |

Uploads go to `video_engine/upload_video_DRAFT` in chunks (`chunked_uploader`), then `video_engine/save_video_draft` creates the draft.
Playback reads `video_engine/stream/<id>/<resolution>/video.m3u8`.

## Configure and build

You need Flutter 3.22 or newer from 2024 (Dart 3.4). The code was last checked with `flutter analyze` on Flutter 3.24.3, which reports no errors.

1. Backend. The default base URL is the old production host, which is offline. Run [`../core`](../core) yourself and pass its URL:

   ```
   flutter run --dart-define=LIMELIGHT_API_URL=http://10.0.2.2:8000/
   ```

2. Firebase. The real project files are not in this repository. Create your own Firebase project, then either run `flutterfire configure`,
   or do it by hand:
   - copy `android/app/google-services.example.json` to `android/app/google-services.json` and fill it in
   - copy `ios/Runner/GoogleService-Info.example.plist` to `ios/Runner/GoogleService-Info.plist` and fill it in
   - replace `YOUR_IOS_CLIENT_ID` in `ios/Runner/Info.plist`
   - pass the values read by `lib/firebase_options.dart` with `--dart-define`, or let `flutterfire configure` rewrite that file
   - fill in the config block in `web/index.html` if you build for the web

3. Signing. Android release builds read `android/key.properties` (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`). It is not included.
   For iOS, set your own team in Xcode.

4. Assets that are not included. See the next section.

5. Build:

   ```
   flutter pub get
   flutter run
   ```

## Assets that were removed

These were in the private repository and are left out because their licences do not allow redistribution or are unknown.

- Gilroy font files. The UI used them as the font family `Gil`. Without them Flutter falls back to the default font. To restore, add your licensed copies under `assets/fonts/` and declare the family in `pubspec.yaml`.
- `assets/sign-in.mp4`, the looping background video of the sign-in screen (`lib/screens/authentication/signin.dart`).
- Eleven sticker GIFs used by the onboarding slides and a few empty states (`end.gif`, `game.gif`, `leaderboards.gif`, `lounges.gif`, `monetise.gif`, `peek.gif`, `promise.gif`, `ranks.gif`, `support.gif` and two unused ones).

The screens that load them will show a missing-asset error until you add files with the same names.

## Third-party code in the tree

- `lib/widgets/miniplayer/miniplayer.dart` is adapted from the [`miniplayer`](https://pub.dev/packages/miniplayer) package (MIT).
- `lib/widgets/draggable_home.dart` and `lib/widgets/draggable_home_alternative.dart` are adapted from the [`draggable_home`](https://pub.dev/packages/draggable_home) package (MIT).
- `lib/logics/models/**/*.g.dart` are generated by `hive_generator`.

## Known rough edges

- Several packages are imported without being listed in `pubspec.yaml` (`http`, `rxdart`, `collection`, `shared_preferences`, `visibility_detector` and others). They resolve because other dependencies bring them in.
- A few screens load placeholder images from third-party hosts by URL.
- `flutter analyze` still reports about 190 lints, mostly `use_build_context_synchronously`.
- There are no tests.
