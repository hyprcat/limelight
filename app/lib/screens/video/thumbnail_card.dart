// ignore_for_file: no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/upload_video/edit_video_screen.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';
import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';
import 'package:lime_time_app/widgets/miniplayer/miniplayer.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/text_widgets/blur_texts.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';

class ThumbnailCard extends StatefulWidget {
  final VideoPost video;
  final Function? canBuildVideo;
  bool? shouldSetImpression;
  bool? replaceScreen;
  bool? forMiniPlayer;
  ThumbnailCard(
      {super.key,
      required this.video,
      required this.canBuildVideo,
      this.shouldSetImpression = false,
      this.replaceScreen = false,
      this.forMiniPlayer = false});

  @override
  State<ThumbnailCard> createState() => _ThumbnailCardState();
}

class _ThumbnailCardState extends State<ThumbnailCard> {
  @override
  void initState() {
    VideoEngine().setImpression({
      'video_id': widget.video.id,
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RichText _buildUserRow() {
      return RichText(
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(text: "", children: [
          TextSpan(
              text: widget.video.videoCreator!.userChannel!.name!,
              style: defaultVerySmallLabelCustom(
                context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.w500,
              )),
          TextSpan(
            text:
                ' • ${!widget.video.isActive! ? 'DRAFT' : "${numToEng(widget.video.videoXp!)} Points"}',
            style: defaultVerySmallLabelCustom(
              context,
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).hintColor,
            ),
          ),
          TextSpan(
            text: ' • ${formatTimeAgo(widget.video.creationDate!)}',
            style: defaultVerySmallLabelCustom(
              context,
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).hintColor,
            ),
          ),
        ]),
      );
    }

    void videoLongPressCallback() {
      List<Widget> blurMenuChildren = [
        InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.selectionClick();

              analytics!.logEvent(
                  name: 'report_screen_clicked',
                  parameters: <String, Object>{
                    'video_id': widget.video.id.toString(),
                    'clicked_by': authHandler.loggedInUser!.userId!.toString()
                  });
              listController.freeAllControllers();

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ReportScreen(
                  videoPost: widget.video,
                ),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
              Navigator.of(context, rootNavigator: true).pop();
            },
            child:
                buildBlurHeadingButton(context, "Report Video", Icons.report))
      ];
      if (widget.video.videoCreator!.userId! ==
          authHandler.loggedInUser!.userId) {
        blurMenuChildren = [
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                analytics!.logEvent(
                    name: 'delete_video_dialog_shown',
                    parameters: <String, Object>{
                      'video_id': widget.video.id.toString(),
                      'clicked_by': authHandler.loggedInUser!.userId!.toString()
                    });
                showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(context)
                        .modalBarrierDismissLabel,
                    barrierColor: Colors.black45,
                    transitionDuration: const Duration(milliseconds: 200),
                    pageBuilder: (BuildContext buildContext,
                        Animation animation, Animation secondaryAnimation) {
                      return Center(
                        child: Container(
                          width: 400,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(
                              left: 50, right: 50, top: 50, bottom: 50),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Theme.of(context).dividerColor)),
                          child: Material(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("You sure want to delete this video?",
                                  style: defaultHeadingText(context)),
                              const SizedBox(
                                height: 10,
                              ),
                              SelectableText(
                                  "Once deleted, You can't recover it back and XP points that you might have gained from this video will disappear.",
                                  style: defaultSmallLabel(context)),
                              const SizedBox(
                                height: 10,
                              ),
                              PrimaryFocusButton(
                                  label: "Yes, Delete this video",
                                  callback: () async {
                                    var response = await VideoEngine()
                                        .deleteVideo(widget.video.id!);
                                    if (response == "Left Lounge.") {
                                      throwHappySnackBar(context,
                                          "You are not a member of this Lounge anymore.");
                                    } else {
                                      throwErrorSnackBar(context, response);
                                    }
                                    Navigator.of(buildContext,
                                            rootNavigator: true)
                                        .pop(buildContext);
                                    Navigator.of(buildContext,
                                            rootNavigator: true)
                                        .pop(buildContext);
                                  }),
                            ],
                          )),
                        ),
                      );
                    });
              },
              child: buildBlurHeadingButton(
                  context, "Delete video", Icons.delete)),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                listController.freeAllControllers();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: EditScreen(
                    videoPost: widget.video,
                  ),
                  withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: buildBlurHeadingButton(
                  context, "Edit", Iconsax.edit_outline)),
        ];
      }
      showBlurMenu(blurMenuChildren, context, half: true);
    }

    return InkWell(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
        analytics!.logEvent(name: 'video_clicked', parameters: <String, Object>{
          'video_id': widget.video.id.toString(),
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

        if (widget.replaceScreen!) {
          for (var i in myNavigatorObserver.history) {
            if (i is MaterialPageRoute && i.builder is ExpandedVideo) {
              myNavigatorObserver.history.remove(i);
            }
          }
        }

        if (widget.forMiniPlayer!) {
          videoListener.value = widget.video;
          isExpanded.value = false;
          videoPlayerController.value = makeController(widget.video);
          hcontroller.animateTo(0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.fastOutSlowIn);
          miniplayerController.animateToHeight(state: PanelState.MIN);
          Future.delayed(const Duration(milliseconds: 150), () {
            miniplayerController.animateToHeight(state: PanelState.MAX);
          });
          return;
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
          Navigator.of(context, rootNavigator: false)
              .popUntil((route) => route is! ExpandedVideo);
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => ExpandedVideo(
                    video: widget.video,
                    canBuildVideo: checkCanBuildVideo,
                    forMiniPlayer: false,
                    key: ValueKey<int>(Random().nextInt(10000)),
                  )));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 5),
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          videoThumbnailUrl(widget.video.id!)),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 1.0,
                                            sigmaY: 1.0,
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                            ),
                                            width: double.infinity,
                                            child: CachedNetworkImage(
                                              imageUrl: videoThumbnailUrl(
                                                  widget.video.id!),
                                              fit: BoxFit.contain,
                                              filterQuality:
                                                  FilterQuality.medium,
                                              cacheKey: widget.video.id! +
                                                  DateTime.now()
                                                      .hour
                                                      .toString(),
                                              errorWidget: (context, __, ___) {
                                                return Container(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Center(
                                                    child: Text(
                                                      widget.video.title!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: defaultHeadingXText(
                                                          context,
                                                          fontColor: Theme.of(
                                                                  context)
                                                              .hintColor
                                                              .withOpacity(0.2),
                                                          fontsize: 50),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: UserChannel(
                          user: widget.video.videoCreator!, asList: false),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserProfilePicture(
                          radius: 16,
                          userObj: widget.video.videoCreator!,
                          useCache: true,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.title!,
                                style: defaultSmallXLabelCustom(context,
                                    fontColor: theme == ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              _buildUserRow(),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: videoLongPressCallback,
                          child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).canvasColor,
                              child: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
