// ignore_for_file: must_be_immutable

part of 'upload_video_bloc.dart';

@immutable
abstract class UploadVideoEvent {}

class LoadSection extends UploadVideoEvent {}

class SelectVideoEvent extends UploadVideoEvent {}

class SelectFileEvent extends UploadVideoEvent {}

class UploadVideo extends UploadVideoEvent {
  VideoPost video;
  UploadVideo(this.video);
}

class UploadMetaInformation extends UploadVideoEvent {}

class UploadSubtitles extends UploadVideoEvent {}

class CheckCopyright extends UploadVideoEvent {}
