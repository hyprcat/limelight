// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:meta/meta.dart';

part 'per_comment_event.dart';
part 'per_comment_state.dart';

class PerCommentBloc extends Bloc<PerCommentEvent, PerCommentState> {
  VideoComment comment;

  PerCommentBloc(this.comment) : super(PerCommentInitial()) {
    on<LoadComment>(loadComment);
    on<LikeComment>(likeComment);
    on<DislikeComment>(dislikeComment);
    on<RemoveLikeComment>(removeLike);
    on<RemoveDislikeComment>(removeDislike);
  }

  FutureOr<void> loadComment(LoadComment event, Emitter<PerCommentState> emit) {
    emit(SuccessCommentLoadState(comment.interactionStatus!));
  }

  FutureOr<void> likeComment(
      LikeComment event, Emitter<PerCommentState> emit) async {
    try {
      Map<String, dynamic> original = Map.from(event.reactionMap);
      Map<String, dynamic> map = event.reactionMap;
      map['like'] = true;
      map['dislike'] = false;
      map['total_likes'] += 1;

      if (original['dislike'] == true) {
        map['total_dislikes'] -= 1;
      }
      emit(SuccessCommentLoadState(map));
      await VideoEngine().likeComment(event.comment);
    } catch (e) {
      emit(ErrorCommentState());
    }
  }

  FutureOr<void> dislikeComment(
      DislikeComment event, Emitter<PerCommentState> emit) async {
    try {
      Map<String, dynamic> original = Map.from(event.reactionMap);
      Map<String, dynamic> map = event.reactionMap;
      map['like'] = false;
      map['dislike'] = true;
      map['total_dislikes'] += 1;

      if (original['like'] == true) {
        map['total_likes'] -= 1;
      }
      emit(SuccessCommentLoadState(map));
      await VideoEngine().dislikeComment(event.comment);
    } catch (e) {
      emit(ErrorCommentState());
    }
  }

  FutureOr<void> removeLike(
      RemoveLikeComment event, Emitter<PerCommentState> emit) async {
    try {
      Map<String, dynamic> map = event.reactionMap;
      map['dislike'] = false;
      map['like'] = false;
      map['total_likes'] -= 1;
      emit(SuccessCommentLoadState(map));
      await VideoEngine().removeLikeComment(event.comment);
    } catch (e) {
      emit(ErrorCommentState());
    }
  }

  FutureOr<void> removeDislike(
      RemoveDislikeComment event, Emitter<PerCommentState> emit) async {
    try {
      Map<String, dynamic> map = event.reactionMap;
      map['dislike'] = false;
      map['like'] = false;
      map['total_dislikes'] -= 1;
      emit(SuccessCommentLoadState(map));
      await VideoEngine().removeDislikeComment(event.comment);
    } catch (e) {
      emit(ErrorCommentState());
    }
  }
}
