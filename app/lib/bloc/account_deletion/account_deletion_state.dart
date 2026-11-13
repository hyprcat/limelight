part of 'account_deletion_bloc.dart';

@immutable
sealed class AccountDeletionState {}

final class AccountDeletionInitial extends AccountDeletionState {}

class AccDeletionPageSuccess extends AccountDeletionState {
  bool status;
  AccDeletionPageSuccess(this.status);
}

class AccDeletionError extends AccountDeletionState {}
