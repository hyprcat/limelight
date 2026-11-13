// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

import 'package:lime_time_app/screens/video/fake_video.dart';

class SuggestedVideos extends StatefulWidget {
  final ScrollController controller;
  final Function? canBuildVideo;
  bool? forMiniPlayer;

  SuggestedVideos(
      {super.key,
      required this.controller,
      required this.canBuildVideo,
      this.forMiniPlayer = false});

  @override
  State<SuggestedVideos> createState() => _SuggestedVideosState();
}

class _SuggestedVideosState extends State<SuggestedVideos> {
  RecommendedBloc recommendedBloc = RecommendedBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
    paginationScrollController.init(loadAction: () async {
      int currentPage = recommendedBloc.recommendationsRepo.currentPage;
      int lastPage = recommendedBloc.recommendationsRepo.lastPage + 1;
      if (lastPage > currentPage) {
        recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
        return false;
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  Widget buildState(context, state) {
    if (state is LoadingRecommended) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return const ShimmerVideo();
            }),
      );
    }
    if (state is RecommendedSuccess) {
      return state.videoRepo.buildThumbnailOnlyList(context, checkCanBuildVideo,
          enablePadding: false,
          shouldSetImpression: true,
          controller: widget.controller,
          physics: const NeverScrollableScrollPhysics(),
          replaceScreen: true,
          renderAsGrid: true,
          forMiniPlayer: widget.forMiniPlayer!);
    }
    if (state is RecommendedError) {
      return Center(
          child: Text(
        "Error occurred",
        style: defaultLabelText(context),
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return const ShimmerVideo();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecommendedBloc, RecommendedState>(
      bloc: recommendedBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: buildState(context, state),
        );
      },
    );
  }
}
