// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/repos/home/home.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'recommended_event.dart';
part 'recommended_state.dart';

class RecommendedBloc extends Bloc<RecommendedEvent, RecommendedState> {
  String previousType = "";
  VideoRepo recommendationsRepo = VideoRepo();

  RecommendedBloc() : super(RecommendedInitial()) {
    on<LoadRecommendedEvent>(loadVideos, transformer: debounce());
    on<LoadSubscribedVideos>(loadSubscriptionVideos, transformer: debounce());
    on<LoadExperimentalUI>(loadExperimentalUI, transformer: debounce());
    on<LoadExperimentalUIVideos>(loadExperimentalUIVideos,
        transformer: debounce());
    on<LoadExperimentalUIThreads>(loadExperimentalUIThreads,
        transformer: debounce());
  }

  FutureOr<void> loadVideos(
      LoadRecommendedEvent event, Emitter<RecommendedState> emit) async {
    try {
      recommendationsRepo = await VideoEngine().loadRecommendations(
          recommendationsRepo,
          onlyShortVideos: event.onlyShortVideos);
      emit(RecommendedSuccess(recommendationsRepo));
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> loadSubscriptionVideos(
      LoadSubscribedVideos event, Emitter<RecommendedState> emit) async {
    try {
      recommendationsRepo =
          await UserEngine().loadSubscribedToVideos(recommendationsRepo);
      emit(RecommendedSuccess(recommendationsRepo));
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> loadExperimentalUI(
      LoadExperimentalUI event, Emitter<RecommendedState> emit) async {
    emit(RecommendedInitial());
    emit(ExperimentalHomeSection(await VideoEngine().renderHomeV2Experiment()));
  }

  FutureOr<void> loadExperimentalUIVideos(
      LoadExperimentalUIVideos event, Emitter<RecommendedState> emit) async {
    emit(RecommendedInitial());
    emit(ExperimentalHomeSection(await VideoEngine().renderHomeV2Videos()));
  }

  FutureOr<void> loadExperimentalUIThreads(
      LoadExperimentalUIThreads event, Emitter<RecommendedState> emit) async {
    emit(RecommendedInitial());
    emit(ExperimentalHomeSection(await VideoEngine().renderHomeV2Threads()));
  }
}
