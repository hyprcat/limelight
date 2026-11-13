part of 'video_actions_bloc.dart';

@immutable
abstract class VideoActionsEvent {}

class LoadVideoActions extends VideoActionsEvent {
  final VideoPost video;
  LoadVideoActions(this.video);
}

class LikeVideo extends VideoActionsEvent {
  final VideoPost video;
  LikeVideo(this.video);
}

class RemoveLike extends VideoActionsEvent {
  final VideoPost video;
  RemoveLike(this.video);
}

class DisLikeVideo extends VideoActionsEvent {
  final VideoPost video;
  DisLikeVideo(this.video);
}

class RemoveDisLike extends VideoActionsEvent {
  final VideoPost video;
  RemoveDisLike(this.video);
}

class AddToPlaylist extends VideoActionsEvent {
  final VideoPost video;
  AddToPlaylist(this.video);
}
