// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:async';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/upload_video/edit_video_screen.dart';

import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';
import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:lime_time_app/widgets/text_widgets/blur_texts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';

class VideoCard extends StatefulWidget {
  final VideoPost? video;
  final Function? canBuildVideo;
  final Function? actionCallback;
  final bool? cardType;
  bool? shouldSetImpression;

  VideoCard(
      {super.key,
      this.video,
      this.canBuildVideo,
      this.actionCallback,
      this.cardType,
      this.shouldSetImpression = false});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoPost? get video => widget.video;
  BetterPlayerController? controller;
  StreamController<BetterPlayerController?>
      betterPlayerControllerStreamController = StreamController.broadcast();
  bool _initialized = false;
  Timer? _timer;

  @override
  void initState() {
    if (widget.shouldSetImpression!) {
      VideoEngine().setImpression({
        'video_id': widget.video!.id,
      });
    }

    if (!widget.cardType!) {
      _setupController();
    }
    super.initState();
  }

  @override
  void dispose() {
    _freeController();
    super.dispose();
  }

  void onPlayerEvent(BetterPlayerEvent event) async {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      var progress = event.parameters!["progress"] as Duration?;
      progress!.inSeconds;
      var data = {
        'video_id': video!.id,
        'view_time_seconds': progress.inSeconds,
      };
      VideoEngine().setView(data);
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (video!.lastPosition != null) {
        controller!.seekTo(video!.lastPosition!);
      }
      if (video!.wasPlaying!) {
        controller!.play();
      }
    }
  }

  BetterPlayerDataSource? dataSource;
  void _setupController() {
    Map<String, String> resolutionsMap = {
      "144p": videoStreamUrl(widget.video!.id!, 144),
      "240p": videoStreamUrl(widget.video!.id!, 240),
      "360p": videoStreamUrl(widget.video!.id!, 360),
      "480p": videoStreamUrl(widget.video!.id!, 480),
      "720p": videoStreamUrl(widget.video!.id!, 720),
      "1080p": videoStreamUrl(widget.video!.id!, 1080),
      "1440p": videoStreamUrl(widget.video!.id!, 1440)
    };
    var url = originalVideoUrl(widget.video!.id!);

    if (controller == null) {
      controller = listController.getBetterPlayerController();
      if (controller != null) {
        controller!.setControlsEnabled(true);

        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          (widget.video!.isEncoded!) ? resolutionsMap.values.first : url,
          resolutions: (widget.video!.isEncoded!) ? resolutionsMap : null,
          videoFormat:
              (widget.video!.isEncoded!) ? BetterPlayerVideoFormat.hls : null,
          cacheConfiguration: BetterPlayerCacheConfiguration(
              useCache: true, key: widget.video!.id!),
        );

        controller!.setupDataSource(dataSource!);
        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }

        controller!.addEventsListener(onPlayerEvent);
        controller!.addEventsListener(_setView);
      }
    }
  }

  void _freeController() {
    if (!_initialized) {
      _initialized = true;
      return;
    }
    if (controller != null && _initialized) {
      controller!.removeEventsListener(onPlayerEvent);
      listController.freeBetterPlayerController(controller);
      controller!.pause();
      controller = null;
      if (!betterPlayerControllerStreamController.isClosed) {
        betterPlayerControllerStreamController.add(null);
      }
      _initialized = false;
    }
  }

  void _setView(BetterPlayerEvent event) {}

  RichText _buildUserRow() {
    return RichText(
      text: TextSpan(
          text: widget.video!.videoCreator!.userChannel!.name!,
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: ' ◦ ${formatTimeAgo(widget.video!.creationDate!)}',
              style: defaultSmallLabel(context,
                  fontColor: Theme.of(context).hintColor),
            ),
          ]),
    );
  }

  Future<Duration?> duration() async {
    return const Duration(seconds: 0);
  }

  void videoLongPressCallback() {
    List<Widget> blurMenuChildren = [
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            listController.freeAllControllers();
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ReportScreen(
                videoPost: widget.video!,
              ),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: buildBlurHeadingButton(context, "Report Video", Icons.report))
    ];
    if (widget.video!.videoCreator!.userId! ==
        authHandler.loggedInUser!.userId) {
      blurMenuChildren = [
        InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: MaterialLocalizations.of(context)
                      .modalBarrierDismissLabel,
                  barrierColor: Colors.black45,
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (BuildContext buildContext, Animation animation,
                      Animation secondaryAnimation) {
                    return Center(
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(
                            left: 50, right: 50, top: 50, bottom: 50),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary)),
                        child: Material(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("You sure want to delete this video?",
                                style: defaultHeadingText(context)),
                            SelectableText(
                                "Once deleted, You can't recover it back and XP points that you might have gained from this video will disappear.",
                                style: defaultSmallLabel(context)),
                            const SizedBox(
                              height: 20,
                            ),
                            PrimaryFocusButton(
                                label: "Yes, Delete this video",
                                callback: () async {
                                  var response = await VideoEngine()
                                      .deleteVideo(widget.video!.id!);
                                  if (response == "Deleted video") {
                                    throwHappySnackBar(context,
                                        "Requested to delete your video. It should be deleted in a few moments.");
                                  } else {
                                    throwErrorSnackBar(context, response);
                                  }
                                  Navigator.pop(context);
                                }),
                          ],
                        )),
                      ),
                    );
                  });
            },
            child:
                buildBlurHeadingButton(context, "Delete video", Icons.delete)),
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
                  videoPost: widget.video!,
                ),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
              Navigator.of(context, rootNavigator: true).pop();
            },
            child:
                buildBlurHeadingButton(context, "Edit", Iconsax.edit_outline)),
      ];
    }
    showBlurMenu(blurMenuChildren, context, half: true);
  }

  void onTapCallback() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    listController.freeAllControllers();
    listController.makeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (widget.actionCallback != null) {
          setState(() {
            _freeController();
            listController.freeAllControllers();
          });
          widget.actionCallback!();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: EdgeInsets.all(widget.cardType! ? 5 : 0),
      margin: widget.cardType!
          ? const EdgeInsets.only(bottom: 10, left: 5, right: 5)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          debugSettings
              ? Column(
                  children: [
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        IconLabelButton(
                            icon: Iconsax.password_check_outline,
                            label: "ID: ${widget.video!.id}"),
                        const SizedBox(
                          height: 4,
                        ),
                        IconLabelButton(
                            icon: Iconsax.timer_1_outline,
                            label:
                                "Video Duration (Sec): ${widget.video!.videoDurationSeconds}"),
                        const SizedBox(
                          height: 4,
                        ),
                        IconLabelButton(
                            icon: Iconsax.language_circle_outline,
                            label: "Language: ${widget.video!.language}"),
                        const SizedBox(
                          height: 4,
                        ),
                        IconLabelButton(
                            icon: Iconsax.info_circle_outline,
                            label: "Impressions: ${widget.video!.impressions}"),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    )
                  ],
                )
              : Container(),
          VisibilityDetector(
            key: Key(hashCode.toString() + DateTime.now().toString()),
            onVisibilityChanged: (info) {
              if (widget.cardType!) {
                if (!checkCanBuildVideo()) {
                  _timer?.cancel();
                  _timer = null;
                  _timer = Timer(const Duration(milliseconds: 500), () {
                    if (info.visibleFraction >= 0.6) {
                      _setupController();
                    } else {
                      _freeController();
                    }
                  });
                  return;
                }
                if (info.visibleFraction >= 0.6) {
                  _setupController();
                } else {
                  _freeController();
                }
              } else {}
            },
            child: StreamBuilder<BetterPlayerController?>(
              stream: betterPlayerControllerStreamController.stream,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: widget.cardType!
                          ? BorderRadius.circular(10)
                          : BorderRadius.circular(0),
                      child: AspectRatio(
                        aspectRatio: (controller != null)
                            ? controller!.getAspectRatio()!
                            : 16 / 9,
                        child: (controller != null)
                            ? InkWell(
                                onLongPress: videoLongPressCallback,
                                onTap: onTapCallback,
                                child: BetterPlayer(
                                  controller: controller!,
                                ),
                              )
                            : Container(),
                      ),
                    ),
                    widget.cardType! && (controller == null)
                        ? ClipRRect(
                            borderRadius: widget.cardType!
                                ? BorderRadius.circular(10)
                                : BorderRadius.circular(0),
                            child: AspectRatio(
                              aspectRatio: (controller != null)
                                  ? controller!.getAspectRatio()!
                                  : 16 / 9,
                              child: Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(videoThumbnailUrl(
                                              widget.video!.id!)),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 2.0,
                                              sigmaY: 2.0,
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black54),
                                              width: double.infinity,
                                              child: Image.network(
                                                videoThumbnailUrl(
                                                    widget.video!.id!),
                                                fit: BoxFit.contain,
                                                filterQuality:
                                                    FilterQuality.high,
                                                errorBuilder:
                                                    (context, __, ___) {
                                                  return Container(
                                                    color: Theme.of(context)
                                                        .dividerColor,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: Center(
                                                      child: Text(
                                                        widget.video!.title!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: defaultHeadingText(
                                                            context,
                                                            fontColor: Theme.of(
                                                                    context)
                                                                .hintColor
                                                                .withOpacity(
                                                                    0.2),
                                                            fontsize: 50),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).dividerColor),
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                          Colors.transparent,
                                          Colors.black12,
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Text(widget.video!.title!,
                                            style: defaultHeadingText(context,
                                                fontWeight: FontWeight.bold,
                                                fontColor: Colors.white,
                                                fontsize: 20)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        : Container()
                  ],
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          widget.cardType!
              ? InkWell(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: UserChannel(
                          user: widget.video!.videoCreator!, asList: false),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserProfilePicture(
                                  radius: 20,
                                  userObj: widget.video!.videoCreator!),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildUserRow(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 20,
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Text(
                                                !widget.video!.isActive!
                                                    ? 'DRAFT'
                                                    : "${numToEng(widget.video!.videoXp!)} Points",
                                                style: defaultVerySmallLabel(
                                                    context,
                                                    fontColor:
                                                        theme == ThemeMode.light
                                                            ? Theme.of(context)
                                                                .canvasColor
                                                            : Theme.of(context)
                                                                .primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          TextMetric(
                                              label: 'Level',
                                              value: numToEng(widget
                                                  .video!
                                                  .videoCreator!
                                                  .userChannel!
                                                  .level!),
                                              reverse: true),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: videoLongPressCallback,
                          child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).dividerColor,
                              child: const Icon(
                                Icons.more_horiz,
                                size: 16,
                              )),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          const Row(
            children: [
              SizedBox(
                width: 5,
              ),
            ],
          ),
          debugSettings
              ? Column(
                  children: [
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        IconLabelButton(
                            icon: Iconsax.category_2_outline,
                            label: "Topic ID: ${widget.video!.topicId}"),
                        const SizedBox(
                          height: 4,
                        ),
                        IconLabelButton(
                            icon: Iconsax.info_circle_outline,
                            label:
                                "Topic Category ID: ${widget.video!.topicCategoryId}"),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    )
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  @override
  void deactivate() {
    if (controller != null) {
      video!.wasPlaying = controller!.isPlaying();
    }
    _initialized = true;
    super.deactivate();
  }
}
