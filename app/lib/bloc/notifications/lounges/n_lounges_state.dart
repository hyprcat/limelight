part of 'n_lounges_bloc.dart';

@immutable
sealed class NLoungesState {}

final class NLoungesInitial extends NLoungesState {}

class NLoungeError extends NLoungesState {}

class NLoungeSuccess extends NLoungesState {
  LoungeNotificationRepo repo;
  NLoungeSuccess(this.repo);
}

class NLoungeLoading extends NLoungesState {}
