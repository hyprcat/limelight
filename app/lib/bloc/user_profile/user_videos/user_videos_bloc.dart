// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'user_videos_event.dart';
part 'user_videos_state.dart';

class UserVideosBloc extends Bloc<UserVideosEvent, UserVideosState> {
  UserVideosBloc() : super(UserVideosInitial()) {
    on<LoadUserVideos>(loadUserVideos);
  }

  VideoRepo? videoRepo = VideoRepo();
  FutureOr<void> loadUserVideos(
      LoadUserVideos event, Emitter<UserVideosState> emit) async {
    emit(LoadingUserVideos());
    try {
      UserProfile? targetProfile = event.user;
      if (event.refresh ||
          targetProfile.isBlockedByLoggedInUser ||
          targetProfile.isReversedBanned) {}

      await VideoEngine()
          .loadCreatorVideos(event.user.userId!.toString(), videoRepo!);
      if (targetProfile.isBlockedByLoggedInUser) {
        emit(UserHasBeenBlocked());
      } else if (targetProfile.isReversedBanned) {
        emit(UserBlockedLoggedInUser());
      } else {
        emit(UserVideosLoadingSuccess(videoRepo!, targetProfile));
      }
    } catch (e) {
      rethrow;
    }
  }
}
