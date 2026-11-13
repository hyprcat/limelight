part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

class VideoSearchState extends SearchState {
  final VideoRepo repo;

  VideoSearchState(this.repo);
}

class UserSearchState extends SearchState {
  final UserRepo repo;
  UserSearchState(this.repo);
}

class CommentSearchState extends SearchState {
  final VideoCommentRepo repo;
  CommentSearchState(this.repo);
}

class LoungePostSearchState extends SearchState {
  final PostRepo repo;
  LoungePostSearchState(this.repo);
}

class LoadingSearchResults extends SearchState {}

class SearchError extends SearchState {}
