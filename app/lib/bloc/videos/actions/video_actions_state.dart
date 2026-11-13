// ignore_for_file: must_be_immutable

part of 'video_actions_bloc.dart';

@immutable
abstract class VideoActionsState {}

class VideoActionsInitial extends VideoActionsState {}

class VideoActionsEmitSuccess extends VideoActionsState {
  dynamic reactionMap;
  VideoActionsEmitSuccess(this.reactionMap);
}

class VideoActionsError extends VideoActionsState {}
