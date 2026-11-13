import 'package:lime_time_app/logics/models/users/user_profile.dart';

class SeptemberContestData {
  UserProfile? user;
  int? subscriberCount;
  String? endDate;
  String? startDate;
  String? creationDate;

  SeptemberContestData(
      {this.user,
      this.subscriberCount,
      this.endDate,
      this.startDate,
      this.creationDate});

  SeptemberContestData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserProfile.fromJson(json['user']) : null;
    subscriberCount = json['subscriber_count'];
    endDate = json['end_date'];
    startDate = json['start_date'];
    creationDate = json['creation_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['subscriber_count'] = subscriberCount;
    data['end_date'] = endDate;
    data['start_date'] = startDate;
    data['creation_date'] = creationDate;
    return data;
  }
}
