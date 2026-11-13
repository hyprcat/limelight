part of 'n_subscriptions_bloc.dart';

@immutable
sealed class NSubscriptionsEvent {}

class LoadSubscriptionsNotification extends NSubscriptionsEvent {}
