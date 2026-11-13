part of 'trending_bloc.dart';

@immutable
abstract class TrendingState {}

class TrendingInitial extends TrendingState {}

class LoadingTrendingVideos extends TrendingState {}

class LoadErrorTrendingVideos extends TrendingState {}

class LoadedTrendingVideosSuccessfully extends TrendingState {
  final VideoRepo repo;

  LoadedTrendingVideosSuccessfully(this.repo);
}
