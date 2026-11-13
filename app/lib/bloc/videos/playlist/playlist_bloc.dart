import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/playlist_engine.dart';
import 'package:lime_time_app/logics/repos/playlist_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(PlaylistInitial()) {
    on<FetchPlaylists>(fetchPlaylists);
    on<FetchPlaylistItems>(fetchPlaylistItems);
    on<CreatePlaylist>(createPlaylist);
    on<ModifyPlaylist>(modifyPlaylist);
    on<RemovePlaylist>(removePlaylist);
    on<AddVideoToPlaylist>(addVideoToPlaylist);
    on<RemoveVideoFromPlaylist>(removeVideoFromPlaylist);
  }

  PlayListRepo repo = PlayListRepo();
  VideoRepo playlistRepo = VideoRepo();

  FutureOr<void> fetchPlaylists(
      FetchPlaylists event, Emitter<PlaylistState> emit) async {
    emit(LoadingPlaylists());
    try {
      repo = await PlaylistHelper().getAllPlaylist(event.userId, repo);
      emit(PlaylistLoaded(repo));
    } catch (e) {
      emit(PlaylistsError());
    }
  }

  FutureOr<void> fetchPlaylistItems(
      FetchPlaylistItems event, Emitter<PlaylistState> emit) async {
    try {
      playlistRepo = await PlaylistHelper()
          .loadPlaylistVideos(event.playlistId, playlistRepo);
      emit(LoadingPlaylistItems(repo: playlistRepo));
    } catch (e) {
      emit(PlaylistsError());
    }
  }

  FutureOr<void> createPlaylist(
      CreatePlaylist event, Emitter<PlaylistState> emit) async {
    emit(LoadingPlaylists());
    try {
      var status =
          await PlaylistHelper().createPlaylist(event.name, event.description);
      if (status == "Playlist successfully created.") {
        emit(PlaylistCreated());
      } else {
        emit(PlaylistsError());
      }
    } catch (e) {
      emit(PlaylistsError());
    }
  }

  FutureOr<void> modifyPlaylist(
      ModifyPlaylist event, Emitter<PlaylistState> emit) async {
    emit(LoadingPlaylists());
    try {
      var status = await PlaylistHelper()
          .modifyPlaylist(event.name, event.description, event.playlistId);
      if (status == "Successfully modified playlist.") {
        emit(PlaylistModified());
      } else {
        emit(PlaylistsError());
      }
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> removePlaylist(
      RemovePlaylist event, Emitter<PlaylistState> emit) async {
    emit(LoadingPlaylists());
    try {
      var status = await PlaylistHelper().removePlaylist(event.playlistId);
      if (status == "Successfully deleted playlist.") {
        emit(PlaylistModified());
      } else {
        emit(PlaylistsError());
      }
    } catch (e) {
      emit(PlaylistsError());
    }
  }

  FutureOr<void> addVideoToPlaylist(
      AddVideoToPlaylist event, Emitter<PlaylistState> emit) {}

  FutureOr<void> removeVideoFromPlaylist(
      RemoveVideoFromPlaylist event, Emitter<PlaylistState> emit) {}
}
