import 'package:lime_time_app/logics/models/videos/playlist.dart';

class PlayListRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<PlayList> playlists = [];

  void markPlaylistContainingVideo(PlayListRepo otherRepo) {
    Set<String?> otherPlaylistIds =
        otherRepo.playlists.map((playlist) => playlist.playlistId).toSet();

    for (PlayList playlist in playlists) {
      if (otherPlaylistIds.contains(playlist.playlistId)) {
        playlist.videoExistsInPlaylist = true;
      }
    }
  }
}
