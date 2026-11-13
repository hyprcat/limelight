// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/v1_200/cards/short_video_card.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class ShortVideoRenderer extends StatefulWidget {
  final List<VideoPost> data;
  final Function? canBuildVideo;
  final bool shouldSetImpression;
  final bool enablePadding;
  final bool replaceScreen;
  final bool forMiniPlayer;
  final bool renderAsGrid;
  final ScrollPhysics? physics;
  ScrollController? controller;
  ShortVideoRenderer(
      {super.key,
      required this.data,
      required this.canBuildVideo,
      required this.shouldSetImpression,
      this.enablePadding = true,
      this.controller,
      this.replaceScreen = false,
      this.renderAsGrid = false,
      this.forMiniPlayer = false,
      required this.physics});

  @override
  State<ShortVideoRenderer> createState() => _ShortVideoRendererState();
}

class _ShortVideoRendererState extends State<ShortVideoRenderer> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          return ScrollConfiguration(
              behavior: AppScrollBehavior(),
              child: GridView.builder(
                addAutomaticKeepAlives: true,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                itemCount: widget.data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 3.0,
                    crossAxisCount: 1,
                    childAspectRatio: 1.8),
                itemBuilder: (context, index) {
                  return ShortVideoCard(
                    indexInList: index,
                    actualList: widget.data,
                    video: widget.data[index],
                  );
                },
              ));
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
