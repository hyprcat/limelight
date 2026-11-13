// ignore_for_file: must_be_immutable

part of 'recommended_bloc.dart';

@immutable
abstract class RecommendedEvent {}

class LoadRecommendedEvent extends RecommendedEvent {
  String type;
  bool onlyShortVideos = false;
  LoadRecommendedEvent(this.type, {this.onlyShortVideos = false});
}

class LoadSubscribedVideos extends RecommendedEvent {}

class LoadExperimentalUI extends RecommendedEvent {}

class LoadExperimentalUIVideos extends RecommendedEvent {}

class LoadExperimentalUIThreads extends RecommendedEvent {}
