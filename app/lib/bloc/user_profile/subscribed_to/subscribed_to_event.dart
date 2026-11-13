part of 'subscribed_to_bloc.dart';

@immutable
abstract class SubscribedToEvent {}

class LoadSubscribedTo extends SubscribedToEvent {}

class LoadBlockedUsers extends SubscribedToEvent {}
