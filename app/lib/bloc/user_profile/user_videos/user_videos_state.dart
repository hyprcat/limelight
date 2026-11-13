part of 'user_videos_bloc.dart';

@immutable
abstract class UserVideosState {}

class UserVideosInitial extends UserVideosState {}

class LoadingUserVideos extends UserVideosState {}

class UserVideosError extends UserVideosState {}

class UserVideosLoadingSuccess extends UserVideosState {
  final VideoRepo videos;
  final UserProfile user;
  UserVideosLoadingSuccess(this.videos, this.user);
}

class UserBlockedLoggedInUser extends UserVideosState {}

class UserHasBeenBlocked extends UserVideosState {}
