// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/thumbnail_card.dart';
import 'package:lime_time_app/v1_200/cards/short_video_card.dart';
import 'package:lime_time_app/v1_200/cards/thumbnail_card.dart';
import 'package:lime_time_app/v1_300/cards/post_video_card.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class ThumbnailsRenderer extends StatefulWidget {
  final List<VideoPost> data;
  final Function? canBuildVideo;
  final bool shouldSetImpression;
  final bool enablePadding;
  final bool replaceScreen;
  final bool forMiniPlayer;
  final bool renderAsGrid;
  final bool verticalGrid;
  final ScrollPhysics? physics;
  ScrollController? controller;
  ThumbnailsRenderer(
      {super.key,
      required this.data,
      required this.canBuildVideo,
      required this.shouldSetImpression,
      this.enablePadding = true,
      this.controller,
      this.replaceScreen = false,
      this.renderAsGrid = false,
      this.verticalGrid = false,
      this.forMiniPlayer = false,
      required this.physics});

  @override
  State<ThumbnailsRenderer> createState() => _ThumbnailsRendererState();
}

class _ThumbnailsRendererState extends State<ThumbnailsRenderer> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          if (widget.renderAsGrid) {
            return GridView.builder(
              scrollDirection:
                  widget.verticalGrid ? Axis.vertical : Axis.horizontal,
              itemCount: widget.data.length,
              controller: widget.controller ?? controller,
              padding: widget.verticalGrid
                  ? (!widget.enablePadding
                      ? const EdgeInsets.only(top: 0, bottom: 100)
                      : EdgeInsets.only(
                          top: MediaQuery.paddingOf(context).top, bottom: 100))
                  : (!widget.enablePadding ? EdgeInsets.zero : null),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 0.0,
                  crossAxisCount: widget.verticalGrid
                      ? 2
                      : (widget.data.length < 4 ? 1 : 2),
                  childAspectRatio: widget.verticalGrid ? 0.6 : 0.85),
              itemBuilder: (context, index) {
                if (widget.verticalGrid) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ShortVideoCard(
                        video: widget.data[index],
                        actualList: widget.data,
                        indexInList: index),
                  );
                }

                if (isExperimental) {
                  return ThumbnailCardExperimental(
                    shouldSetImpression: widget.shouldSetImpression,
                    video: widget.data[index],
                    canBuildVideo: checkCanBuildVideo,
                    replaceScreen: widget.replaceScreen,
                    forMiniPlayer: widget.forMiniPlayer,
                  );
                }

                return ThumbnailCard(
                  shouldSetImpression: widget.shouldSetImpression,
                  video: widget.data[index],
                  canBuildVideo: checkCanBuildVideo,
                  replaceScreen: widget.replaceScreen,
                  forMiniPlayer: widget.forMiniPlayer,
                );
              },
            );
          }

          return ListView.builder(
              controller: widget.controller ?? controller,
              shrinkWrap: true,
              padding: !widget.enablePadding
                  ? const EdgeInsets.only(top: 0, bottom: 100)
                  : EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top, bottom: 100),
              physics: widget.physics ?? const BouncingScrollPhysics(),
              itemCount: widget.data.length,
              addAutomaticKeepAlives: false,
              itemBuilder: (context, index) {
                return PostVideoCard(
                  shouldSetImpression: widget.shouldSetImpression,
                  video: widget.data[index],
                  canBuildVideo: checkCanBuildVideo,
                  replaceScreen: widget.replaceScreen,
                  forMiniPlayer: widget.forMiniPlayer,
                );
              });
        });
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
