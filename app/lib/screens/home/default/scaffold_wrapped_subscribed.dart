import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/video/fake_video.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class SubscribedVideosScreen extends StatefulWidget {
  const SubscribedVideosScreen({super.key});

  @override
  State<SubscribedVideosScreen> createState() => _SubscribedVideosScreenState();
}

class _SubscribedVideosScreenState extends State<SubscribedVideosScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    paginationScrollController.init(loadAction: () async {
      int lastPage = subscriptionBloc.recommendationsRepo.lastPage + 1;
      int currentPage = subscriptionBloc.recommendationsRepo.currentPage;
      if (lastPage > currentPage) {
        // do some data fetching here, e.g.
        subscriptionBloc.add(LoadSubscribedVideos());
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
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: AnimatedCoolRefresh(
          onRefresh: () async {
            paginationScrollController.reset();
            subscriptionBloc.recommendationsRepo = VideoRepo();
            subscriptionBloc.add(LoadSubscribedVideos());
          },
          child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                // ignore: prefer_const_constructors
                return ShimmerVideo();
              }),
        ),
      );
    }
    if (state is RecommendedSuccess) {
      return AnimatedCoolRefresh(
          onRefresh: () async {
            paginationScrollController.reset();
            subscriptionBloc.recommendationsRepo = VideoRepo();
            subscriptionBloc.add(LoadSubscribedVideos());
          },
          child: state.videoRepo.renderVideos(context,
              shouldSetImpression: true,
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
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          "Videos from your subscription",
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<RecommendedBloc, RecommendedState>(
        bloc: subscriptionBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: buildState(context, state),
          );
        },
      ),
    );
  }
}
