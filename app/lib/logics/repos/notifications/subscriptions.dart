import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/notifications/video_processed.dart';
import 'package:lime_time_app/logics/models/notifications/video_upload.dart';
import 'package:lime_time_app/screens/notifications/widgets/video_processed_notification.dart';
import 'package:lime_time_app/screens/notifications/widgets/video_upload_notification.dart';

import 'package:lime_time_app/logics/models/notifications/notification_base.dart';

class SubscriptionsRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<VideoUploadNotification> subscriptions = [];

  SubscriptionsRepo();

  Map<String, dynamic> toJson() {
    return {
      'promotions': subscriptions.map((promo) => promo.toJson()).toList(),
    };
  }

  SubscriptionsRepo.fromJson(List<dynamic> jsonList) : subscriptions = [] {
    for (var item in jsonList) {
      if (item.isNotEmpty) {
        switch (item['type']) {
          case 'video_upload':
            subscriptions.add(VideoUploadNotification.fromJson(item));
            break;
        }
      }
    }
  }

  List<Widget> getCombinedNotifications() {
    if (subscriptions.isEmpty) {
      return [const Center(child: Text("ssup"))];
    }

    List<NotificationBase> combinedList = subscriptions;

    combinedList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

    return combinedList
        .map((notification) {
          if (notification is VideoUploadNotification) {
            return VideoUploadNotificationWidget(notification: notification); //
          } else if (notification is VideoProcessedNotification) {
            return VideoProcessedNotificationWidget(
              notification: notification,
            );
          } else {
            return const SizedBox.shrink(); // Fallback widget
          }
        })
        .toList()
        .reversed
        .toList();
  }

  void mergeNewRepo(SubscriptionsRepo newRepo) {
    subscriptions.addAll(newRepo.subscriptions);
    removeDuplicates();
  }

  void dump() {
    subscriptions = [];
    currentPage = 1;
    lastPage = 1;
  }

  void removeDuplicates() {
    final seen = <int>{}; // Set to store seen primary keys
    subscriptions.retainWhere((promo) => seen.add(promo.pk!));
  }
}
