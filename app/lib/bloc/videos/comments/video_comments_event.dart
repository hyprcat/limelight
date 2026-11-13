part of 'video_comments_bloc.dart';

@immutable
abstract class VideoCommentsEvent {}

class LoadComments extends VideoCommentsEvent {
  final bool refresh;

  LoadComments(this.refresh);
}

class AddComment extends VideoCommentsEvent {
  final Map<String, dynamic> data;
  AddComment(this.data);
}

class RemoveComment extends VideoCommentsEvent {
  final Map<String, dynamic> data;
  RemoveComment(this.data);
}

class LoadThreadedComments extends VideoCommentsEvent {
  final bool refresh;

  LoadThreadedComments(this.refresh);
}

class LoadThreadsUser extends VideoCommentsEvent {
  final String userId;
  LoadThreadsUser(this.userId);
}
