// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/videos/actions/video_actions_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';

import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';

class VideoActionRowVertical extends StatefulWidget {
  final VideoPost video;
  final Function? updateVideoCallback;
  final Function? showCommentsCallback;

  const VideoActionRowVertical(
      {super.key,
      required this.video,
      this.updateVideoCallback,
      this.showCommentsCallback});

  @override
  State<VideoActionRowVertical> createState() => _VideoActionRowVerticalState();
}

class _VideoActionRowVerticalState extends State<VideoActionRowVertical>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoActionsBloc videoActionsBloc = VideoActionsBloc();

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  void initState() {
    videoActionsBloc.add(LoadVideoActions(widget.video));
    super.initState();
  }

  void reflectBack(int likes, int dislikes) {
    widget.video.likes = likes;
    widget.video.dislikes = dislikes;
    widget.updateVideoCallback!(likes, dislikes);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<VideoActionsBloc, VideoActionsState>(
      bloc: videoActionsBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is VideoActionsEmitSuccess) {
          bool like = state.reactionMap['like'];
          bool dislike = state.reactionMap['dislike'];
          int likes = state.reactionMap['total_likes'];
          int dislikes = state.reactionMap['total_dislikes'];
          reflectBack(likes, dislikes);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _backgroundWrapper([
                InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.mediumImpact();
                    if (!like) {
                      analytics!.logEvent(
                          name: 'video_liked',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      videoActionsBloc.add(LikeVideo(widget.video));
                    } else {
                      analytics!.logEvent(
                          name: 'like_removed',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      videoActionsBloc.add(RemoveLike(widget.video));
                    }
                  },
                  child: IconLabelButton(
                    icon: like ? Iconsax.heart_bold : Iconsax.heart_outline,
                    label: numToEng(likes),
                    isBig: true,
                    vertical: true,
                    iconColor: like ? Colors.red : Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.mediumImpact();
                    if (!dislike) {
                      analytics!.logEvent(
                          name: 'video_disliked',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      videoActionsBloc.add(DisLikeVideo(widget.video));
                    } else {
                      analytics!.logEvent(
                          name: 'dislike_removed',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      videoActionsBloc.add(RemoveDisLike(widget.video));
                    }
                  },
                  child: IconLabelButton(
                    icon: dislike
                        ? Iconsax.heart_slash_bold
                        : Iconsax.heart_slash_outline,
                    label: numToEng(dislikes),
                    isBig: true,
                    vertical: true,
                    iconColor:
                        dislike ? Theme.of(context).hintColor : Colors.white,
                  ),
                ),
              ]),
              const SizedBox(
                width: 5,
              ),
              _backgroundWrapper([
                InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    analytics!.logEvent(
                        name: 'opened_threads',
                        parameters: <String, Object>{
                          'video_id': widget.video.id.toString(),
                          'user_id':
                              authHandler.loggedInUser!.userId!.toString()
                        });
                    widget.showCommentsCallback!();
                  },
                  child: IconLabelButton(
                    icon: Iconsax.message_outline,
                    isBig: true,
                    vertical: true,
                    label: numToEng(widget.video.comments!),
                    iconColor: Colors.white,
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: PopupMenuButton(
                  child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Theme.of(context).dividerColor,
                      child: const Icon(
                        Icons.more_horiz,
                        size: 16,
                      )),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      onTap: () {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ReportScreen(
                            videoPost: widget.video,
                          ),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.report),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Report User',
                            style: defaultSmallLabel(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              )
            ],
          );
        }
        if (state is VideoActionsError) {
          return Center(
            child: Text(
              "Error occured.",
              style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
            ),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(10),
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
          ],
        );
      },
    );
  }
}
