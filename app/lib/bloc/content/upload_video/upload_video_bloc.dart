// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

import 'package:meta/meta.dart';

part 'upload_video_event.dart';
part 'upload_video_state.dart';

class UploadVideoBloc extends Bloc<UploadVideoEvent, UploadVideoState> {
  UploadVideoBloc() : super(UploadVideoInitial()) {
    on<LoadSection>(loadSection);
    on<SelectVideoEvent>(selectVideo);
    on<UploadVideo>(uploadVideo);
  }

  FutureOr<void> loadSection(
      LoadSection event, Emitter<UploadVideoState> emit) async {
    emit(UploadVideoInitial());
  }

  FutureOr<void> selectVideo(
      SelectVideoEvent event, Emitter<UploadVideoState> emit) {
    emit(SectionLoading());
  }

  FutureOr<void> uploadVideo(
      UploadVideo event, Emitter<UploadVideoState> emit) async {
    emit(SectionLoading());
    try {
      emit(UploadMetaInformationState(event.video));
    } catch (e) {
      rethrow;
    }
  }
}
