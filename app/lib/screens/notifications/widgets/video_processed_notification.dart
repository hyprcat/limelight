import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';

import 'package:lime_time_app/logics/models/notifications/video_processed.dart';

class VideoProcessedNotificationWidget extends StatefulWidget {
  final VideoProcessedNotification notification;
  const VideoProcessedNotificationWidget(
      {super.key, required this.notification});

  @override
  State<VideoProcessedNotificationWidget> createState() =>
      _VideoProcessedNotificationWidgetState();
}

class _VideoProcessedNotificationWidgetState
    extends State<VideoProcessedNotificationWidget> {
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
                          user: widget.notification.linkedVideo!.videoCreator!,
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
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
        analytics!.logEvent(name: 'video_clicked', parameters: <String, Object>{
          'video_id': widget.notification.linkedVideo!.id.toString(),
          'clicked_by': authHandler.loggedInUser!.userId!.toString()
        });

        listController.freeAllControllers();
        videoListener.value = null;

        if (videoPlayerController.value != null) {
          videoPlayerController.value!.dispose(forceDispose: true);
          videoPlayerController.value = null;
        }
        invalidateAllControllers();
        if (playerWidget.value != null) {
          playerWidget.value = null;
        }

        if (isExpandedScreenInStack(myNavigatorObserver)) {
          for (var i in myNavigatorObserver.history) {
            if (i is MaterialPageRoute && i.builder is ExpandedVideo) {
              myNavigatorObserver.history.remove(i);
              break;
            }
          }
        }

        {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => ExpandedVideo(
                    video: widget.notification.linkedVideo!,
                    canBuildVideo: checkCanBuildVideo,
                    forMiniPlayer: false,
                    key: ValueKey<int>(Random().nextInt(10000)),
                  )));
        }
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
                  radius: 20,
                  userObj: widget.notification.linkedVideo!.videoCreator!),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: defaultSmallXLabelCustom(context,
                            fontColor: Theme.of(context).hintColor),
                        children: getFormattedText(
                            widget.notification.message![0] == "("
                                ? widget.notification.message!.substring(
                                    2, widget.notification.message!.length - 3)
                                : widget.notification.message!),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: ReadMoreText(
                            widget.notification.linkedVideo!.title!,
                            trimMode: TrimMode.Line,
                            trimLines: 4,
                            colorClickableText: Colors.pink,
                            trimCollapsedText: '\nShow more',
                            trimExpandedText: '\nShow less',
                            style: defaultSmallXLabelCustom(context,
                                fontWeight: FontWeight.bold),
                            moreStyle: defaultSmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor:
                                    Theme.of(context).colorScheme.primary),
                            lessStyle: defaultSmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor:
                                    Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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
