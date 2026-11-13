import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_participant.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';

class Post {
  String? id = "";
  UserLounge? userLounge;
  UserProfile? userProfile;
  String? text;
  String? attachment;
  int? likes;
  int? dislikes;
  int? replies;
  int? topicId;
  double? xp;
  int? topicCategoryId;
  int? postSentiment;
  int? impressions;
  bool? isAdvertisement;
  String? rootPost;
  String? parentPost;
  int? postDepth;
  String? creationDate;
  LoungeSection? associatedLoungeSection;
  LoungeParticipant? createdBy;
  Map<String, dynamic>? interactionStatus;
  List<UserProfile>? topTwoUsers = [];

  Post(
      {this.id,
      this.userLounge,
      this.userProfile,
      this.text,
      this.attachment,
      this.likes,
      this.dislikes,
      this.replies,
      this.topicId,
      this.topicCategoryId,
      this.postSentiment,
      this.impressions,
      this.isAdvertisement,
      this.rootPost,
      this.parentPost,
      this.postDepth,
      this.xp,
      this.creationDate,
      this.topTwoUsers,
      this.associatedLoungeSection,
      this.createdBy});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userLounge = json['user_lounge'] != null
        ? UserLounge.fromJson(json['user_lounge'])
        : null;
    userProfile = json['user_profile'] != null
        ? UserProfile.fromJson(json['user_profile'])
        : null;
    text = json['text'];
    attachment = json['attachment'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    replies = json['replies'];
    xp = double.parse(json['xp'].toString());
    topicId = json['topic_id'];
    topicCategoryId = json['topic_category_id'];
    postSentiment = json['post_sentiment'];
    impressions = json['impressions'];
    isAdvertisement = json['is_advertisement'];
    rootPost = json['root_post'];
    parentPost = json['parent_post'];
    postDepth = json['post_depth'];
    creationDate = json['creation_date'];
    associatedLoungeSection = json['associated_lounge_section'] != null
        ? LoungeSection.fromJson(json['associated_lounge_section'])
        : null;
    createdBy = json['created_by'] != null
        ? LoungeParticipant.fromJson(json['created_by'])
        : null;
    interactionStatus = json['reaction_status'];
    for (var i in json['top_comments_by']) {
      var user = UserProfile.fromJson(i);
      topTwoUsers?.add(user);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (userLounge != null) {
      data['user_lounge'] = userLounge!.toJson();
    }
    if (userProfile != null) {
      data['user_profile'] = userProfile!.toJson();
    }
    data['text'] = text;
    data['attachment'] = attachment;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    data['replies'] = replies;
    data['topic_id'] = topicId;
    data['topic_category_id'] = topicCategoryId;
    data['post_sentiment'] = postSentiment;
    data['impressions'] = impressions;
    data['xp'] = xp;
    data['is_advertisement'] = isAdvertisement;
    data['root_post'] = rootPost;
    data['parent_post'] = parentPost;
    data['post_depth'] = postDepth;
    data['creation_date'] = creationDate;
    if (associatedLoungeSection != null) {
      data['associated_lounge_section'] = associatedLoungeSection!.toJson();
    }
    if (createdBy != null) {
      data['created_by'] = createdBy!.toJson();
    }
    return data;
  }
}
