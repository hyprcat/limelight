part of 'lounge_section_bloc.dart';

@immutable
abstract class LoungeSectionEvent {}

class LoadSectionPosts extends LoungeSectionEvent {
  final LoungeSection section;
  final String endPoint;
  final Post? post;
  LoadSectionPosts(this.section, this.endPoint, this.post);
}

class LoadThreadedPosts extends LoungeSectionEvent {
  final bool refresh;
  LoadThreadedPosts(this.refresh);
}

class RemoveLoungePost extends LoungeSectionEvent {
  final String postId;
  final bool isRootPost;
  RemoveLoungePost(this.postId, this.isRootPost);
}

class AddLoungePost extends LoungeSectionEvent {
  final Map data;
  AddLoungePost(this.data);
}
