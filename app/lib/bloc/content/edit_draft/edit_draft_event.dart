// ignore_for_file: camel_case_types

part of 'edit_draft_bloc.dart';

@immutable
abstract class EditDraftEvent {}

class LoadDraft extends EditDraftEvent {}

class InitialSave extends EditDraftEvent {}

class SaveDraft_I extends EditDraftEvent {
  final String title;
  final String description;
  final MultipartFile? thumbnail;
  final bool isPaidPromotion;
  final bool isAgeRestricted;
  final String topic;
  final dynamic data;

  SaveDraft_I(
      {required this.title,
      required this.description,
      required this.thumbnail,
      required this.isPaidPromotion,
      required this.isAgeRestricted,
      required this.topic,
      required this.data});
}

class SaveDraft_II extends EditDraftEvent {}

class SaveDraft_III extends EditDraftEvent {}
