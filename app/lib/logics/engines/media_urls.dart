import 'package:lime_time_app/defaults/constants.dart';

/// URLs for media and callbacks served by the backend.
///
/// Widgets and players load these directly (images, HLS playlists, uploads),
/// so they live here next to the engines instead of being spelled out in
/// every screen.

/// Thumbnail of a video. The backend expects the id without dashes.
String videoThumbnailUrl(String videoId) =>
    '${URL}video_engine/get_thumbnail/${videoId.replaceAll("-", "").toString()}';

/// HLS playlist of a video at one resolution (144, 240, ... 1440).
String videoStreamUrl(String videoId, Object resolution) =>
    '${URL}video_engine/stream/$videoId/$resolution/video.m3u8';

/// The originally uploaded file, used as a fallback source.
String originalVideoUrl(String videoId) =>
    '${URL}video_engine/stream_original_video/$videoId';

/// Chunked upload endpoint for a new video draft.
String get videoDraftUploadUrl => '${URL}video_engine/upload_video_DRAFT';

/// Profile picture of a user.
String profilePictureUrl(String? userName) =>
    '${URL}user_eng/get_media_url/$userName';

/// Channel banner of a user.
String userBannerUrl(String? userName) => '${URL}user_eng/get_banner/$userName';

/// Image attached to a lounge post.
String loungePostMediaUrl(Object postId) =>
    '${URL}lounge_engine/get_media_url/$postId';

/// Sign in with Apple: redirect target and token validation.
String get appleCallbackUrl => '${URL}user_eng/apple_callback';
String get appleIdTokenValidationUrl =>
    '${URL}user_eng/validate_apple_id_token';
