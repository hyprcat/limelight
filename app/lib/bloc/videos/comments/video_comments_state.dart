part of 'video_comments_bloc.dart';

@immutable
abstract class VideoCommentsState {}

class LoadingComments extends VideoCommentsState {}

class VideoCommentsInitial extends VideoCommentsState {}

class SuccessfulCommentFetch extends VideoCommentsState {
  final VideoCommentRepo repo;
  SuccessfulCommentFetch(this.repo);
}

class CommentAddedSuccessfully extends VideoCommentsState {}

class CommentRemovedSuccessfully extends VideoCommentsState {}

class CommentActionError extends VideoCommentsState {}

class CommentLoadError extends VideoCommentsState {}

class SuccessfulThreadsFetch extends VideoCommentsState {
  final VideoCommentThreadRepo repo;
  SuccessfulThreadsFetch(this.repo);
}
