part of 'lounge_bloc.dart';

@immutable
abstract class LoungeState {}

class LoungeInitial extends LoungeState {}

class LoungeSuccess extends LoungeState {
  final UserLounge lounge;
  LoungeSuccess(this.lounge);
}

class LoungeError extends LoungeState {}

class LoungeLoading extends LoungeState {}
