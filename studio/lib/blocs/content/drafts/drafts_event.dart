part of 'drafts_bloc.dart';

@immutable
abstract class DraftsEvent {}

class LoadDrafts extends DraftsEvent {
  String type;

  LoadDrafts(this.type);
}
