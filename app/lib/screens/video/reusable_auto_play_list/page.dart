import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/video/reusable_auto_play_list/widget.dart';

import 'package:lime_time_app/screens/video/reusable_auto_play_list/controller.dart';

class ReusableVideoListPage extends StatefulWidget {
  final List<VideoPost> dataList;

  const ReusableVideoListPage({super.key, required this.dataList});
  @override
  _ReusableVideoListPageState createState() => _ReusableVideoListPageState();
}

class _ReusableVideoListPageState extends State<ReusableVideoListPage> {
  ReusableVideoListController videoListController =
      ReusableVideoListController();

  var value = 0;
  int lastMilli = DateTime.now().millisecondsSinceEpoch;
  bool _canBuildVideo = true;
  int? firstVisibleIndex;

  late PageController pageController;
  VideoRepo localVideoRepo = VideoRepo();
  VideoRepo fallback = VideoRepo();

  @override
  void initState() {
    localVideoRepo.videos = widget.dataList;
    pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 0.99);
    pageController.addListener(_onScroll);
    super.initState();
  }

  Future<void> _onScroll() async {
    if (pageController.page == localVideoRepo.videos.length - 1) {
      Isolate.run(addVideos);
    }
  }

  Future<void> addVideos() async {
    try {
      fallback = localVideoRepo;
      localVideoRepo = await VideoEngine()
          .loadRecommendations(localVideoRepo, onlyShortVideos: true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    videoListController.dispose();
    super.dispose();
  }

  void _onFirstVisibleVideoChange(int index) {
    if (firstVisibleIndex != index) {
      setState(() {
        firstVisibleIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final now = DateTime.now();
        final timeDiff = now.millisecondsSinceEpoch - lastMilli;
        if (notification is ScrollUpdateNotification) {
          final pixelsPerMilli = notification.scrollDelta! / timeDiff;
          if (pixelsPerMilli.abs() > 1) {
            _canBuildVideo = false;
          } else {
            _canBuildVideo = true;
          }
          lastMilli = DateTime.now().millisecondsSinceEpoch;
        }

        if (notification is ScrollEndNotification) {
          _canBuildVideo = true;
          lastMilli = DateTime.now().millisecondsSinceEpoch;
        }

        return true;
      },
      child: PageView.builder(
        itemCount: localVideoRepo.videos.length,
        scrollDirection: Axis.vertical,
        controller: pageController,
        itemBuilder: (context, index) {
          VideoPost videoListData = widget.dataList[index];
          return ReusableVideoListWidget(
            videoListData: videoListData,
            videoListController: videoListController,
            canBuildVideo: _checkCanBuildVideo,
            onFirstVisibleVideoChange: _onFirstVisibleVideoChange,
            index: index,
          );
        },
      ),
    );
  }

  bool _checkCanBuildVideo() {
    return _canBuildVideo;
  }
}
