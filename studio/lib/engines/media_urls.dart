import 'package:code_arrow_creator_studio/defaults/constants.dart';

/// URLs for media served by the backend, used by widgets and players.

String videoThumbnailUrl(Object? videoId) => '${URL}video_engine/get_thumbnail/$videoId';

String videoStreamUrl(Object? videoId) => '${URL}video_engine/stream/$videoId';

/// Chunked upload endpoint for a new video draft.
String get videoDraftUploadUrl => '${URL}video_engine/upload_video_DRAFT';

String profilePictureUrl(Object? userName) => '${URL}user_eng/get_media_url/$userName';
