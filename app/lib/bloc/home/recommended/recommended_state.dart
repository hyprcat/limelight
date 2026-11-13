// ignore_for_file: must_be_immutable

part of 'recommended_bloc.dart';

@immutable
abstract class RecommendedState {}

class RecommendedInitial extends RecommendedState {}

class RecommendedSuccess extends RecommendedState {
  VideoRepo videoRepo;
  RecommendedSuccess(this.videoRepo);
}

class ExperimentalHomeSection extends RecommendedState {
  ExperimentalHomeRepo repo;
  ExperimentalHomeSection(this.repo);
}

class LoadingRecommended extends RecommendedState {}

class RecommendedError extends RecommendedState {}
