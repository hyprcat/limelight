import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

class LoungeParticipant {
  UserLounge? lounge;
  UserProfile? member;
  int? level;
  int? xp;
  int? challengesCompleted;

  LoungeParticipant(
      {this.lounge,
      this.member,
      this.level,
      this.xp,
      this.challengesCompleted});

  LoungeParticipant.fromJson(Map<String, dynamic> json) {
    lounge =
        json['lounge'] != null ? UserLounge.fromJson(json['lounge']) : null;
    member =
        json['member'] != null ? UserProfile.fromJson(json['member']) : null;
    level = json['level'];
    xp = json['xp'];
    challengesCompleted = json['challenges_completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lounge != null) {
      data['lounge'] = lounge!.toJson();
    }
    if (member != null) {
      data['member'] = member!.toJson();
    }
    data['level'] = level;
    data['xp'] = xp;
    data['challenges_completed'] = challengesCompleted;
    return data;
  }
}
