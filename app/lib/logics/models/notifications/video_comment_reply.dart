import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';

import 'package:lime_time_app/logics/models/notifications/notification_base.dart';

class VideoCommentReplyNotification extends NotificationBase {
  @override
  int? pk;
  @override
  String? type;
  UserProfile? receiver;
  String? message;
  @override
  String? creationDate;
  bool? viewed;
  VideoComment? replyComment;
  VideoComment? repliedTo;

  VideoCommentReplyNotification({
    this.pk,
    this.type,
    this.receiver,
    this.message,
    this.creationDate,
    this.viewed,
    this.replyComment,
    this.repliedTo,
  }) : super(pk: pk, type: type, creationDate: creationDate);

  @override
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'type': type,
      'receiver': receiver,
      'message': message,
      'creation_date': creationDate,
      'viewed': viewed,
      'reply_comment': replyComment,
      'replied_to': repliedTo,
    };
  }

  VideoCommentReplyNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        creationDate = json['creation_date'],
        viewed = json['viewed'],
        replyComment = VideoComment.fromJson(json['reply_comment']),
        repliedTo = VideoComment.fromJson(json['replied_to']),
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
