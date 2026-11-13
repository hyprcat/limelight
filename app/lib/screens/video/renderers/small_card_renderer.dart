import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/small_card.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class SmallCardRenderer extends StatefulWidget {
  final List<VideoPost> data;
  final Function? canBuildVideo;
  final bool shouldSetImpression;
  const SmallCardRenderer(
      {super.key,
      required this.canBuildVideo,
      required this.data,
      required this.shouldSetImpression});

  @override
  State<SmallCardRenderer> createState() => _SmallCardRendererState();
}

class _SmallCardRendererState extends State<SmallCardRenderer> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          return ListView.builder(
              controller: controller,
              physics: physics,
              shrinkWrap: true,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor))),
                  child: SmallCard(
                    video: widget.data[index],
                    canBuildVideo: checkCanBuildVideo,
                  ),
                );
              });
        });
  }
}
