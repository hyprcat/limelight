import 'package:hive/hive.dart';
import 'package:lime_time_app/logics/models/users/user_channel.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

import 'package:lime_time_app/logics/models/lounge/lounge.dart';
part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  int? userId;

  @HiveField(1)
  String? userName;

  @HiveField(2)
  String? userEmail;

  @HiveField(3)
  int? age;

  @HiveField(4)
  String? bio;

  @HiveField(5)
  String? gender;

  @HiveField(6)
  String? profilePicture;

  @HiveField(7)
  String? profileBanner;

  @HiveField(8)
  int? joinedCommunities;

  @HiveField(9)
  String? creationDate;

  @HiveField(10)
  bool? isCreator;

  @HiveField(11)
  bool? isAdvertisor;

  @HiveField(12)
  UserChannel? userChannel;

  @HiveField(13)
  UserLounge? userLounge;

  VideoPost? topVideo;
  VideoComment? topComment;
  bool? subscribedByCurrentUser;
  bool isBlockedByLoggedInUser = false;
  bool? isBanned;
  bool isReversedBanned = false;

  UserProfile(
      {this.userId,
      this.userName,
      this.userEmail,
      this.age,
      this.bio,
      this.gender,
      this.profilePicture,
      this.profileBanner,
      this.joinedCommunities,
      this.creationDate,
      this.isCreator,
      this.isAdvertisor,
      this.isBanned,
      this.userChannel,
      this.userLounge});

  UserProfile.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    if (json['age'] != null) {
      age = int.parse(json['age']);
    } else {
      age = 0;
    }

    bio = json['bio'];
    gender = json['gender'];
    profilePicture = json['profile_picture'];
    profileBanner = json['profile_banner'];

    if (json['joined_communities'] != null) {
      joinedCommunities = int.parse(json['joined_communities']);
    } else {
      joinedCommunities = 0;
    }
    creationDate = json['creation_date'];
    isCreator = json['is_creator'];
    isAdvertisor = json['is_advertisor'];

    isBlockedByLoggedInUser = json['block_status'] ?? false;
    isReversedBanned = json['reverse_block'] ?? false;
    subscribedByCurrentUser = json['subscription_status'];
    userChannel = json['user_channel'] != null
        ? UserChannel.fromJson(json['user_channel'])
        : null;
    userLounge = json['user_lounge'] != null
        ? UserLounge.fromJson(json['user_lounge'])
        : null;
    isBanned = json['is_banned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['age'] = age;
    data['bio'] = bio;
    data['gender'] = gender;
    data['profile_picture'] = profilePicture;
    data['profile_banner'] = profileBanner;
    data['joined_communities'] = joinedCommunities;
    data['creation_date'] = creationDate;
    data['is_creator'] = isCreator;
    data['is_advertisor'] = isAdvertisor;
    data['subscription_status'] = subscribedByCurrentUser;
    data['block_status'] = isBlockedByLoggedInUser;
    data['reverse_block'] = isReversedBanned;
    data['is_banned'] = isBanned;
    if (userChannel != null) {
      data['user_channel'] = userChannel!.toJson();
    }
    if (userLounge != null) {
      data['user_lounge'] = userLounge!.toJson();
    }
    return data;
  }
}
