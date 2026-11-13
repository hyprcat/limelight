import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';

import 'package:lime_time_app/logics/models/notifications/notification_base.dart';

class VideoCommentCreatedNotification extends NotificationBase {
  @override
  int? pk;
  @override
  String? type;
  UserProfile? receiver;
  String? message;
  @override
  String? creationDate;
  VideoComment? linkedComment; //
  bool? viewed;

  VideoCommentCreatedNotification(
      {this.pk,
      this.type,
      this.receiver,
      this.message,
      this.creationDate,
      this.linkedComment,
      this.viewed});

  @override
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'type': type,
      'receiver': receiver,
      'message': message,
      'creation_date': creationDate,
      'linked_comment': linkedComment,
      'viewed': viewed
    };
  }

  VideoCommentCreatedNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        creationDate = json['creation_date'],
        linkedComment = VideoComment.fromJson(json['linked_comment']),
        viewed = json['viewed'],
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
