import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'watched_videos_event.dart';
part 'watched_videos_state.dart';

class WatchedVideosBloc extends Bloc<WatchedVideosEvent, WatchedVideosState> {
  WatchedVideosBloc() : super(WatchedVideosInitial()) {
    on<LoadWatchedVideos>(load);
  }

  VideoRepo videoRepo = VideoRepo();
  FutureOr<void> load(
      LoadWatchedVideos event, Emitter<WatchedVideosState> emit) async {
    emit(LoadingWatchedVideos());
    try {
      videoRepo = await VideoEngine().fetchWatchedVideos(videoRepo);
      emit(LoadedWatchedVideos(repo: videoRepo));
    } catch (e) {
      emit(ErrorWatchedVideos());
    }
  }
}
