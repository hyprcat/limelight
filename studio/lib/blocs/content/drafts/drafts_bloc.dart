// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_arrow_creator_studio/engines/models/video_repo.dart';
import 'package:code_arrow_creator_studio/engines/video_engine.dart';
import 'package:meta/meta.dart';

part 'drafts_event.dart';
part 'drafts_state.dart';

class DraftsBloc extends Bloc<DraftsEvent, DraftsState> {
  DraftsBloc() : super(DraftsInitial()) {
    on<LoadDrafts>(loadDrafts);
  }

  String previous_type = "";
  VideoRepo draftsRepo = VideoRepo();
  FutureOr<void> loadDrafts(LoadDrafts event, Emitter<DraftsState> emit) async {
    emit(DraftsLoading());
    try {
      if (previous_type != event.type) {
        draftsRepo = VideoRepo();
      }
      VideoRepo tempRepo = await VideoEngine().loadDrafts(event.type, draftsRepo);
      draftsRepo = tempRepo;

      emit(LoadDraftsState(draftsRepo));
    } catch (e) {
      emit(DraftsErrorState());
    }
  }
}
