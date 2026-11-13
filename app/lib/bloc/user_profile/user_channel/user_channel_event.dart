// ignore_for_file: must_be_immutable

part of 'user_channel_bloc.dart';

@immutable
abstract class UserChannelEvent {}

class LoadUserChannel extends UserChannelEvent {
  bool refresh;
  bool fetchSubscriptionStatus;
  LoadUserChannel(this.refresh, this.fetchSubscriptionStatus);
}

class Subscribe extends UserChannelEvent {}

class Unsubscribe extends UserChannelEvent {}
