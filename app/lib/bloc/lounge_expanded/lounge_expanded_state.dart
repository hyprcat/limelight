part of 'lounge_expanded_bloc.dart';

@immutable
sealed class LoungeExpandedState {}

final class LoungeExpandedInitial extends LoungeExpandedState {}

class LoadingExpanded extends LoungeExpandedState {}

class PostFetchedSuccess extends LoungeExpandedState {
  final PostRepo repo;
  PostFetchedSuccess(this.repo);
}

class UsersFetchedSuccess extends LoungeExpandedState {
  final UserRepo repo;
  UsersFetchedSuccess(this.repo);
}

class ExpandedError extends LoungeExpandedState {}
