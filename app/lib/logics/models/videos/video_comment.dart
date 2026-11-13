import 'package:lime_time_app/logics/models/users/user_profile.dart';

class VideoComment {
  String? id = '';
  String? videoId;
  String? comment;
  UserProfile? commentedBy;
  int? replies;
  int? likes;
  int? dislikes;
  int? commentSentiment;
  String? rootCommentId;
  bool? isReply;
  String? creationDate;
  Map<String, dynamic>? interactionStatus;
  List<UserProfile>? topTwoUsers = [];
  String? parentCommentId;
  int? commentDepth;

  VideoComment(
      {this.id,
      this.videoId,
      this.comment,
      this.commentedBy,
      this.replies,
      this.likes,
      this.dislikes,
      this.commentSentiment,
      this.rootCommentId,
      this.isReply,
      this.creationDate,
      this.topTwoUsers});

  VideoComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoId = json['video_id'];
    comment = json['comment'];
    commentedBy = json['commented_by'] != null
        ? UserProfile.fromJson(json['commented_by'])
        : null;
    replies = json['replies'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    commentSentiment = json['comment_sentiment'];
    rootCommentId = json['root_comment_id'];
    isReply = json['is_reply'];
    creationDate = json['creation_date'];
    interactionStatus = json['reaction_status'];
    parentCommentId = json['parent_comment_id'];
    commentDepth = json['comment_depth'];
    if (json['top_comments_by'] != null) {
      for (var i in json['top_comments_by']) {
        var user = UserProfile.fromJson(i);
        topTwoUsers?.add(user);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['video_id'] = videoId;
    data['comment'] = comment;
    if (commentedBy != null) {
      data['commented_by'] = commentedBy!.toJson();
    }
    data['replies'] = replies;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    data['comment_sentiment'] = commentSentiment;
    data['root_comment_id'] = rootCommentId;
    data['is_reply'] = isReply;
    data['creation_date'] = creationDate;
    data['reaction_status'] = interactionStatus;
    data['parent_comment_id'] = parentCommentId;
    data['commentDepth'] = commentDepth;
    return data;
  }
}
