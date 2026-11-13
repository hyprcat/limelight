import 'package:lime_time_app/logics/models/notifications/notification_base.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

class LoungePostNotification extends NotificationBase {
  @override
  int? pk;
  @override
  String? type;
  UserProfile? receiver;
  String? message;
  @override
  String? creationDate;
  bool? viewed;
  UserProfile? linkedLounge;

  LoungePostNotification({
    this.pk,
    this.type,
    this.receiver,
    this.message,
    this.creationDate,
    this.viewed,
    this.linkedLounge,
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
      'linked_lounge': linkedLounge,
    };
  }

  LoungePostNotification.fromJson(Map<String, dynamic> json)
      : pk = json['pk'],
        type = json['type'],
        receiver = UserProfile.fromJson(json['receiver']),
        message = json['message'],
        creationDate = json['creation_date'],
        viewed = json['viewed'],
        linkedLounge = UserProfile.fromJson(json['linked_lounge']),
        super(
            pk: json['pk'],
            type: json['type'],
            creationDate: json['creation_date']);
}
