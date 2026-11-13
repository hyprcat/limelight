// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/users/user_channel.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:meta/meta.dart';

part 'user_channel_event.dart';
part 'user_channel_state.dart';

class UserChannelBloc extends Bloc<UserChannelEvent, UserChannelState> {
  UserProfile? profile;
  UserChannel? channel;
  UserProfile? targetProfile;
  UserChannelBloc(this.channel, this.profile, this.targetProfile)
      : super(UserChannelInitial()) {
    on<LoadUserChannel>(loadUserChannel);
    on<Subscribe>(subscribe);
    on<Unsubscribe>(unsubscribe);
  }

  FutureOr<void> loadUserChannel(
      LoadUserChannel event, Emitter<UserChannelState> emit) async {
    try {
      if (event.refresh) {
        targetProfile = await UserEngine().getUserInfo(targetProfile!.userId!);
      }
      if (event.fetchSubscriptionStatus) {
        bool subscriptionStatus =
            await UserEngine().subscriptionStatus(channel!, profile!.userId!);
        emit(SuccessfullyLoadedChannel(subscriptionStatus, targetProfile!));
      } else {
        emit(SuccessfullyLoadedChannel(
            targetProfile!.subscribedByCurrentUser!, targetProfile!));
      }
    } catch (e) {
      emit(ErrorAtChannel());
    }
  }

  FutureOr<void> subscribe(
      Subscribe event, Emitter<UserChannelState> emit) async {
    try {
      emit(SuccessfullyLoadedChannel(true, targetProfile!));
      await UserEngine().subscribeChannel(channel!);
      targetProfile = await UserEngine().getUserInfo(targetProfile!.userId!);
    } catch (e) {
      emit(ErrorAtChannel());
    }
  }

  FutureOr<void> unsubscribe(
      Unsubscribe event, Emitter<UserChannelState> emit) async {
    try {
      emit(SuccessfullyLoadedChannel(false, targetProfile!));
      await UserEngine().unsubscribeChannel(channel!);
      targetProfile = await UserEngine().getUserInfo(targetProfile!.userId!);
    } catch (e) {
      emit(ErrorAtChannel());
    }
  }
}
