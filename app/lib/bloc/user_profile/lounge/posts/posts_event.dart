// ignore_for_file: must_be_immutable

part of 'posts_bloc.dart';

@immutable
abstract class PostsEvent {}

class LoadPost extends PostsEvent {}

class LikePost extends PostsEvent {
  Post post;
  LikePost(this.post);
}

class DislikePost extends PostsEvent {
  Post post;
  DislikePost(this.post);
}

class RemoveLike extends PostsEvent {
  Post post;
  RemoveLike(this.post);
}

class RemoveDislike extends PostsEvent {
  Post post;
  RemoveDislike(this.post);
}
