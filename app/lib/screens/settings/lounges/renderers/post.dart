// ignore_for_file: unused_local_variable, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/posts/posts_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/thread.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:text_scroll/text_scroll.dart';

import 'package:lime_time_app/screens/settings/lounges/renderers/image_viewer.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final bool isThreadable;
  final bool showTail;
  final bool isFirst;
  final bool? forLoungeHome;
  final bool? isExpanded;
  final List<Post> baseComments;
  bool? withoutDp;
  bool showCommentedByText;
  bool? showTopPadding;
  final Function deleteCallbackPost;
  PostWidget(
      {super.key,
      required this.post,
      required this.baseComments,
      this.showCommentedByText = true,
      required this.isThreadable,
      required this.showTail,
      required this.isFirst,
      this.forLoungeHome = false,
      this.isExpanded = false,
      this.withoutDp = false,
      this.showTopPadding = false,
      required this.deleteCallbackPost});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late PostsBloc postsBloc;
  bool isExpanded = false;

  @override
  void initState() {
    postsBloc = PostsBloc(widget.post);
    postsBloc.add(LoadPost());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildFlare(String label, Color color) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 2, bottom: 2),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(15)),
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

    Widget backgroundWrapper2(List<Widget> children) {
      return Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: theme == ThemeMode.light
                ? Theme.of(context).splashColor
                : Theme.of(context).colorScheme.outline,
            borderRadius: BorderRadius.circular(100)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }

    Widget debugSettingsWidget() {
      return debugSettings
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Theme.of(context).dividerColor,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  children: [
                    IconLabelButton(
                        icon: Iconsax.password_check_outline,
                        label: "ID: ${widget.post.id}"),
                    IconLabelButton(
                        icon: Iconsax.password_check_outline,
                        label: "PARENT ID: ${widget.post.parentPost}"),
                    IconLabelButton(
                        icon: Iconsax.password_check_outline,
                        label: "ROOT ID: ${widget.post.rootPost}"),
                    const SizedBox(
                      height: 4,
                    ),
                    Wrap(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        TextMetric(
                            label: "Likes",
                            value: numToEng(widget.post.likes!),
                            reverse: true),
                        const SizedBox(
                          width: 5,
                        ),
                        TextMetric(
                            label: "Impressions",
                            value: numToEng(widget.post.impressions!),
                            reverse: true),
                        const SizedBox(
                          width: 5,
                        ),
                        TextMetric(
                            label: "Dislikes",
                            value: numToEng(widget.post.dislikes!),
                            reverse: true),
                        const SizedBox(
                          width: 5,
                        ),
                        TextMetric(
                            label: "Post Depth",
                            value: numToEng(widget.post.postDepth!),
                            reverse: true),
                        const SizedBox(
                          width: 5,
                        ),
                        TextMetric(
                            label: "Threads",
                            value: numToEng(widget.post.replies!),
                            reverse: true),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                )
              ],
            )
          : Container();
    }

    Widget userRow() {
      return InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen:
                UserChannel(user: widget.post.createdBy!.member, asList: false),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(
                        text: widget.post.createdBy!.member!.userChannel!.name!,
                        style: defaultLabelTextForPost(context,
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text:
                                  " @${widget.post.createdBy!.member!.userName!} ",
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
                            "Level ${widget.post.createdBy!.level!}",
                            style: defaultVerySmallLabelCustom(context,
                                fontColor: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(formatTimeAgo(widget.post.creationDate!),
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

    Widget postText({bool? isBig = false}) {
      return ReadMoreText(
        widget.post.text!,
        trimMode: TrimMode.Line,
        trimLines: 4,
        colorClickableText: Colors.pink,
        trimCollapsedText: '\nShow more',
        trimExpandedText: '\nShow less',
        style: isBig!
            ? defaultNormalText(context,
                fontColor:
                    theme == ThemeMode.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500)
            : defaultLabelTextForPost(context,
                fontColor:
                    theme == ThemeMode.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500),
        moreStyle: defaultSmallLabel(context,
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary),
        lessStyle: defaultSmallLabel(context,
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary),
      );
    }

    Widget metricRow() {
      return Wrap(
        children: [
          TextMetric(
            label: 'Follow up threads',
            value: numToEng(widget.post.replies!),
            reverse: true,
            compact: true,
            labelColor: Theme.of(context).hintColor,
            valueColor: Theme.of(context).hintColor,
          ),
          const SizedBox(
            width: 10,
          ),
          TextMetric(
            label: 'Impressions',
            value: numToEng(widget.post.impressions!),
            reverse: true,
            compact: true,
            labelColor: Theme.of(context).hintColor,
            valueColor: Theme.of(context).hintColor,
          ),
        ],
      );
    }

    Widget actionRow(like, dislike, likes, dislikes) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            widget.forLoungeHome!
                ? Container()
                : InkWell(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.mediumImpact();
                      if (!like) {
                        postsBloc.add(LikePost(widget.post));
                      } else {
                        postsBloc.add(RemoveLike(widget.post));
                      }
                    },
                    child: IconLabelButton(
                      icon: like ? Iconsax.heart_bold : Iconsax.heart_outline,
                      label: numToEng(likes),
                      iconColor: like ? Colors.red : null,
                    ),
                  ),
            widget.forLoungeHome!
                ? Container()
                : const SizedBox(
                    width: 20,
                  ),
            widget.forLoungeHome!
                ? Container()
                : InkWell(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.mediumImpact();
                      if (!dislike) {
                        postsBloc.add(DislikePost(widget.post));
                      } else {
                        postsBloc.add(RemoveDislike(widget.post));
                      }
                    },
                    child: IconLabelButton(
                        icon: dislike
                            ? Iconsax.heart_slash_bold
                            : Iconsax.heart_slash_outline,
                        label: numToEng(dislikes),
                        iconColor:
                            dislike ? Theme.of(context).hintColor : null),
                  ),
            widget.forLoungeHome!
                ? Container()
                : const SizedBox(
                    width: 20,
                  ),
            (!widget.forLoungeHome!)
                ? (widget.showCommentedByText)
                    ? InkWell(
                        onTap: () {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.selectionClick();
                          if (reply.value == widget.post) {
                            reply.value = null;
                          } else {
                            reply.value = widget.post;
                          }
                        },
                        child: buildFlare(
                            'Reply', Theme.of(context).colorScheme.primary),
                      )
                    : Container()
                : Container(),
            !widget.forLoungeHome!
                ? Container()
                : InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: Lounge(user: widget.post.createdBy!.member!),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: backgroundWrapper2([
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: AutoSizeText(
                          widget.post.userLounge!.name!.isNotEmpty
                              ? widget.post.userLounge!.name!
                              : "${widget.post.createdBy!.member!.userName}'s lounge",
                          style: defaultVerySmallLabelCustom(context,
                              fontWeight: FontWeight.bold,
                              fontColor: Theme.of(context).colorScheme.primary),
                          maxLines: 2,
                        ),
                      ),
                    ]),
                  )
          ],
        ),
      );
    }

    String buildSecondText() {
      if (widget.post.replies == 2) {
        return widget.post.topTwoUsers![1].userName!;
      }
      return "others";
    }

    Widget threadPost(like, dislike, likes, dislikes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          debugSettingsWidget(),
          (widget.showTopPadding!)
              ? Container()
              : const SizedBox(
                  height: 15,
                ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!widget.withoutDp!)
                              UserProfilePicture(
                                radius: 18,
                                asSquare: true,
                                userObj: widget.post.createdBy!.member!,
                                doNothing: true,
                                useCache: true,
                              ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                  fit: FlexFit.loose,
                                                  child: userRow()),
                                              if (!widget.withoutDp!)
                                                PopupMenuButton(
                                                  child: CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .dividerColor,
                                                      child: const Icon(
                                                        Icons.more_horiz,
                                                        size: 16,
                                                      )),
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      onTap: () {
                                                        PersistentNavBarNavigator
                                                            .pushNewScreen(
                                                          context,
                                                          screen: ReportScreen(
                                                            post: widget.post,
                                                          ),
                                                          withNavBar:
                                                              true, // OPTIONAL VALUE. True by default.
                                                          pageTransitionAnimation:
                                                              PageTransitionAnimation
                                                                  .cupertino,
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.report),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Report',
                                                            style:
                                                                defaultSmallLabel(
                                                                    context),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      onTap: () {
                                                        widget
                                                            .deleteCallbackPost(
                                                                widget.post);
                                                      },
                                                      enabled: widget
                                                              .post
                                                              .createdBy!
                                                              .member!
                                                              .userId ==
                                                          authHandler
                                                              .loggedInUser!
                                                              .userId!,
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.delete),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Delete',
                                                            style:
                                                                defaultSmallLabel(
                                                                    context),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        postText(),
                                        SizedBox(
                                          height:
                                              (widget.post.attachment == null)
                                                  ? 20
                                                  : 10,
                                        ),
                                        (widget.post.attachment == null)
                                            ? Container()
                                            : InkWell(
                                                onTap: () {
                                                  SystemSound.play(
                                                      SystemSoundType.click);
                                                  HapticFeedback
                                                      .selectionClick();
                                                  PersistentNavBarNavigator
                                                      .pushNewScreen(
                                                    context,
                                                    screen: PostImageViewer(
                                                        post: widget.post),
                                                    withNavBar:
                                                        false, // OPTIONAL VALUE. True by default.
                                                    pageTransitionAnimation:
                                                        PageTransitionAnimation
                                                            .cupertino,
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    placeholder:
                                                        (context, string) {
                                                      return AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor
                                                                  .withAlpha(
                                                                      100)),
                                                          child: Center(
                                                            child: SizedBox(
                                                              height: 50,
                                                              width: 50,
                                                              child:
                                                                  LoadingIndicator(
                                                                      indicatorType:
                                                                          Indicator
                                                                              .lineScalePulseOut,
                                                                      colors: [
                                                                        Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        Theme.of(context)
                                                                            .colorScheme
                                                                            .secondary,
                                                                        Theme.of(context)
                                                                            .colorScheme
                                                                            .tertiary
                                                                      ],
                                                                      strokeWidth:
                                                                          2,
                                                                      backgroundColor:
                                                                          Theme.of(context)
                                                                              .canvasColor,
                                                                      pathBackgroundColor:
                                                                          Theme.of(context)
                                                                              .canvasColor),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    imageUrl:
                                                        loungePostMediaUrl(
                                                            widget.post.id!),
                                                    fit: BoxFit.fill,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                  ),
                                                ),
                                              ),
                                        (widget.post.attachment == null)
                                            ? Container()
                                            : const SizedBox(
                                                height: 20,
                                              ),
                                        metricRow(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        actionRow(
                                            like, dislike, likes, dislikes),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                (widget.post.topTwoUsers != null &&
                            widget.post.topTwoUsers!.isNotEmpty) &&
                        !widget.withoutDp!
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
          ),
          (widget.post.topTwoUsers != null &&
                  widget.post.topTwoUsers!.isNotEmpty &&
                  widget.showCommentedByText)
              ? (widget.post.topTwoUsers!.length == 1)
                  ? Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 18),
                            child: UserProfilePicture(
                                radius: 10,
                                userObj: widget.post.topTwoUsers!.first)),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextScroll(
                              '${widget.post.topTwoUsers!.first.userName} has commented in this thread.',
                              style: defaultVerySmallLabelCustom(
                                context,
                                fontWeight: FontWeight.bold,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              velocity: const Velocity(
                                  pixelsPerSecond: Offset(25, 0)),
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
                                    userObj: widget.post.topTwoUsers![1],
                                  )),
                              UserProfilePicture(
                                radius: 8,
                                userObj: widget.post.topTwoUsers![0],
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
                              '${widget.post.topTwoUsers!.first.userName} and ${buildSecondText()} are in this thread.',
                              style: defaultVerySmallLabelCustom(context,
                                  fontWeight: FontWeight.bold,
                                  fontColor:
                                      Theme.of(context).colorScheme.secondary),
                              velocity: const Velocity(
                                  pixelsPerSecond: Offset(25, 0)),
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
                      height: 20,
                    ),
                    Divider(
                      color: !widget.withoutDp!
                          ? Theme.of(context).dividerColor
                          : Colors.transparent,
                      height: 0,
                    ),
                  ],
                ),
        ],
      );
    }

    Widget expandedPost(like, dislike, likes, dislikes) {
      return Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserProfilePicture(
                    radius: 18,
                    asSquare: true,
                    userObj: widget.post.createdBy!.member!,
                    doNothing: true,
                    useCache: true,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                        fit: FlexFit.loose, child: userRow()),
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
                                          onTap: () {
                                            PersistentNavBarNavigator
                                                .pushNewScreen(
                                              context,
                                              screen: ReportScreen(
                                                post: widget.post,
                                              ),
                                              withNavBar:
                                                  true, // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation:
                                                  PageTransitionAnimation
                                                      .cupertino,
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(Icons.report),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Report',
                                                style:
                                                    defaultSmallLabel(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          onTap: () {
                                            widget.deleteCallbackPost(
                                                widget.post);
                                          },
                                          enabled: widget.post.createdBy!
                                                  .member!.userId ==
                                              authHandler.loggedInUser!.userId!,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Delete',
                                                style:
                                                    defaultSmallLabel(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              postText(isBig: true),
              SizedBox(
                height: (widget.post.attachment == null) ? 20 : 10,
              ),
              (widget.post.attachment == null)
                  ? Container()
                  : InkWell(
                      onTap: () {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: PostImageViewer(post: widget.post),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          placeholder: (context, string) {
                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withAlpha(100)),
                                child: Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
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
                                ),
                              ),
                            );
                          },
                          imageUrl: loungePostMediaUrl(widget.post.id!),
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
              (widget.post.attachment == null)
                  ? Container()
                  : const SizedBox(
                      height: 20,
                    ),
              metricRow(),
              const SizedBox(
                height: 10,
              ),
              actionRow(like, dislike, likes, dislikes),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      );
    }

    return BlocConsumer<PostsBloc, PostsState>(
      bloc: postsBloc,
      listener: (context, state) {
        if (state is PostMessageDeliver) {
          throwHappySnackBar(context, state.message);
        }
        if (state is PostError) {
          throwErrorSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is PostLoadSuccess) {
          bool like = state.map['like'];
          bool dislike = state.map['dislike'];
          int likes = state.map['total_likes'];
          int dislikes = state.map['total_dislikes'];
          return ShowCaseWidget(
            builder: (context) {
              return InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    analytics!.logEvent(
                        name: 'lounge_post_clicked',
                        parameters: <String, Object>{
                          'post_id': widget.post.id.toString(),
                          'user_id':
                              authHandler.loggedInUser!.userId!.toString()
                        });
                    var newBaseComments = [...widget.baseComments];
                    if (widget.post.replies! != 0 || widget.forLoungeHome!) {
                      try {
                        bool flag = false;
                        for (Post i in widget.baseComments) {
                          if (i.id == widget.post.id!) {
                            flag = true;
                          }
                        }
                        if (!flag) {
                          newBaseComments.add(widget.post);
                        }
                      } catch (E) {}

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: LoungePostThreadV2(
                          key: ValueKey<int>(Random().nextInt(9999)),
                          baseComments: newBaseComments,
                          hasRootComment: true,
                        ),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    }
                  },
                  child: !widget.isExpanded!
                      ? threadPost(like, dislike, likes, dislikes)
                      : expandedPost(like, dislike, likes, dislikes));
            },
          );
        }
        if (state is PostError) {
          return const Text("Error occurred");
        }
        return Container();
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  final Color color;
  final int depthMultiplier;
  CurvePainter(this.color, this.depthMultiplier);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    const startPoint = Offset(0, 0);
    final endPoint = Offset(size.width * 2.5, size.height + 10);
    final controlPoint = Offset((size.width / 5), size.height);

    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(startPoint.dx, startPoint.dy, controlPoint.dx, controlPoint.dy,
        endPoint.dx, endPoint.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
