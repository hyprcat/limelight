part of 'playlist_bloc.dart';

@immutable
abstract class PlaylistEvent {}

class FetchPlaylists extends PlaylistEvent {
  final String userId;
  final int pageNumber;

  FetchPlaylists({required this.userId, required this.pageNumber});
}

class FetchPlaylistItems extends PlaylistEvent {
  final String playlistId;

  FetchPlaylistItems({required this.playlistId});
}

class CreatePlaylist extends PlaylistEvent {
  final String name;
  final String description;

  CreatePlaylist({required this.name, required this.description});
}

class ModifyPlaylist extends PlaylistEvent {
  final String name;
  final String description;
  final String playlistId;

  ModifyPlaylist(
      {required this.name,
      required this.description,
      required this.playlistId});
}

class RemovePlaylist extends PlaylistEvent {
  final String playlistId;

  RemovePlaylist({required this.playlistId});
}

class AddVideoToPlaylist extends PlaylistEvent {}

class RemoveVideoFromPlaylist extends PlaylistEvent {}
