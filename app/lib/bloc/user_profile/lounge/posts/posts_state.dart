// ignore_for_file: must_be_immutable

part of 'posts_bloc.dart';

@immutable
abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostMessageDeliver extends PostsState {
  final String message;

  PostMessageDeliver(this.message);
}

class PostLoadSuccess extends PostsState {
  Map<String, dynamic> map;
  PostLoadSuccess(this.map);
}

class PostError extends PostsState {
  final String error;

  PostError({required this.error});
}

class LoadingPost extends PostsState {}
