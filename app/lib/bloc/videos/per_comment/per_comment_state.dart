// ignore_for_file: must_be_immutable

part of 'per_comment_bloc.dart';

@immutable
abstract class PerCommentState {}

class PerCommentInitial extends PerCommentState {}

class SuccessCommentLoadState extends PerCommentState {
  Map<String, dynamic> map;
  SuccessCommentLoadState(this.map);
}

class ErrorCommentState extends PerCommentState {}

class LoadingComment extends PerCommentState {}
