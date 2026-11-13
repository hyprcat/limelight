import 'dart:math';

import 'package:hive/hive.dart';

part 'user_channel.g.dart';

@HiveType(typeId: 2)
class UserChannel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? channelDescription;
  @HiveField(3)
  int? subscriberCount;
  @HiveField(4)
  int? videosCount;
  @HiveField(5)
  int? level;
  @HiveField(6)
  int? xP;
  @HiveField(7)
  String? metricsLastUpdated;

  UserChannel(
      {this.id,
      this.name,
      this.channelDescription,
      this.subscriberCount,
      this.videosCount,
      this.level,
      this.xP,
      this.metricsLastUpdated});

  UserChannel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    channelDescription = json['channel_description'];
    subscriberCount = json['subscriber_count'];
    videosCount = json['videos_count'];
    level = json['level'];
    xP = json['XP'];
    metricsLastUpdated = json['metrics_last_updated'];
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_new
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['channel_description'] = channelDescription;
    data['subscriber_count'] = subscriberCount;
    data['videos_count'] = videosCount;
    data['level'] = level;
    data['XP'] = xP;
    data['metrics_last_updated'] = metricsLastUpdated;
    return data;
  }

  int getExperiencePointsForLevel(int level,
      {int basePoints = 50, int multiplier = 2}) {
    return (basePoints * (pow(multiplier, level))).toInt();
  }

  int experienceNeededForLevelUp(int currentExp,
      {int basePoints = 50, int multiplier = 2}) {
    int currentLevel = 1;
    int nextLevelPoints = getExperiencePointsForLevel(currentLevel + 1,
        basePoints: basePoints, multiplier: multiplier);
    return nextLevelPoints;
  }

  int generateLevel(int userExp, {int basePoints = 50, int multiplier = 2}) {
    if (userExp <
        getExperiencePointsForLevel(1,
            basePoints: basePoints, multiplier: multiplier)) {
      return 0;
    }
    int level = 2;
    int startExp = experienceNeededForLevelUp(level);
    while (userExp >= startExp) {
      level += 1;
      startExp = getExperiencePointsForLevel(level,
          basePoints: basePoints, multiplier: multiplier);
    }
    return level;
  }
}
