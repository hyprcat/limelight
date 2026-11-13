// ignore_for_file: must_be_immutable

part of 'edit_draft_bloc.dart';

@immutable
abstract class EditDraftState {}

class EditDraftInitial extends EditDraftState {}

class Loading extends EditDraftState {}

class ErrorEditDraft extends EditDraftState {}

class EditDraftStartSuccess extends EditDraftState {}

class SaveOneSuccess extends EditDraftState {
  VideoPost video;

  SaveOneSuccess(this.video);
}

class SaveTwoSuccess extends EditDraftState {}

class SaveThreeSuccess extends EditDraftState {}
