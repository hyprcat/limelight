part of 'n_for_you_bloc.dart';

@immutable
sealed class NForYouState {}

final class NForYouInitial extends NForYouState {}

class NForYouSuccess extends NForYouState {
  ForYouRepo repo;
  NForYouSuccess(this.repo);
}

class NForYouError extends NForYouState {}
