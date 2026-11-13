import 'package:lime_time_app/logics/models/users/user_profile.dart';

class PlayList {
  String? playlistId;
  String? name;
  String? description;
  String? creationDate;
  UserProfile? createdBy;
  bool videoExistsInPlaylist = false;
  int? views;
  String? firstVideoId;
  int? videos;

  PlayList(
      {this.playlistId,
      this.name,
      this.description,
      this.creationDate,
      this.createdBy,
      this.views});

  PlayList.fromJson(Map<String, dynamic> json) {
    playlistId = json['playlist_id'];
    name = json['name'];
    description = json['description'];
    creationDate = json['creation_date'];
    createdBy = json['created_by'] != null
        ? UserProfile.fromJson(json['created_by'])
        : null;
    views = json['views'];
    firstVideoId = json['first_video'];
    videos = json['video_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['playlist_id'] = playlistId;
    data['name'] = name;
    data['description'] = description;
    data['creation_date'] = creationDate;
    if (createdBy != null) {
      data['created_by'] = createdBy!.toJson();
    }
    data['views'] = views;
    data['first_video'] = firstVideoId;
    data['video_count'] = videos;
    return data;
  }
}
