import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'trending_event.dart';
part 'trending_state.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  TrendingBloc() : super(TrendingInitial()) {
    on<LoadTrendingVideos>(loadEvent);
  }

  VideoRepo videoRepo = VideoRepo();

  FutureOr<void> loadEvent(
      LoadTrendingVideos event, Emitter<TrendingState> emit) async {
    try {
      if (event.isDay) {
        videoRepo = await VideoEngine().fetchTopDailyVideos(
            event.data, videoRepo,
            onlyShortVideos: event.onlyShortVideos);
      } else if (event.isWeek) {
        videoRepo = await VideoEngine().fetchTopWeekVideos(
            event.data, videoRepo,
            onlyShortVideos: event.onlyShortVideos);
      } else if (event.isMonth) {
        videoRepo = await VideoEngine().fetchTopMonthVideos(
            event.data, videoRepo,
            onlyShortVideos: event.onlyShortVideos);
      } else if (event.isYear) {
        videoRepo = await VideoEngine().fetchTopYearVideos(
            event.data, videoRepo,
            onlyShortVideos: event.onlyShortVideos);
      }
      emit(LoadedTrendingVideosSuccessfully(videoRepo));
    } catch (e) {
      emit(LoadErrorTrendingVideos());
    }
  }
}
