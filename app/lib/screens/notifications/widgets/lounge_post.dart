import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/models/notifications/lounge_post_created.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';

class LoungePostNotificationWidget extends StatefulWidget {
  final LoungePostNotification notification;

  const LoungePostNotificationWidget({super.key, required this.notification});

  @override
  State<LoungePostNotificationWidget> createState() => _PromotionPostState();
}

class _PromotionPostState extends State<LoungePostNotificationWidget> {
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
    List<TextSpan> getFormattedText(String text) {
      List<TextSpan> spans = [];
      text = text.replaceAll('\n', ' \n');
      RegExp regExp = RegExp(r'(@\w+)|(:\s.+)');

      text.splitMapJoin(
        regExp,
        onMatch: (Match match) {
          if (match.group(1) != null) {
            // Text starting with @
            spans.add(
              TextSpan(
                text: match.group(1),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: UserChannel(
                          user: widget.notification.linkedLounge!,
                          asList: false),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                style: defaultSmallXLabelCustom(context,
                    fontColor: Theme.of(context).colorScheme.primary),
              ),
            );
          } else if (match.group(2) != null) {
            // Text after :
            spans.add(
              TextSpan(
                text: match.group(2),
                style: defaultSmallXLabelCustom(context,
                    fontColor: Theme.of(context).colorScheme.primary),
              ),
            );
          }
          return '';
        },
        onNonMatch: (String nonMatch) {
          spans.add(
            TextSpan(
              text: nonMatch,
            ),
          );
          return '';
        },
      );

      return spans;
    }

    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: Lounge(user: widget.notification.linkedLounge!),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: widget.notification.viewed!
                ? Theme.of(context).canvasColor
                : Theme.of(context).dividerColor.withAlpha(400),
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).dividerColor, width: 1))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfilePicture(
                  radius: 20, userObj: widget.notification.linkedLounge!),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: defaultSmallXLabelCustom(
                          context,
                        ),
                        children: getFormattedText(
                            widget.notification.message![0] == "("
                                ? widget.notification.message!.substring(
                                    2, widget.notification.message!.length - 3)
                                : widget.notification.message!
                                    .replaceAll('\n', ' \n')
                                    .toString()),
                      ),
                    ),
                    Text(
                      formatTimeAgo(widget.notification.creationDate!),
                      style: defaultSmallXLabelCustom(context,
                          fontColor: Theme.of(context).hintColor),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
