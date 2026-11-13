import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/notifications/notification_base.dart';
import 'package:lime_time_app/logics/models/notifications/lounge_post_created.dart';
import 'package:lime_time_app/logics/models/notifications/lounge_post_reply.dart';
import 'package:lime_time_app/logics/models/notifications/video_comment.dart';
import 'package:lime_time_app/logics/models/notifications/video_comment_reply.dart';
import 'package:lime_time_app/screens/notifications/widgets/lounge_post.dart';
import 'package:lime_time_app/screens/notifications/widgets/lounge_post_reply.dart';
import 'package:lime_time_app/screens/notifications/widgets/video_comment.dart';
import 'package:lime_time_app/screens/notifications/widgets/video_comment_reply.dart';

class ThreadNotifications {
  int currentPage = 1;
  int lastPage = 1;
  List<LoungePostReplyNotification> loungePostReply = [];
  List<VideoCommentReplyNotification> videoCommentReply = [];
  List<LoungePostNotification> loungeReply = [];
  List<VideoCommentCreatedNotification> videoComments = [];

  ThreadNotifications();

  Map<String, dynamic> toJson() {
    return {
      'promotions': loungePostReply.map((promo) => promo.toJson()).toList(),
      'video_processed':
          videoCommentReply.map((video) => video.toJson()).toList(),
    };
  }

  ThreadNotifications.fromJson(List<dynamic> jsonList)
      : loungePostReply = [],
        videoCommentReply = [] {
    for (var item in jsonList) {
      switch (item['type']) {
        case 'lounge_post_reply':
          loungePostReply.add(LoungePostReplyNotification.fromJson(item));
          break;
        case 'video_comment_reply':
          videoCommentReply.add(VideoCommentReplyNotification.fromJson(item));
          break;
        case 'video_comment_created':
          videoComments.add(VideoCommentCreatedNotification.fromJson(item));
          break;
        case 'lounge_post_created':
          loungeReply.add(LoungePostNotification.fromJson(item));
          break;
      }
    }
  }

  List<Widget> getCombinedNotifications() {
    List<NotificationBase> combinedList = [
      ...loungePostReply,
      ...videoCommentReply,
      ...loungeReply,
      ...videoComments
    ];

    combinedList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

    return combinedList
        .map((notification) {
          if (notification is LoungePostReplyNotification) {
            return LoungePostReplyWidget(notification: notification);
          } else if (notification is VideoCommentReplyNotification) {
            return VideoCommentReplyNotificationWidget(
                notification: notification); //
          } else if (notification is VideoCommentCreatedNotification) {
            return VideoCommentCreatedNotificationWidget(
                notification: notification); //
            // Fallback widget
          } else if (notification is LoungePostNotification) {
            return LoungePostNotificationWidget(
              notification: notification,
            );
          } else {
            return Container();
          }
        })
        .toList()
        .reversed
        .toList();
  }

  void mergeNewRepo(ThreadNotifications newRepo) {
    videoCommentReply.addAll(newRepo.videoCommentReply);
    loungePostReply.addAll(newRepo.loungePostReply);
    loungeReply.addAll(newRepo.loungeReply);
    videoComments.addAll(newRepo.videoComments);
    removeDuplicates();
  }

  void dump() {
    videoCommentReply = [];
    loungePostReply = [];
    loungeReply = [];
    videoComments = [];
    currentPage = 1;
    lastPage = 1;
  }

  void removeDuplicates() {
    final seen = <int>{};
    final seen2 = <int>{};
    final seen3 = <int>{};
    final seen4 = <int>{};
    loungePostReply.retainWhere((obj) => seen.add(obj.pk!));
    videoCommentReply.retainWhere((obj) => seen2.add(obj.pk!));
    loungeReply.retainWhere((obj) => seen3.add(obj.pk!));
    videoComments.retainWhere((obj) => seen4.add(obj.pk!));
  }
}
