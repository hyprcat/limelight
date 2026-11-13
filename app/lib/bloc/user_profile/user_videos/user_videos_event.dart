part of 'user_videos_bloc.dart';

@immutable
abstract class UserVideosEvent {}

class LoadUserVideos extends UserVideosEvent {
  final UserProfile user;
  final bool refresh;
  LoadUserVideos(this.user, this.refresh);
}
