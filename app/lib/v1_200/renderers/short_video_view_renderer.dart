import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/upload_video/upload_file_card.dart';
import 'package:lime_time_app/screens/video/reusable_auto_play_list/controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/v1_200/shorts/short_video_expanded.dart';

class ShortVideoViewRenderer extends StatefulWidget {
  int? index;
  int currentPage;
  int totalPages;
  List<VideoPost>? followUp;
  ShortVideoViewRenderer(
      {super.key,
      this.currentPage = 1,
      this.totalPages = 1,
      this.index,
      this.followUp});

  @override
  State<ShortVideoViewRenderer> createState() => _ShortVideoViewRendererState();
}

class _ShortVideoViewRendererState extends State<ShortVideoViewRenderer> {
  late PageController pageController;

  VideoRepo localVideoRepo = VideoRepo();
  VideoRepo fallback = VideoRepo();

  var value = 0;
  int lastMilli = DateTime.now().millisecondsSinceEpoch;
  bool _canBuildVideo = true;
  ReusableVideoListController videoListController =
      ReusableVideoListController();
  @override
  void initState() {
    localVideoRepo.currentPage = widget.currentPage;
    localVideoRepo.lastPage = widget.totalPages;
    localVideoRepo.videos = widget.followUp!;
    pageController = PageController(
      initialPage: widget.index!,
      keepPage: false,
      viewportFraction: 0.97,
    );
    pageController.addListener(_onScroll);
    super.initState();
  }

  Future<void> _onScroll() async {
    if (pageController.page == localVideoRepo.videos.length - 1) {
      addVideos();
    }
  }

  Future<void> addVideos() async {
    try {
      fallback = localVideoRepo;
      localVideoRepo = await VideoEngine()
          .loadRecommendations(localVideoRepo, onlyShortVideos: true);

      setState(() {});
    } catch (e) {
      localVideoRepo = fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 40,
        leading: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).focusColor,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              onPressed: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
            )),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.5),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.5),
        title: Text(
          "Shorts",
          style: defaultLabelTextC(context, fontWeight: FontWeight.bold),
        ),
        actions: [
          CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).focusColor,
              child: IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                onPressed: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.selectionClick();
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const ImportVideoCard(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              )),
        ],
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
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
                pageSnapping: true,
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return ShortVideoExpanded(
                    currentIndex: index,
                    data: localVideoRepo.videos,
                    video: localVideoRepo.videos[index],
                    videoListController: videoListController,
                    canBuildVideo: _checkCanBuildVideo,
                  );
                }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 55,
              width: double.infinity,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  bool _checkCanBuildVideo() {
    return _canBuildVideo;
  }
}
