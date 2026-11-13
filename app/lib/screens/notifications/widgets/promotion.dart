import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/models/notifications/promotion.dart';

class PromotionPost extends StatefulWidget {
  final PromotionalNotification notification;

  const PromotionPost({super.key, required this.notification});

  @override
  State<PromotionPost> createState() => _PromotionPostState();
}

class _PromotionPostState extends State<PromotionPost> {
  void markAsSeen() {
    NotifierEngine().markNotificationAsSeen({
      'object_type': widget.notification.type,
      'object_id': widget.notification.pk
    });
  }

  @override
  void initState() {
    super.initState();
    markAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.notification.viewed!
              ? Theme.of(context).canvasColor
              : Theme.of(context).dividerColor.withAlpha(400),
          border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1))),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.notification.title!,
                style: defaultSmallXLabelCustom(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary)),
            Text(widget.notification.message!,
                style: defaultSmallXLabelCustom(context)),
            Text(
              formatTimeAgo(widget.notification.creationDate!),
              style: defaultSmallXLabelCustom(context,
                  fontColor: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
