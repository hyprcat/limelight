part of 'n_subscriptions_bloc.dart';

@immutable
sealed class NSubscriptionsState {}

final class NSubscriptionsInitial extends NSubscriptionsState {}

class NSubscriptionLoaded extends NSubscriptionsState {
  final SubscriptionsRepo repo;

  NSubscriptionLoaded(this.repo);
}

class NSubscriptionError extends NSubscriptionsState {}
