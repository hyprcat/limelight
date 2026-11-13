import 'package:lime_time_app/logics/models/notifications/notification_base.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

class VideoProcessedNotification extends NotificationBase {
  @override
  int? pk;
  @override
  String? type;
  UserProfile? receiver;
  String? message;
  @override
  String? creationDate;
  bool? viewed;
  VideoPost? linkedVideo;

  VideoProcessedNotification(
      {this.pk,
      this.type,
      this.receiver,
      this.message,
      this.creationDate,
      this.linkedVideo,
      this.viewed});

  @override
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'type': type,
      'receiver': receiver,
      'message': message,
      'creation_date': creationDate,
      'linked_video': linkedVideo,
      'viewed': viewed
    };
  }

  VideoProcessedNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        creationDate = json['creation_date'],
        linkedVideo = VideoPost.fromJson(json['linked_video']),
        viewed = json['viewed'],
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
