part of 'n_threads_bloc.dart';

@immutable
sealed class NThreadsState {}

final class NThreadsInitial extends NThreadsState {}

class NThreadsSuccess extends NThreadsState {
  ThreadNotifications repo;
  NThreadsSuccess(this.repo);
}

class NThreadsError extends NThreadsState {}
