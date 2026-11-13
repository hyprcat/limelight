import 'package:code_arrow_creator_studio/engines/models/user_profile.dart';

class VideoPost {
  String? id;
  String? thumbnail;
  String? title;
  String? videoFileOriginalName;
  String? videoFile;
  String? videoDescription;
  UserProfile? videoCreator;
  int? videoDurationSeconds;
  int? impressions;
  int? likes;
  int? dislikes;
  int? comments;
  int? views;
  int? videoXp;
  String? creationDate;
  bool? isAdvertisement;
  bool? isDraft;
  bool? isUnlisted;
  bool? isLoungeOnly;
  bool? isAgeRestricted;
  bool? isScheduled;
  String? scheduledDate;
  bool? containsPaidPromotion;
  int? topicId;
  int? topicCategoryId;
  String? language;
  String? transcript;
  int? transcriptSentiment;
  int? descriptionSentiment;
  String? metricsLastUpdated;
  bool? isActive;

  VideoPost(
      {this.id,
      this.thumbnail,
      this.title,
      this.videoFileOriginalName,
      this.videoFile,
      this.videoDescription,
      this.videoCreator,
      this.videoDurationSeconds,
      this.impressions,
      this.likes,
      this.dislikes,
      this.comments,
      this.views,
      this.videoXp,
      this.creationDate,
      this.isAdvertisement,
      this.isDraft,
      this.isUnlisted,
      this.isLoungeOnly,
      this.isAgeRestricted,
      this.isScheduled,
      this.scheduledDate,
      this.containsPaidPromotion,
      this.topicId,
      this.topicCategoryId,
      this.language,
      this.transcript,
      this.transcriptSentiment,
      this.descriptionSentiment,
      this.metricsLastUpdated,
      this.isActive});

  VideoPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    thumbnail = json['thumbnail'];
    title = json['title'];
    videoFileOriginalName = json['video_file_original_name'];
    videoFile = json['video_file'];
    videoDescription = json['video_description'];
    videoCreator = json['video_creator'] != null ? UserProfile.fromJson(json['video_creator']) : null;
    videoDurationSeconds = json['video_duration_seconds'];
    impressions = json['impressions'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    comments = json['comments'];
    views = json['views'];
    videoXp = json['video_xp'];
    creationDate = json['creation_date'];
    isAdvertisement = json['is_advertisement'];
    isDraft = json['is_draft'];
    isUnlisted = json['is_unlisted'];
    isLoungeOnly = json['is_lounge_only'];
    isAgeRestricted = json['is_age_restricted'];
    isScheduled = json['is_scheduled'];
    scheduledDate = json['scheduled_date'];
    containsPaidPromotion = json['contains_paid_promotion'];
    topicId = json['topic_id'];
    topicCategoryId = json['topic_category_id'];
    language = json['language'];
    transcript = json['transcript'];
    transcriptSentiment = json['transcript_sentiment'];
    descriptionSentiment = json['description_sentiment'];
    metricsLastUpdated = json['metrics_last_updated'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['thumbnail'] = thumbnail;
    data['title'] = title;
    data['video_file_original_name'] = videoFileOriginalName;
    data['video_file'] = videoFile;
    data['video_description'] = videoDescription;
    if (videoCreator != null) {
      data['video_creator'] = videoCreator!.toJson();
    }
    data['video_duration_seconds'] = videoDurationSeconds;
    data['impressions'] = impressions;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    data['comments'] = comments;
    data['views'] = views;
    data['video_xp'] = videoXp;
    data['creation_date'] = creationDate;
    data['is_advertisement'] = isAdvertisement;
    data['is_draft'] = isDraft;
    data['is_unlisted'] = isUnlisted;
    data['is_lounge_only'] = isLoungeOnly;
    data['is_age_restricted'] = isAgeRestricted;
    data['is_scheduled'] = isScheduled;
    data['scheduled_date'] = scheduledDate;
    data['contains_paid_promotion'] = containsPaidPromotion;
    data['topic_id'] = topicId;
    data['topic_category_id'] = topicCategoryId;
    data['language'] = language;
    data['transcript'] = transcript;
    data['transcript_sentiment'] = transcriptSentiment;
    data['description_sentiment'] = descriptionSentiment;
    data['metrics_last_updated'] = metricsLastUpdated;
    data['is_active'] = isActive;
    return data;
  }

  String getStatus() {
    if (isAdvertisement == true) {
      return "Advertisement";
    } else if (isDraft == true) {
      return "Draft";
    } else if (isUnlisted == true) {
      return "Unlisted";
    } else if (isLoungeOnly == true) {
      return "Lounge Only";
    } else if (isAgeRestricted == true) {
      return "Age Restricted";
    } else if (isScheduled == true) {
      return "Scheduled";
    } else if (isActive == true) {
      return "Active";
    } else {
      return "Unknown";
    }
  }
}
