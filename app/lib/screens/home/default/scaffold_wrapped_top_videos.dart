import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

import 'package:lime_time_app/screens/video/fake_video.dart';

class TopVideosScreen extends StatefulWidget {
  final bool onlyShortVideos;
  const TopVideosScreen({super.key, required this.onlyShortVideos});

  @override
  State<TopVideosScreen> createState() => _TopVideosScreenState();
}

class _TopVideosScreenState extends State<TopVideosScreen> {
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos',
        onlyShortVideos: widget.onlyShortVideos));
    paginationScrollController.init(loadAction: () async {
      int lastPage = recommendedBloc.recommendationsRepo.lastPage + 1;
      int currentPage = recommendedBloc.recommendationsRepo.currentPage;
      if (lastPage > currentPage) {
        recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos',
            onlyShortVideos: widget.onlyShortVideos));
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  Widget buildState(context, state) {
    if (state is LoadingRecommended) {
      return AnimatedCoolRefresh(
        onRefresh: () async {
          paginationScrollController.reset();
          recommendedBloc.recommendationsRepo = VideoRepo();
          recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos',
              onlyShortVideos: widget.onlyShortVideos));
        },
        child: ListView.builder(
            itemCount: 3,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return const ShimmerVideo();
            }),
      );
    }
    if (state is RecommendedSuccess) {
      return AnimatedCoolRefresh(
          onRefresh: () async {
            paginationScrollController.reset();
            recommendedBloc.recommendationsRepo = VideoRepo();
            recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos',
                onlyShortVideos: widget.onlyShortVideos));
          },
          child: state.videoRepo.renderVideos(context,
              shouldSetImpression: true,
              verticalGrid: widget.onlyShortVideos,
              renderAsGrid: widget.onlyShortVideos,
              controller: paginationScrollController.scrollController,
              enablePadding: true));
    }
    if (state is RecommendedError) {
      return Center(
          child: Text(
        "Error occurred",
        style: defaultLabelText(context),
      ));
    }
    return AnimatedCoolRefresh(
      onRefresh: () async {
        paginationScrollController.reset();
        recommendedBloc.recommendationsRepo = VideoRepo();
        recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos',
            onlyShortVideos: widget.onlyShortVideos));
      },
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return const ShimmerVideo();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
          surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
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
          title: Text(
            "Top videos",
            style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<RecommendedBloc, RecommendedState>(
          bloc: recommendedBloc,
          listener: (context, state) {},
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: buildState(context, state),
            );
          },
        ));
  }
}
