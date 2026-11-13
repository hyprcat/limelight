// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:meta/meta.dart';

part 'video_actions_event.dart';
part 'video_actions_state.dart';

class VideoActionsBloc extends Bloc<VideoActionsEvent, VideoActionsState> {
  VideoActionsBloc() : super(VideoActionsInitial()) {
    on<LoadVideoActions>(loadActionBar);
    on<LikeVideo>(likeVideo);
    on<RemoveLike>(removeLike);
    on<DisLikeVideo>(dislikeVideo);
    on<RemoveDisLike>(removeDislike);
  }

  var OGMap;

  FutureOr<void> loadActionBar(
      LoadVideoActions event, Emitter<VideoActionsState> emit) async {
    try {
      OGMap = await VideoEngine().fetchVideoReactionStatus(event.video);

      emit(VideoActionsEmitSuccess(OGMap));
    } catch (e) {
      emit(VideoActionsError());
    }
  }

  FutureOr<void> likeVideo(
      LikeVideo event, Emitter<VideoActionsState> emit) async {
    try {
      var response = await VideoEngine().likeVideo(event.video);
      if (response == 'success') {
        var reactionMap =
            await VideoEngine().fetchVideoReactionStatus(event.video);
        emit(VideoActionsEmitSuccess(reactionMap));
      } else {
        emit(VideoActionsEmitSuccess(OGMap));
      }
    } catch (e) {
      emit(VideoActionsError());
    }
  }

  FutureOr<void> removeLike(
      RemoveLike event, Emitter<VideoActionsState> emit) async {
    try {
      var response = await VideoEngine().removeLike(event.video);
      if (response == 'success') {
        var reactionMap =
            await VideoEngine().fetchVideoReactionStatus(event.video);
        emit(VideoActionsEmitSuccess(reactionMap));
      } else {
        emit(VideoActionsEmitSuccess(OGMap));
      }
    } catch (e) {
      emit(VideoActionsError());
    }
  }

  FutureOr<void> dislikeVideo(
      DisLikeVideo event, Emitter<VideoActionsState> emit) async {
    try {
      var response = await VideoEngine().dislikeVideo(event.video);
      if (response == 'success') {
        var reactionMap =
            await VideoEngine().fetchVideoReactionStatus(event.video);
        emit(VideoActionsEmitSuccess(reactionMap));
      } else {
        emit(VideoActionsEmitSuccess(OGMap));
      }
    } catch (e) {
      emit(VideoActionsError());
    }
  }

  FutureOr<void> removeDislike(
      RemoveDisLike event, Emitter<VideoActionsState> emit) async {
    try {
      var response = await VideoEngine().removeDislike(event.video);
      if (response == 'success') {
        var reactionMap =
            await VideoEngine().fetchVideoReactionStatus(event.video);
        emit(VideoActionsEmitSuccess(reactionMap));
      } else {
        emit(VideoActionsEmitSuccess(OGMap));
      }
    } catch (e) {
      emit(VideoActionsError());
    }
  }
}
