import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/videos/watched_videos/watched_videos_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';

class WatchHistory extends StatefulWidget {
  const WatchHistory({super.key});

  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory> {
  WatchedVideosBloc watchedVideosBloc = WatchedVideosBloc();

  @override
  void initState() {
    watchedVideosBloc.add(LoadWatchedVideos());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          "Watch History",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<WatchedVideosBloc, WatchedVideosState>(
        bloc: watchedVideosBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoadedWatchedVideos) {
            return DynMouseScroll(
                durationMS: 200,
                scrollSpeed: 4.4,
                animationCurve: Curves.easeInOut,
                builder: (context, controller, physics) {
                  return ListView(
                    controller: controller,
                    physics: physics,
                    shrinkWrap: true,
                    children: [
                      state.repo.buildSmallCard(
                          context,
                          controller: controller,
                          physics: physics,
                          shouldSetImpression: false,
                          checkCanBuildVideo)
                    ],
                  );
                });
          }
          if (state is ErrorWatchedVideos) {
            return Center(
                child: Text(
              "Error occurred",
              style: defaultLabelText(context),
            ));
          }
          return Container();
        },
      ),
    );
  }
}
