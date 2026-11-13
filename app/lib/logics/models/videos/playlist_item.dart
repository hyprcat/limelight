import 'package:lime_time_app/logics/models/videos/playlist.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

class PlayListItem {
  PlayList? playlist;
  VideoPost? video;
  String? addedAt;

  PlayListItem({this.playlist, this.video, this.addedAt});

  PlayListItem.fromJson(Map<String, dynamic> json) {
    playlist = PlayList.fromJson(json['playlist']);
    video = VideoPost.fromJson(json['video']);
    addedAt = json['addedAt'];
  }
}
