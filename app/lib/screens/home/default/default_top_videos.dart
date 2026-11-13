import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/video/fake_video.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';

class DefaultTopVideos extends StatefulWidget {
  const DefaultTopVideos({super.key});

  @override
  State<DefaultTopVideos> createState() => _DefaultTopVideosState();
}

class _DefaultTopVideosState extends State<DefaultTopVideos>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
    paginationScrollController.init(loadAction: () async {
      int lastPage = recommendedBloc.recommendationsRepo.lastPage + 1;
      int currentPage = recommendedBloc.recommendationsRepo.currentPage;
      if (lastPage > currentPage) {
        recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
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

  void setBadge() async {
    var temp = await NotifierEngine().getNotificationsCount();
    notificationCount.value = temp;
  }

  Widget buildState(context, state) {
    if (state is LoadingRecommended) {
      return AnimatedCoolRefresh(
        onRefresh: () async {
          setBadge();
          paginationScrollController.reset();
          recommendedBloc.recommendationsRepo = VideoRepo();
          recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
        },
        child: ListView.builder(
            itemCount: 3,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return const ShimmerVideo();
            }),
      );
    }
    if (state is RecommendedSuccess) {
      return AnimatedCoolRefresh(
          onRefresh: () async {
            setBadge();
            paginationScrollController.reset();
            recommendedBloc.recommendationsRepo = VideoRepo();
            recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
          },
          child: state.videoRepo.renderVideos(context,
              shouldSetImpression: true,
              controller: paginationScrollController.scrollController,
              enablePadding: false));
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
        recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
      },
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return const ShimmerVideo();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
