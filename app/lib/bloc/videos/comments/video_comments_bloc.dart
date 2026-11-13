// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/logics/repos/threads/video_comment_thread_repo.dart';
import 'package:meta/meta.dart';

part 'video_comments_event.dart';
part 'video_comments_state.dart';

class VideoCommentsBloc extends Bloc<VideoCommentsEvent, VideoCommentsState> {
  VideoCommentThreadRepo repo = VideoCommentThreadRepo();
  VideoCommentRepo commentsRepo;
  VideoCommentsBloc(this.commentsRepo) : super(VideoCommentsInitial()) {
    on<LoadComments>(loadComments);
    on<AddComment>(addComment);
    on<RemoveComment>(removeComment);
    on<LoadThreadedComments>(loadThreadedComments);
    on<LoadThreadsUser>(loadThreads);
  }

  FutureOr<void> loadComments(
      LoadComments event, Emitter<VideoCommentsState> emit) async {
    emit(LoadingComments());
    try {
      VideoCommentRepo tempRepo = await VideoEngine()
          .loadComments(commentsRepo, refresh: event.refresh);
      commentsRepo = tempRepo;
      emit(SuccessfulCommentFetch(tempRepo));
    } catch (E) {
      CommentLoadError();
    }
  }

  FutureOr<void> removeComment(
      RemoveComment event, Emitter<VideoCommentsState> emit) async {
    try {
      var response = await VideoEngine().removeComment(event.data);
      if (response == 'success') {
        emit(CommentRemovedSuccessfully());
        VideoCommentRepo tempRepo =
            await VideoEngine().loadComments(commentsRepo);
        commentsRepo = tempRepo;
        emit(SuccessfulCommentFetch(tempRepo));
      } else {
        emit(SuccessfulCommentFetch(commentsRepo));
      }
    } catch (E) {
      CommentLoadError();
    }
  }

  FutureOr<void> addComment(
      AddComment event, Emitter<VideoCommentsState> emit) async {
    try {
      var response = await VideoEngine().addCommentV2(event.data);
      if (response == 'success') {
        emit(CommentAddedSuccessfully());
        VideoCommentRepo tempRepo =
            await VideoEngine().loadComments(commentsRepo);
        commentsRepo = tempRepo;
        emit(SuccessfulCommentFetch(tempRepo));
      } else {
        emit(SuccessfulCommentFetch(commentsRepo));
      }
    } catch (E) {
      CommentLoadError();
    }
  }

  FutureOr<void> loadThreadedComments(
      LoadThreadedComments event, Emitter<VideoCommentsState> emit) async {
    emit(LoadingComments());
    try {
      VideoCommentRepo tempRepo = await VideoEngine()
          .loadThreadedComments(commentsRepo, refresh: event.refresh);
      commentsRepo = tempRepo;
      emit(SuccessfulCommentFetch(tempRepo));
    } catch (E) {
      CommentLoadError();
    }
  }

  FutureOr<void> loadThreads(
      LoadThreadsUser event, Emitter<VideoCommentsState> emit) async {
    try {
      repo = await VideoEngine()
          .renderUserThreads(event.userId, VideoCommentThreadRepo());
      emit(SuccessfulThreadsFetch(repo));
    } catch (e) {
      rethrow;
    }
  }
}
