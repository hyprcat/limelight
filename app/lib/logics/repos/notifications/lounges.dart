import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/notifications/lounge_post_created.dart';
// ignore: unused_import
import 'package:lime_time_app/logics/models/notifications/video_processed.dart';

class LoungeNotificationRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<LoungePostNotification> loungePostNotification = [];

  LoungeNotificationRepo();

  Map<String, dynamic> toJson() {
    return {
      'promotions':
          loungePostNotification.map((promo) => promo.toJson()).toList(),
    };
  }

  LoungeNotificationRepo.fromJson(List<dynamic> jsonList)
      : loungePostNotification = [] {
    for (var item in jsonList) {
      if (item.isNotEmpty) {
        switch (item['type']) {
          case 'video_upload':
            loungePostNotification.add(LoungePostNotification.fromJson(item));
            break;
        }
      }
    }
  }

  List<Widget> getCombinedNotifications() {
    List<LoungePostNotification> combinedList = loungePostNotification;

    combinedList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

    return combinedList
        .map((notification) {
          return Container();
        })
        .toList()
        .reversed
        .toList();
  }

  void mergeNewRepo(LoungeNotificationRepo newRepo) {
    loungePostNotification.addAll(newRepo.loungePostNotification);
    removeDuplicates();
  }

  void dump() {
    loungePostNotification = [];
    currentPage = 1;
    lastPage = 1;
  }

  void removeDuplicates() {
    final seen = <int>{}; // Set to store seen primary keys
    loungePostNotification.retainWhere((promo) => seen.add(promo.pk!));
  }
}
