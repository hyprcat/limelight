import 'dart:math';

import 'package:hive/hive.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';

import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';

part 'lounge.g.dart';

@HiveType(typeId: 3)
class UserLounge {
  @HiveField(0)
  String? id;
  @HiveField(1)
  int? totalMembers;
  @HiveField(2)
  int? totalCategories;
  @HiveField(3)
  String? loungeDescription;
  @HiveField(4)
  int? loungeTiers;
  @HiveField(5)
  String? name;
  @HiveField(6)
  List<LoungeCategory>? categories;
  @HiveField(7)
  List<LoungeSection>? sections;
  @HiveField(8)
  int? xP;
  @HiveField(9)
  int? level;
  @HiveField(10)
  bool? isPublic = false;
  bool isLocked = false;

  UserLounge(
      {this.id,
      this.totalMembers,
      this.totalCategories,
      this.loungeDescription,
      this.loungeTiers,
      this.name,
      this.categories,
      this.sections,
      this.xP,
      this.level,
      this.isPublic});

  UserLounge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalMembers = json['total_members'];
    totalCategories = json['total_categories'];
    loungeDescription = json['lounge_description'];
    loungeTiers = json['lounge_tiers'];
    name = json['name'];
    xP = json['xp'];
    level = json['level'];
    isPublic = json['is_public'];
    if (json['categories'] != null) {
      categories = <LoungeCategory>[];
      json['categories'].forEach((v) {
        categories!.add(LoungeCategory.fromJson(v));
      });
    }
    if (json['sections'] != null) {
      sections = <LoungeSection>[];
      json['sections'].forEach((v) {
        sections!.add(LoungeSection.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['total_members'] = totalMembers;
    data['total_categories'] = totalCategories;
    data['lounge_description'] = loungeDescription;
    data['lounge_tiers'] = loungeTiers;
    data['name'] = name;
    data['xp'] = xP;
    data['level'] = level;
    data['is_public'] = isPublic;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
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
