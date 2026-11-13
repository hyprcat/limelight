// ignore_for_file: unused_field, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:better_player/better_player.dart';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:lime_time_app/widgets/draggable_home.dart';
import 'package:lime_time_app/widgets/miniplayer/miniplayer.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:text_scroll/text_scroll.dart';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';

import 'package:lime_time_app/screens/home/suggested_videos.dart';
import 'package:lime_time_app/screens/video_player/widgets/action_row.dart';
import 'package:lime_time_app/screens/video_player/renderers/comment_renderer.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/video_players/better_player_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/renderers/comment_section.dart';

class ExpandedVideo extends StatefulWidget {
  final VideoPost video;
  final bool forMiniPlayer;
  final Function? canBuildVideo;
  const ExpandedVideo(
      {super.key,
      this.canBuildVideo,
      required this.video,
      this.forMiniPlayer = false});

  @override
  State<ExpandedVideo> createState() => _ExpandedVideoState();
}

Path drawStar(Size size) {
  // Method to convert degree to radians
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}

class _ExpandedVideoState extends State<ExpandedVideo> {
  final bool _showDescription = false;
  late UserChannelBloc userChannelBloc;

  RichText _buildMetricRow() {
    return RichText(
      softWrap: true,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(text: "", children: [
        TextSpan(
          text: numToEng(widget.video.videoXp!),
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: " points",
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: " • ",
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: formatTimeAgo(widget.video.creationDate!),
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  RichText _buildMetricRowForUsers() {
    return RichText(
      softWrap: true,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(text: "", children: [
        TextSpan(
          text: numToEng(widget.video.videoCreator!.userChannel!.xP!),
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: " Overall Points",
          style: defaultSmallXLabelCustom(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Widget _buildUserRow() {
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
            UserProfilePicture(radius: 14, userObj: widget.video.videoCreator!),
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
                                  widget.video.videoCreator!.userChannel!.name!,
                                  style: defaultLabelText(context,
                                      fontWeight: FontWeight.w700),
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(25, 0)),
                                  mode: TextScrollMode.endless,
                                  intervalSpaces: 5),
                              _buildMetricRowForUsers()
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          BlocConsumer<UserChannelBloc, UserChannelState>(
                            bloc: userChannelBloc,
                            listener: (context, state) {
                              if (state is RefreshChannel) {
                                userChannelBloc
                                    .add(LoadUserChannel(true, true));
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
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                                    compact: false,
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
                          ),
                        ],
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

  Widget _buildInfo() {
    return InkWell(
      onTap: () {
        setState(() {
          activeIndex = 1;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, left: 15, right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.video.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: defaultHeadingText(context,
                          fontWeight: FontWeight.bold, fontsize: 20)),
                  _buildMetricRow()
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    activeIndex = 1;
                  });
                },
                icon: const Icon(
                  Iconsax.arrow_circle_down_bold,
                ))
          ],
        ),
      ),
    );
  }

  void updateVideoStatus(int likes, int dislikes) {
    widget.video.likes = likes;
    widget.video.dislikes = dislikes;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.video.likes = likes;
        widget.video.dislikes = dislikes;
      });
    });
  }

  void showCommentsCallBack() {
    setState(() {
      activeIndex = 2;
    });
  }

  Widget _buildActionsDescription() {
    return Container(
        key: const ValueKey<int>(1),
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 0, left: 15, right: 10),
        child: VideoActionRow(
          video: widget.video,
          updateVideoCallback: updateVideoStatus,
          showCommentsCallback: showCommentsCallBack,
        ));
  }

  @override
  void dispose() {
    listController.freeAllControllers();
    _controllerCenter.dispose();

    super.dispose();
  }

  late ConfettiController _controllerCenter;
  void actionCallback() {}
  ScrollController scrollController = ScrollController();

  int activeIndex = 0;

  Widget _initialSection() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      controller: scrollController,
      shrinkWrap: true,
      key: const ValueKey<int>(1),
      children: [
        _buildInfo(),
        const SizedBox(
          height: 15,
        ),
        _buildActionsDescription(),
        Container(child: _buildUserRow()),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Icon(
                BoxIcons.bxs_videos,
                size: 35,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("More videos to watch",
                      style: defaultNormalText(context,
                          fontWeight: FontWeight.bold)),
                  Text("Based on your interests",
                      style: defaultSmallLabel(context,
                          fontColor: Theme.of(context)
                              .hintColor)) // this wraps the previous Animate in another Animate
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 500,
          child: SuggestedVideos(
            controller: scrollController,
            canBuildVideo: checkCanBuildVideo,
            forMiniPlayer: widget.forMiniPlayer,
          ),
        ),
        const Divider(),
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
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2500.ms, color: Colors.pinkAccent)
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
                                onPlay: (controller) => controller.repeat())
                            .shimmer(
                                duration: 3500.ms, color: Colors.grey.shade600)
                            .animate(),
                        Text("Powered by Hazel AI",
                                style: defaultSmallLabel(context,
                                    fontColor: Theme.of(context).hintColor))
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 3500.ms, color: Colors.grey)
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
                        fontColor: Theme.of(context).colorScheme.primary),
                    lessStyle: defaultSmallLabel(context,
                        fontWeight: FontWeight.w600,
                        fontColor: Theme.of(context).colorScheme.primary),
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
      ],
    );
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

  Widget _descriptionSection() {
    var activeStep = 0;
    if (widget.video.isEncoded!) {
      activeStep = 1;
    }
    if (widget.video.goneThroughMl!) {
      activeStep = 3;
    }

    return ListView(
      key: const ValueKey<int>(2),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Divider(height: 0, color: Theme.of(context).dividerColor),
        Container(
          key: const ValueKey<int>(2),
          child: Column(
            key: const ValueKey<int>(2),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    activeIndex = 0;
                  });
                },
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
                                    fontWeight: FontWeight.bold, fontsize: 20)),
                            Text(
                              "Uploaded on ${dateTimeToWords(widget.video.creationDate!)}",
                              style: defaultSmallXLabelCustom(context,
                                  fontColor: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              activeIndex = 0;
                            });
                          },
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
                      label: "${widget.video.dislikes!} Dislikes",
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
                    style:
                        defaultNormalText(context, fontWeight: FontWeight.w500),
                    children: highlightLinksHashtagsTimestamps(
                        widget.video.videoDescription ??
                            "No description available."),
                  ),
                ),
              ),
              if (widget.video.transcript != null)
                Divider(color: Theme.of(context).dividerColor),
              if (debugSettings) Divider(color: Theme.of(context).dividerColor),
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
                  onStepReached: (index) => setState(() => activeStep = index),
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

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget searchUserField(VideoCommentRepo? repo) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: false,
          maxLength: 700,
          controller: commentController,
          style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
          maxLines: null,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: repo != null ? "Add a reply" : "Add a comment..",
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
            suffixIcon: InkWell(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (commentController.text.isEmpty) {
                  throwErrorSnackBar(
                      context, "Looks like comment field's empty.");
                } else {
                  var data = {
                    'token': sessionData!['token'],
                    'video_id': widget.video.id,
                    'comment_string': commentController.text
                  };

                  if (repo != null) {
                    data['root_comment_id'] = repo.rootComment.id;
                  }
                  commentController.clear();
                  videoCommentsBloc!.add(AddComment(data));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: _backgroundWrapper([
                  Text(
                    "Post",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Iconsax.send_1_bold,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: ValueListenableBuilder<VideoCommentRepo?>(
              valueListenable: buildReplies,
              builder: (context, VideoCommentRepo? value, _) {
                return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Theme.of(context).canvasColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Divider(
                            height: 0,
                            color: Theme.of(context).dividerColor,
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                            ),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 20, top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  UserProfilePicture(
                                      radius: 18,
                                      userObj: authHandler.loggedInUser!),
                                  Expanded(child: searchUserField(value)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              }),
        ),
      ],
    );
  }

  late CommentsRenderer commentsRenderer;
  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));

    commentsRenderer = CommentsRenderer(videoPost: widget.video);
    userChannelBloc = UserChannelBloc(widget.video.videoCreator!.userChannel!,
        authHandler.loggedInUser!, widget.video.videoCreator!);
    userChannelBloc.add(LoadUserChannel(false, true));

    super.initState();
  }

  void activeIndexCallback(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> availableSecondarySections = [
      _initialSection(),
      _descriptionSection(),
      CommentSection(
        key: const ValueKey<int>(3),
        video: widget.video,
        activeIndexCallback: activeIndexCallback,
      )
    ];

    Widget _buildSecondarySection() {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
              padding: const EdgeInsets.only(top: 10),
              child: availableSecondarySections[activeIndex]));
    }

    Widget expandedBody = Container();
    expandedBody = ValueListenableBuilder(
        valueListenable: videoPlayerController,
        builder: (BuildContext context, BetterPlayerController? value,
            Widget? child) {
          return SafeArea(
            bottom: true,
            top: true,
            child: BetterPlayerWidget(
              video: widget.video,
              betterPlayerController: value,
              key: widget.key,
            ),
          );
        });
    int? small;
    double? aspectRatio;
    double m = MediaQuery.of(context).size.height;

    if (widget.video.videoHeight != null && widget.video.videoWidth != null) {
      small = min(widget.video.videoHeight!, widget.video.videoWidth!);

      if (small == widget.video.videoHeight) {
        m = MediaQuery.of(context).size.width;
        small = 1440; // Example fallback value, adjust as necessary
      }

      if (m > small) {
        m = m / 2;
      }
      aspectRatio = (m / small) - 0.04;
    }

    return PopScope(
      canPop: !widget.forMiniPlayer,
      onPopInvokedWithResult: (status, _) {
        if (!widget.forMiniPlayer) {
          videoListener.value = widget.video;
        }
        if (widget.forMiniPlayer) {
          miniplayerController.animateToHeight(state: PanelState.MIN);
        }
        isExpanded.value = true;
      },
      child: DraggableHome(
        scrollController: hcontroller,
        backgroundColor: Theme.of(context).canvasColor,
        appBarColor: Theme.of(context).canvasColor,
        title: Container(),
        headerExpandedHeight: (aspectRatio! > 0.8) ? 0.80 : aspectRatio,
        bottomNavigationBar: (activeIndex == 2)
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: (activeIndex == 2)
                    ? Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: _bottomTextField(),
                      )
                    : null,
              )
            : null,
        headerWidget: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              miniplayerController.animateToHeight(state: PanelState.MIN);
              isExpanded.value = true;
              if (!widget.forMiniPlayer) {
                Navigator.pop(context);
              }
            } else {}
          },
          child: Container(
              padding: const EdgeInsets.only(bottom: 0), child: expandedBody),
        ),
        body: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    height: 100,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black])),
                  ),
                  Container(
                    height: 1000,
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.black),
                  ),
                ],
              ),
              _buildSecondarySection(),
            ],
          ),
        ],
      ),
    );
  }
}
