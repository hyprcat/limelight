part of 'lounge_expanded_bloc.dart';

@immutable
sealed class LoungeExpandedEvent {}

class LoadMorePosts extends LoungeExpandedEvent {
  final String endpoint;
  LoadMorePosts(this.endpoint);
}

class LoadMoreUsers extends LoungeExpandedEvent {
  final String endpoint;
  LoadMoreUsers(this.endpoint);
}
