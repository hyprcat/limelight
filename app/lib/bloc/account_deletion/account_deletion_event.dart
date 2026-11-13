part of 'account_deletion_bloc.dart';

@immutable
sealed class AccountDeletionEvent {}

class LoadAccountDeletionEvent extends AccountDeletionEvent {}
