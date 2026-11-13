// ignore_for_file: must_be_immutable

part of 'per_comment_bloc.dart';

@immutable
abstract class PerCommentEvent {}

class LoadComment extends PerCommentEvent {}

class LikeComment extends PerCommentEvent {
  VideoComment comment;
  Map<String, dynamic> reactionMap;
  LikeComment(this.comment, this.reactionMap);
}

class DislikeComment extends PerCommentEvent {
  VideoComment comment;
  Map<String, dynamic> reactionMap;
  DislikeComment(this.comment, this.reactionMap);
}

class RemoveLikeComment extends PerCommentEvent {
  VideoComment comment;
  Map<String, dynamic> reactionMap;
  RemoveLikeComment(this.comment, this.reactionMap);
}

class RemoveDislikeComment extends PerCommentEvent {
  VideoComment comment;
  Map<String, dynamic> reactionMap;
  RemoveDislikeComment(this.comment, this.reactionMap);
}
