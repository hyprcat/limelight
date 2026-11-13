// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/screens/video/video_card.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class VideosRenderer extends StatefulWidget {
  final List<VideoPost> dataList;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Function? canBuildVideo;
  final bool? shouldSetImpression;

  const VideosRenderer(
      {super.key,
      required this.dataList,
      this.controller,
      this.physics,
      this.canBuildVideo,
      this.shouldSetImpression});
  @override
  _VideosRendererState createState() => _VideosRendererState();
}

bool _canBuildVideo = true;
bool checkCanBuildVideo() {
  return _canBuildVideo;
}

class _VideosRendererState extends State<VideosRenderer> {
  var value = 0;
  int lastMilli = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }

  final ScrollPhysics _physics = const ScrollPhysics();
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.dataList.length,
      controller: widget.controller ?? _controller,
      physics: widget.physics ?? _physics,
      itemBuilder: (context, index) {
        VideoPost videoListData = widget.dataList[index];
        return VideoCard(
          shouldSetImpression: true,
          video: videoListData,
          canBuildVideo: checkCanBuildVideo,
          cardType: true,
          actionCallback: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ExpandedVideo(
                  video: videoListData, canBuildVideo: checkCanBuildVideo),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.slideUp,
            );
          },
        );
      },
    );
  }
}
