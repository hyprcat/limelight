part of 'watched_videos_bloc.dart';

@immutable
abstract class WatchedVideosState {}

class WatchedVideosInitial extends WatchedVideosState {}

class LoadingWatchedVideos extends WatchedVideosState {}

class LoadedWatchedVideos extends WatchedVideosState {
  final VideoRepo repo;

  LoadedWatchedVideos({required this.repo});
}

class ErrorWatchedVideos extends WatchedVideosState {}
