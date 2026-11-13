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

class InlineVideoActionRow extends StatefulWidget {
  final VideoPost video;
  final Function? updateVideoCallback;
  final Function? showCommentsCallback;

  const InlineVideoActionRow(
      {super.key,
      required this.video,
      this.updateVideoCallback,
      this.showCommentsCallback});

  @override
  State<InlineVideoActionRow> createState() => _InlineVideoActionRowState();
}

class _InlineVideoActionRowState extends State<InlineVideoActionRow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoActionsBloc videoActionsBloc = VideoActionsBloc();

  Widget _backgroundWrapper(List<Widget> children) {
    return Row(
      children: children,
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
          return Container(
            margin: const EdgeInsets.only(right: 0, bottom: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                        vertical: false,
                        iconColor: like
                            ? Colors.red
                            : Theme.of(context).colorScheme.inverseSurface,
                        isBig: false,
                      ),
                    ),
                    const SizedBox(
                      width: 7.5,
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
                        isBig: false,
                        vertical: false,
                        iconColor: dislike
                            ? Theme.of(context).hintColor
                            : Theme.of(context).colorScheme.inverseSurface,
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
                        icon: Iconsax.messages_outline,
                        isBig: false,
                        vertical: false,
                        label: numToEng(widget.video.comments!),
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
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
                        icon: Iconsax.repeat_outline,
                        isBig: false,
                        vertical: false,
                        label: numToEng(widget.video.comments!),
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ]),
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
                        icon: Icons.reply,
                        isBig: false,
                        vertical: false,
                        label: numToEng(widget.video.comments!),
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
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
