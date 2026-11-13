part of 'subscribed_to_bloc.dart';

@immutable
abstract class SubscribedToState {}

class SubscribedToInitial extends SubscribedToState {}

class Loading extends SubscribedToState {}

class LoadingSuccess extends SubscribedToState {
  final UserRepo repo;

  LoadingSuccess({required this.repo});
}

class FetchingError extends SubscribedToState {}
