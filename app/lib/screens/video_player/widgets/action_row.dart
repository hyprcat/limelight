// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/videos/actions/video_actions_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/playlist_engine.dart';
import 'package:lime_time_app/logics/models/videos/playlist.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/playlist_repo.dart';
import 'package:lime_time_app/main.dart';

import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';
import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class VideoActionRow extends StatefulWidget {
  final VideoPost video;
  final Function? updateVideoCallback;
  final Function? showCommentsCallback;

  const VideoActionRow(
      {super.key,
      required this.video,
      this.updateVideoCallback,
      this.showCommentsCallback});

  @override
  State<VideoActionRow> createState() => _VideoActionRowState();
}

class _VideoActionRowState extends State<VideoActionRow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoActionsBloc videoActionsBloc = VideoActionsBloc();

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).focusColor, width: 2),
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
      child: Row(
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
    Widget buildBlurTextButton(PlayList obj, bool value) {
      return InkWell(
        onTap: () {},
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Checkbox(
                  value: value,
                  onChanged: (value) async {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    if (!value!) {
                      analytics!.logEvent(
                          name: 'video_removed_from_playlist',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'playlist_id': obj.playlistId!.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      String msg = await PlaylistHelper().removeVideoToPlaylist(
                          obj.playlistId!, widget.video.id!);
                      Navigator.pop(context);
                      throwHappySnackBar(context, msg);
                    } else {
                      analytics!.logEvent(
                          name: 'video_added_to_playlist',
                          parameters: <String, Object>{
                            'video_id': widget.video.id.toString(),
                            'playlist_id': obj.playlistId!.toString(),
                            'user_id':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      String msg = await PlaylistHelper().addVideoToPlaylist(
                          obj.playlistId!, widget.video.id!);
                      Navigator.pop(context);
                      throwHappySnackBar(context, msg);
                    }
                  }),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(obj.name!,
                      style: defaultNormalText(context,
                          fontWeight: FontWeight.normal))),
            ],
          ),
        ),
      );
    }

    Widget buildBlurHeadingButton(String text) {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style:
                      defaultHeadingText(context, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

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
            margin: const EdgeInsets.only(right: 0, bottom: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
                        label: numToEng(likes) + " Likes",
                        vertical: true,
                        iconColor: like
                            ? Colors.red
                            : Theme.of(context).colorScheme.inverseSurface,
                        isBig: false,
                      ),
                    ),
                    const SizedBox(
                      width: 7.5,
                    ),
                    Container(
                      height: 20,
                      width: 2,
                      color: Theme.of(context).disabledColor,
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
                        label: numToEng(dislikes) + " Dislikes",
                        isBig: false,
                        vertical: true,
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
                        icon: Iconsax.message_outline,
                        isBig: false,
                        vertical: true,
                        label: numToEng(widget.video.comments!) + " Threads",
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ]),
                  const SizedBox(
                    width: 5,
                  ),
                  _backgroundWrapper([
                    InkWell(
                      onTap: () async {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        PlayListRepo repo = PlayListRepo();
                        repo = await PlaylistHelper().getAllPlaylist(
                            authHandler.loggedInUser!.userId.toString(), repo);
                        var repo2 = await PlaylistHelper().quickFetchPlaylists(
                            widget.video.id!, PlayListRepo());
                        repo.markPlaylistContainingVideo(repo2);

                        if (repo.playlists.isEmpty) {
                          throwErrorSnackBar(context,
                              "You have not created any playlist yet. Please create one first.");
                        } else {
                          showBlurMenu([
                            buildBlurHeadingButton(
                                "Select a playlist to add this video."),
                            for (PlayList i in repo.playlists)
                              buildBlurTextButton(i, i.videoExistsInPlaylist)
                          ], context);
                        }
                      },
                      child: IconLabelButton(
                        icon: Iconsax.video_add_outline,
                        label: 'Save to playlist',
                        isBig: false,
                        vertical: true,
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ]),
                  const SizedBox(
                    width: 5,
                  ),
                  _backgroundWrapper([
                    InkWell(
                      onTap: () async {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ReportScreen(
                            videoPost: widget.video,
                          ),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.slideUp,
                        );
                      },
                      child: IconLabelButton(
                        icon: Iconsax.flag_outline,
                        label: 'Report',
                        isBig: false,
                        vertical: true,
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ])
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
