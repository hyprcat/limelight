// ignore_for_file: must_be_immutable

part of 'user_channel_bloc.dart';

@immutable
abstract class UserChannelState {}

class UserChannelInitial extends UserChannelState {}

class SuccessfullyLoadedChannel extends UserChannelState {
  bool subscriptionStatus;
  UserProfile obj;
  SuccessfullyLoadedChannel(this.subscriptionStatus, this.obj);
}

class ErrorAtChannel extends UserChannelState {}

class LoadingChannel extends UserChannelState {}

class RefreshChannel extends UserChannelState {}
