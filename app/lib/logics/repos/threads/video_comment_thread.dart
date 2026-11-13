import 'package:lime_time_app/logics/models/videos/video_comment.dart';

import 'package:lime_time_app/logics/models/videos/video_post.dart';

class VideoCommentThread {
  VideoPost? linkedVideo;
  List<VideoComment>? posts;

  VideoCommentThread({this.linkedVideo, this.posts});

  VideoCommentThread.fromJson(Map<String, dynamic> json) {
    linkedVideo = json['linked_video'] != null
        ? VideoPost.fromJson(json['linked_video'])
        : null;
    if (json['posts'] != null) {
      posts = <VideoComment>[];
      json['posts'].forEach((v) {
        posts!.add(VideoComment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (linkedVideo != null) {
      data['linked_video'] = linkedVideo!.toJson();
    }
    if (posts != null) {
      data['posts'] = posts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
