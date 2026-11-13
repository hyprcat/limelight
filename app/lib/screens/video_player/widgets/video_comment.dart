// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/videos/per_comment/per_comment_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/video_player/renderers/followup_section.dart';
import 'package:lime_time_app/screens/video_player/widgets/reply_comment.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:readmore/readmore.dart';
import 'package:text_scroll/text_scroll.dart';

class VideoCommentWidget extends StatefulWidget {
  final VideoPost videoPost;
  final VideoComment? comment;
  final bool showReplyButton;
  final Function blocDeleteCallback;
  List<VideoComment>? baseComments = [];
  bool showCommentedByText;
  bool expandedComment;

  VideoCommentWidget(
      {super.key,
      required this.videoPost,
      required this.comment,
      required this.showReplyButton,
      this.showCommentedByText = true,
      required this.blocDeleteCallback,
      this.baseComments,
      this.expandedComment = false});

  @override
  State<VideoCommentWidget> createState() => _VideoCommentWidgetState();
}

class _VideoCommentWidgetState extends State<VideoCommentWidget> {
  late PerCommentBloc perCommentBloc;

  Widget buildFlare(String label, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 2, bottom: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text(
          label,
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget userRow() {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen:
              UserChannel(user: widget.comment!.commentedBy!, asList: false),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  text: TextSpan(
                      text: widget.comment!.commentedBy!.userChannel!.name!,
                      style: defaultLabelTextForPost(context,
                          fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                            text:
                                " @${widget.comment!.commentedBy!.userName!} ",
                            style: defaultVerySmallLabelCustom(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600))
                      ]),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          "Level ${widget.comment!.commentedBy!.userChannel!.level!}",
                          style: defaultVerySmallLabelCustom(context,
                              fontColor: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(formatTimeAgo(widget.comment!.creationDate!),
                        style: defaultVerySmallLabelCustom(context,
                            fontColor: Theme.of(context).hintColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget postText() {
    return ReadMoreText(
      widget.comment!.comment!,
      trimMode: TrimMode.Line,
      trimLines: 4,
      colorClickableText: Colors.pink,
      trimCollapsedText: '\nShow more',
      trimExpandedText: '\nShow less',
      style: defaultLabelTextForPost(
        context,
        fontWeight: FontWeight.w500,
        fontColor: theme == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      moreStyle: defaultSmallLabel(context,
          fontWeight: FontWeight.w600,
          fontColor: Theme.of(context).colorScheme.primary),
      lessStyle: defaultSmallLabel(context,
          fontWeight: FontWeight.w600,
          fontColor: Theme.of(context).colorScheme.primary),
    );
  }

  Widget metricRow() {
    return Row(
      children: [
        TextMetric(
          label: 'Follow up threads',
          value: numToEng(widget.comment!.replies!),
          reverse: true,
          compact: true,
          labelColor: Theme.of(context).hintColor,
          valueColor: Theme.of(context).hintColor,
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget actionRow(like, dislike, likes, dislikes, map) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.mediumImpact();
              if (!like) {
                perCommentBloc.add(LikeComment(widget.comment!, map));
              } else {
                perCommentBloc.add(RemoveLikeComment(widget.comment!, map));
              }
            },
            child: IconLabelButton(
                icon: like ? Iconsax.heart_bold : Iconsax.heart_outline,
                label: numToEng(likes),
                iconColor: like ? Colors.red : null),
          ),
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.mediumImpact();
              if (!dislike) {
                perCommentBloc.add(DislikeComment(widget.comment!, map));
              } else {
                perCommentBloc.add(RemoveDislikeComment(widget.comment!, map));
              }
            },
            child: IconLabelButton(
                icon: dislike
                    ? Iconsax.heart_slash_bold
                    : Iconsax.heart_slash_outline,
                label: numToEng(dislikes!),
                iconColor: dislike ? Theme.of(context).hintColor : null),
          ),
          const SizedBox(
            width: 20,
          ),
          (widget.showReplyButton)
              ? InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ReplyToComment(
                        replyingTo: widget.comment!,
                        video: widget.videoPost,
                      ),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation: PageTransitionAnimation.slideUp,
                    );
                  },
                  child: const Icon(
                    BoxIcons.bx_reply,
                    size: 30,
                  ))
              : Container(),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  String buildSecondText() {
    if (widget.comment!.replies == 2) {
      return widget.comment!.topTwoUsers![1].userName!;
    }
    return "others";
  }

  Widget _buildComment(like, dislike, likes, dislikes, map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserProfilePicture(
                        radius: 18,
                        userObj: widget.comment!.commentedBy!,
                        doNothing: true,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(fit: FlexFit.loose, child: userRow()),
                                PopupMenuButton(
                                  child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Theme.of(context).dividerColor,
                                      child: const Icon(
                                        Icons.more_horiz,
                                        size: 16,
                                      )),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 1,
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          const Icon(Icons.report),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Report',
                                            style: defaultSmallLabel(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      onTap: () {
                                        widget.blocDeleteCallback();
                                      },
                                      enabled:
                                          widget.comment!.commentedBy!.userId ==
                                              authHandler.loggedInUser!.userId!,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Delete',
                                            style: defaultSmallLabel(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            (widget.expandedComment)
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      postText(),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      metricRow(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      actionRow(
                                          like, dislike, likes, dislikes, map),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                (!widget.expandedComment)
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            postText(),
                            const SizedBox(
                              height: 20,
                            ),
                            metricRow(),
                            const SizedBox(
                              height: 10,
                            ),
                            actionRow(like, dislike, likes, dislikes, map),
                          ],
                        ),
                      ),
              ],
            ),
            (widget.comment!.topTwoUsers != null &&
                    widget.comment!.topTwoUsers!.isNotEmpty)
                ? Positioned(
                    left: 28,
                    top: 38,
                    child: Container(
                      height: 1000,
                      width: 2,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor,
                      ),
                    ))
                : Container(),
          ],
        ),
        (widget.comment!.topTwoUsers != null &&
                widget.comment!.topTwoUsers!.isNotEmpty &&
                widget.showCommentedByText)
            ? (widget.comment!.topTwoUsers!.length == 1)
                ? Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 18),
                          child: UserProfilePicture(
                              radius: 10,
                              userObj: widget.comment!.topTwoUsers!.first)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextScroll(
                            '${widget.comment!.topTwoUsers!.first.userName} has commented in this thread.',
                            style: defaultSmallLabel(context,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary),
                            velocity:
                                const Velocity(pixelsPerSecond: Offset(25, 0)),
                            mode: TextScrollMode.endless,
                            intervalSpaces: 5),
                      )
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 13),
                        child: Stack(
                          children: [
                            Container(
                                margin: const EdgeInsets.only(left: 12),
                                child: UserProfilePicture(
                                  radius: 8,
                                  userObj: widget.comment!.topTwoUsers![1],
                                )),
                            UserProfilePicture(
                              radius: 8,
                              userObj: widget.comment!.topTwoUsers![0],
                              differentColor: true,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextScroll(
                            '${widget.comment!.topTwoUsers!.first.userName} and ${buildSecondText()}  are in this thread.',
                            style: defaultSmallLabel(context,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary),
                            velocity:
                                const Velocity(pixelsPerSecond: Offset(25, 0)),
                            mode: TextScrollMode.endless,
                            intervalSpaces: 5),
                      )
                    ],
                  )
            : Container(),
        (!widget.showCommentedByText)
            ? Container()
            : Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 0,
                  ),
                ],
              ),
      ],
    );
  }

  @override
  void initState() {
    perCommentBloc = PerCommentBloc(widget.comment!);
    perCommentBloc.add(LoadComment());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
        analytics!.logEvent(
            name: 'comment_post_clicked',
            parameters: <String, Object>{
              'comment_id': widget.comment!.id.toString(),
              'user_id': authHandler.loggedInUser!.userId!.toString()
            });

        if (widget.comment!.replies! != 0) {
          var newComments = [...widget.baseComments!];
          try {
            bool flag = false;
            for (VideoComment i in widget.baseComments!) {
              if (i.id == widget.comment!.id!) {
                flag = true;
              }
            }
            if (!flag) {
              newComments.add(widget.comment!);
            }
          } catch (E) {}
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: FollowUpComments(
              video: widget.videoPost,
              baseComments: newComments,
              hasRootComment: true,
            ),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
      },
      child: BlocConsumer<PerCommentBloc, PerCommentState>(
        bloc: perCommentBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SuccessCommentLoadState) {
            bool like = state.map['like'];
            bool dislike = state.map['dislike'];
            int likes = state.map['total_likes'];
            int dislikes = state.map['total_dislikes'];

            return _buildComment(like, dislike, likes, dislikes, state.map);
          }
          if (state is ErrorCommentState) {
            return const Text("Error occurred");
          }
          if (state is LoadingComment) {
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
                    backgroundColor: Theme.of(context).canvasColor,
                    pathBackgroundColor: Theme.of(context).canvasColor),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
