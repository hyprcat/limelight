part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

class LoadInitial extends SearchEvent {}

class SearchVideos extends SearchEvent {
  final String query;

  SearchVideos(this.query);
}

class SearchUsers extends SearchEvent {
  final String query;

  SearchUsers(this.query);
}

class SearchComments extends SearchEvent {
  final String query;

  SearchComments(this.query);
}

class SearchLoungePosts extends SearchEvent {
  final String query;

  SearchLoungePosts(this.query);
}
