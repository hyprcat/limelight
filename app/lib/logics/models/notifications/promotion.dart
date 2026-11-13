import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/logics/models/notifications/notification_base.dart';

class PromotionalNotification extends NotificationBase {
  @override
  int? pk;
  @override
  String? type;
  UserProfile? receiver;
  String? message;
  String? title;
  @override
  String? creationDate;
  bool? viewed;

  PromotionalNotification(
      {this.pk,
      this.type,
      this.receiver,
      this.message,
      this.title,
      this.creationDate,
      this.viewed});

  @override
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'type': type,
      'receiver': receiver,
      'message': message,
      'title': title,
      'creation_date': creationDate,
      'viewed': viewed
    };
  }

  PromotionalNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        title = json['title'],
        creationDate = json['creation_date'],
        viewed = json['viewed'],
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
