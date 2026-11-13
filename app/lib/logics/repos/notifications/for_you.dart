import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/notifications/notification_base.dart';
import 'package:lime_time_app/logics/models/notifications/promotion.dart';
import 'package:lime_time_app/logics/models/notifications/video_processed.dart';
import 'package:lime_time_app/screens/notifications/widgets/promotion.dart';

class ForYouRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<PromotionalNotification> promotions = [];
  List<VideoProcessedNotification> videoProcessed = [];

  ForYouRepo();

  Map<String, dynamic> toJson() {
    return {
      'promotions': promotions.map((promo) => promo.toJson()).toList(),
      'video_processed': videoProcessed.map((video) => video.toJson()).toList(),
    };
  }

  ForYouRepo.fromJson(List<dynamic> jsonList)
      : promotions = [],
        videoProcessed = [] {
    for (var item in jsonList) {
      switch (item['type']) {
        case 'promotion':
          promotions.add(PromotionalNotification.fromJson(item));
          break;
        case 'video_processed':
          videoProcessed.add(VideoProcessedNotification.fromJson(item));
          break;
      }
    }
  }

  List<Widget> getCombinedNotifications() {
    List<NotificationBase> combinedList = [
      ...promotions,
      ...videoProcessed,
    ];

    combinedList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

    return combinedList
        .map((notification) {
          if (notification is PromotionalNotification) {
            return PromotionPost(notification: notification);
          } else if (notification is VideoProcessedNotification) {
            return Container(
              height: 100,
              color: Colors.red,
            );
          } else {
            return const SizedBox.shrink(); // Fallback widget
          }
        })
        .toList()
        .reversed
        .toList();
  }

  void mergeNewRepo(ForYouRepo newRepo) {
    videoProcessed.addAll(newRepo.videoProcessed);
    promotions.addAll(newRepo.promotions);
    removeDuplicates();
  }

  void dump() {
    videoProcessed = [];
    promotions = [];
    currentPage = 1;
    lastPage = 1;
  }

  void removeDuplicates() {
    final seen = <int>{}; // Set to store seen pr
    final seen2 = <int>{}; // primary keys
    promotions.retainWhere((promo) => seen.add(promo.pk!));
    videoProcessed.retainWhere((video) => seen2.add(video.pk!));
  }
}
