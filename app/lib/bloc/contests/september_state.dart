part of 'september_bloc.dart';

@immutable
sealed class SeptemberState {}

final class SeptemberInitial extends SeptemberState {}

class SeptemberContestLoadSuccessful extends SeptemberState {
  SeptemberContestData data;
  SeptemberContestLoadSuccessful(this.data);
}

class LoadingSeptemberState extends SeptemberState {}

class ErrorSeptemberState extends SeptemberState {}
