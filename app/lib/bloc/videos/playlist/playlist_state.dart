part of 'playlist_bloc.dart';

@immutable
abstract class PlaylistState {}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final PlayListRepo repo;

  PlaylistLoaded(this.repo);
}

class LoadingPlaylists extends PlaylistState {}

class LoadingPlaylistItems extends PlaylistState {
  final VideoRepo repo;

  LoadingPlaylistItems({required this.repo});
}

class PlaylistCreated extends PlaylistState {}

class PlaylistModified extends PlaylistState {}

class PlaylistsError extends PlaylistState {}

class PlaylistItemError extends PlaylistState {}
