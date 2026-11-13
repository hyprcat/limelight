// ignore_for_file: must_be_immutable

part of 'lounge_section_bloc.dart';

@immutable
abstract class LoungeSectionState {}

class LoungeSectionInitial extends LoungeSectionState {}

class PostLoadSuccess extends LoungeSectionState {
  PostRepo repo;
  PostLoadSuccess(this.repo);
}

class PostLoadError extends LoungeSectionState {}

class PostsLoading extends LoungeSectionState {}

class RefreshRootPosts extends LoungeSectionState {}

class RefreshFollowUp extends LoungeSectionState {}

class PostAdded extends LoungeSectionState {
  final String message;

  PostAdded(this.message);
}

class PostAddingError extends LoungeSectionState {
  final String error;

  PostAddingError({required this.error});
}

class PostDeletionSuccess extends LoungeSectionState {}

class PostDeletionError extends LoungeSectionState {}
