// ignore_for_file: must_be_immutable

part of 'drafts_bloc.dart';

@immutable
abstract class DraftsState {}

class DraftsInitial extends DraftsState {}

class DraftsLoading extends DraftsState {}

class LoadDraftsState extends DraftsState {
  VideoRepo repo;
  LoadDraftsState(this.repo);
}

class DraftsErrorState extends DraftsState {}
