// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:meta/meta.dart';

part 'edit_draft_event.dart';
part 'edit_draft_state.dart';

class EditDraftBloc extends Bloc<EditDraftEvent, EditDraftState> {
  EditDraftBloc() : super(EditDraftInitial()) {
    on<SaveDraft_I>(savePartI);
    on<SaveDraft_II>(savePartII);
    on<SaveDraft_III>(savePartIII);
    on<InitialSave>(initialSave);
  }

  FutureOr<void> savePartI(
      SaveDraft_I event, Emitter<EditDraftState> emit) async {
    try {
      emit(Loading());
      var response = await VideoEngine().saveDraft_I(event.data);
      final VideoPost video =
          await VideoEngine().getVideoInfo(event.data['video_id']);
      if (response == "success") {
        emit(SaveOneSuccess(video));
      } else {
        emit(ErrorEditDraft());
      }
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> savePartII(SaveDraft_II event, Emitter<EditDraftState> emit) {}

  FutureOr<void> savePartIII(
      SaveDraft_III event, Emitter<EditDraftState> emit) {}

  FutureOr<void> initialSave(InitialSave event, Emitter<EditDraftState> emit) {}
}
