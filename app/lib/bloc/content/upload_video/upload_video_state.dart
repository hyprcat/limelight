// ignore_for_file: must_be_immutable

part of 'upload_video_bloc.dart';

@immutable
abstract class UploadVideoState {}

class UploadVideoInitial extends UploadVideoState {}

class SectionLoading extends UploadVideoState {}

class SelectVideoState extends UploadVideoState {}

class SelectFileState extends UploadVideoState {}

class UploadMetaInformationState extends UploadVideoState {
  VideoPost video;
  UploadMetaInformationState(this.video);
}

class UploadSubtitlesState extends UploadVideoState {}

class CheckCopyrightState extends UploadVideoState {}

class PublishScreen extends UploadVideoState {}
