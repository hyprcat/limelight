import 'package:lime_time_app/logics/models/notifications/notification_base.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

class VideoUploadNotification extends NotificationBase {
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
  bool? notificationSent;

  VideoUploadNotification({
    this.pk,
    this.type,
    this.receiver,
    this.message,
    this.creationDate,
    this.viewed,
    this.linkedVideo,
    this.notificationSent,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'type': type,
      'receiver': receiver,
      'message': message,
      'creation_date': creationDate,
      'viewed': viewed,
      'linked_video': linkedVideo,
      'notification_sent': notificationSent,
    };
  }

  VideoUploadNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        creationDate = json['creation_date'],
        viewed = json['viewed'],
        linkedVideo = VideoPost.fromJson(json['linked_video']),
        notificationSent = json['notification_sent'],
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
