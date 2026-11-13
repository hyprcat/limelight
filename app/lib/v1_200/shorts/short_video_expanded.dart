import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/reusable_auto_play_list/controller.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/screens/video_player/renderers/comment_section.dart';
import 'package:lime_time_app/v1_200/cards/short_experimental_video_card.dart';
import 'package:lime_time_app/v1_200/shorts/vertical_action_row.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:text_scroll/text_scroll.dart';

import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';

class ShortVideoExpanded extends StatefulWidget {
  final VideoPost video;
  final List<VideoPost> data;
  final int currentIndex;
  final ReusableVideoListController? videoListController;
  final Function? canBuildVideo;
  const ShortVideoExpanded(
      {super.key,
      required this.video,
      this.videoListController,
      this.canBuildVideo,
      required this.data,
      required this.currentIndex});

  @override
  State<ShortVideoExpanded> createState() => _ShortVideoExpandedState();
}

class _ShortVideoExpandedState extends State<ShortVideoExpanded>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;
  late UserChannelBloc userChannelBloc;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
    userChannelBloc = UserChannelBloc(widget.video.videoCreator!.userChannel!,
        authHandler.loggedInUser!, widget.video.videoCreator!);
    userChannelBloc.add(LoadUserChannel(false, true));
    super.initState();
  }

  List<Annotation> _getAnnotations() {
    return [
      Annotation(
        regExp: RegExp(r'\((.*?)\)'),
        spanBuilder: ({required String text, TextStyle? textStyle}) {
          final description =
              text.substring(1, text.length - 1); // Remove parentheses
          var descriptionStrings =
              description.split(',').map((s) => s.trim()).toList();
          final List<String> selectedDescriptions = [];
          final List<String> uniqueDescriptions = [];

          for (var desc in descriptionStrings) {
            bool isUnique = true;
            for (var uniqueDesc in uniqueDescriptions) {
              if (uniqueDesc.contains(desc) || desc.contains(uniqueDesc)) {
                isUnique = false;
                break;
              }
            }
            if (isUnique) {
              uniqueDescriptions.add(desc);
              selectedDescriptions.add(desc);
              if (selectedDescriptions.length == 2) {
                break;
              }
            }
          }

          String formattedDescription;
          if (selectedDescriptions.length == 2) {
            formattedDescription =
                '[${selectedDescriptions[0]} along with ${selectedDescriptions[1]}]';
          } else {
            formattedDescription = '[${selectedDescriptions[0]}]';
          }

          return TextSpan(
            text: "\n" + formattedDescription + '\n',
            style: textStyle?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).hintColor),
          );
        },
      ),
      // Add other annotations here, e.g., for hashtags, mentions, URLs...
    ];
  }

  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;

    Widget buildUserRow() {
      return Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0),
        child: InkWell(
          onTap: () {
            listController.freeAllControllers();
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: UserChannel(
                user: widget.video.videoCreator,
                asList: false,
                canBuildVideo: checkCanBuildVideo,
              ),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserProfilePicture(
                  radius: 18, userObj: widget.video.videoCreator!),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextScroll(
                                    widget
                                        .video.videoCreator!.userChannel!.name!,
                                    style: defaultLabelTextForPost(context,
                                        fontWeight: FontWeight.w700),
                                    velocity: const Velocity(
                                        pixelsPerSecond: Offset(25, 0)),
                                    mode: TextScrollMode.endless,
                                    intervalSpaces: 5),
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
                                          "Level ${widget.video.videoCreator!.userChannel!.level!}",
                                          style: defaultVerySmallLabelCustom(
                                              context,
                                              fontColor:
                                                  Theme.of(context).canvasColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                        "${numToEng(widget.video.videoXp!)} points",
                                        style: defaultVerySmallLabelCustom(
                                          context,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        BlocConsumer<UserChannelBloc, UserChannelState>(
                          bloc: userChannelBloc,
                          listener: (context, state) {
                            if (state is RefreshChannel) {
                              userChannelBloc.add(LoadUserChannel(true, true));
                            }
                          },
                          builder: (context, state) {
                            if (state is LoadingChannel) {
                              return Center(
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballPulse,
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.tertiary
                                      ],
                                      strokeWidth: 2,
                                      backgroundColor:
                                          Theme.of(context).canvasColor,
                                      pathBackgroundColor:
                                          Theme.of(context).canvasColor),
                                ),
                              );
                            }
                            if (state is SuccessfullyLoadedChannel) {
                              Widget child = ConfettiWidget(
                                confettiController: _controllerCenter,
                                blastDirectionality:
                                    BlastDirectionality.explosive,
                                shouldLoop: false,
                                colors: const [
                                  Colors.green,
                                  Colors.blue,
                                  Colors.pink,
                                  Colors.orange,
                                  Colors.purple
                                ], // manually specify the colors to be used
                                createParticlePath: drawStar,
                                child: PrimaryFocusButton(
                                  useRoundedCorner: true,
                                  label: state.subscriptionStatus
                                      ? 'Subscribed'
                                      : 'Subscribe',
                                  highLight: !state.subscriptionStatus,
                                  showArrow: !state.subscriptionStatus,
                                  alternateColor: state.subscriptionStatus
                                      ? Theme.of(context).focusColor
                                      : null,
                                  callback: () {
                                    if (state.subscriptionStatus) {
                                      userChannelBloc.add(Unsubscribe());
                                    } else {
                                      _controllerCenter.play();
                                      userChannelBloc.add(Subscribe());
                                    }
                                  },
                                ),
                              );

                              if (!state.subscriptionStatus) {
                                return child;
                              }
                              return child;
                            }
                            return Container();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget descriptionSection() {
      var activeStep = 0;
      if (widget.video.isEncoded!) {
        activeStep = 1;
      }
      if (widget.video.goneThroughMl!) {
        activeStep = 3;
      }

      return ListView(
        key: const ValueKey<int>(2),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            key: const ValueKey<int>(2),
            child: Column(
              key: const ValueKey<int>(2),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(left: 15, top: 10, right: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.video.title!,
                                  style: defaultHeadingText(context,
                                      fontWeight: FontWeight.bold,
                                      fontsize: 20)),
                              Text(
                                "Uploaded on ${dateTimeToWords(widget.video.creationDate!)}",
                                style: defaultSmallXLabelCustom(context,
                                    fontColor: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Iconsax.arrow_circle_up_bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconLabelButton(
                        icon: Iconsax.eye_outline,
                        label: "${numToEng(widget.video.views!)} Views",
                        isBig: true,
                        vertical: true,
                      ),
                      IconLabelButton(
                        icon: Iconsax.heart_bold,
                        label: "${widget.video.likes!} Likes",
                        isBig: true,
                        vertical: true,
                      ),
                      IconLabelButton(
                        icon: Iconsax.heart_slash_bold,
                        label: "${widget.video.likes!} Dislikes",
                        isBig: true,
                        vertical: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: RichText(
                    text: TextSpan(
                      style: defaultNormalText(context,
                          fontWeight: FontWeight.w500),
                      children: highlightLinksHashtagsTimestamps(
                          widget.video.videoDescription ??
                              "No description available."),
                    ),
                  ),
                ),
                if (widget.video.transcript != null)
                  Divider(color: Theme.of(context).dividerColor),
                if (widget.video.transcript != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.thorchain_rune_bold,
                              size: 35,
                              color: Theme.of(context).colorScheme.primary,
                            )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .shimmer(
                                    duration: 2500.ms, color: Colors.pinkAccent)
                                .animate(),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Screenplay",
                                        style: defaultNormalText(context,
                                            fontWeight: FontWeight.bold))
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat())
                                    .shimmer(
                                        duration: 3500.ms,
                                        color: Colors.grey.shade600)
                                    .animate(),
                                Text("Powered by Hazel AI",
                                        style: defaultSmallLabel(context,
                                            fontColor:
                                                Theme.of(context).hintColor))
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat())
                                    .shimmer(
                                        duration: 3500.ms, color: Colors.grey)
                                    .animate() // this wraps the previous Animate in another Animate
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ReadMoreText(
                            widget.video.transcript!,
                            trimMode: TrimMode.Line,
                            trimLines: 10,
                            colorClickableText: Colors.pink,
                            trimCollapsedText: '\n\nShow more',
                            trimExpandedText: '\n\nShow less',
                            annotations: _getAnnotations(),
                            style: defaultSmallXLabelCustom(context,
                                fontWeight: FontWeight.w500),
                            moreStyle: defaultSmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor:
                                    Theme.of(context).colorScheme.primary),
                            lessStyle: defaultSmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor:
                                    Theme.of(context).colorScheme.primary),
                          ).animate(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                            "AI might not be fully accurate and you might want to double check it before using this.",
                            textAlign: TextAlign.center,
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor: Theme.of(context).disabledColor)),
                      ],
                    ),
                  ),
                if (debugSettings)
                  Divider(color: Theme.of(context).dividerColor),
                if (authHandler.loggedInUser!.userId! ==
                    widget.video.videoCreator!.userId!)
                  EasyStepper(
                    activeStep: 0,
                    stepShape: StepShape.rRectangle,
                    stepBorderRadius: 15,
                    borderThickness: 2,
                    stepRadius: 28,
                    finishedStepBorderColor: Colors.deepOrange,
                    finishedStepTextColor: Colors.deepOrange,
                    finishedStepBackgroundColor: Colors.deepOrange,
                    activeStepIconColor: Colors.deepOrange,
                    showLoadingAnimation: false,
                    steps: [
                      EasyStep(
                        customStep: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Opacity(
                            opacity: activeStep >= 0 ? 1 : 0.3,
                            child: Icon(
                              Iconsax.document_upload_outline,
                              color: activeStep >= 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                        customTitle: Text(
                          'Video\nUploaded',
                          textAlign: TextAlign.center,
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      EasyStep(
                        customStep: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Opacity(
                            opacity: activeStep >= 1 ? 1 : 0.5,
                            child: Icon(
                              Iconsax.speedometer_outline,
                              color: activeStep >= 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                        customTitle: Text(
                          'Optimising Video',
                          textAlign: TextAlign.center,
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      EasyStep(
                        customStep: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Opacity(
                            opacity: activeStep >= 2 ? 1 : 0.3,
                            child: Icon(
                              Iconsax.thorchain_rune_outline,
                              color: activeStep >= 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                        customTitle: Text(
                          'AI Processing',
                          textAlign: TextAlign.center,
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      EasyStep(
                        customStep: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Opacity(
                            opacity: activeStep >= 3 ? 1 : 0.3,
                            child: Icon(
                              Iconsax.tick_circle_bold,
                              color: activeStep >= 0
                                  ? Colors.green
                                  : Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                        customTitle: Text(
                          'Ready for Viewers',
                          textAlign: TextAlign.center,
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    onStepReached: (index) =>
                        setState(() => activeStep = index),
                  ),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 3,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.video.id!,
                    style: defaultSmallLabel(context,
                        fontColor: Theme.of(context).disabledColor),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        OverflowBox(
          child: BetterPlayerWidgetExperimental(
            video: widget.video,
            repoData: widget.data,
            index: widget.currentIndex,
            videoListController: widget.videoListController,
            canBuildVideo: widget.canBuildVideo,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: Platform.isIOS ? const EdgeInsets.only(bottom: 30) : null,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.black45,
              Colors.black54,
              Colors.black87,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.only(right: 30),
                    child: buildUserRow()),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Theme.of(context).cardColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      builder: (BuildContext context) {
                        return descriptionSection();
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 20),
                    child: Text(
                      widget.video.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: defaultLabelTextForPost(context,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: VideoActionRowVertical(
            video: widget.video,
            updateVideoCallback: (x, y) {},
            showCommentsCallback: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      CommentSection(
                        key: const ValueKey<int>(3),
                        video: widget.video,
                        activeIndexCallback: (index) {},
                      ),
                    ],
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}
