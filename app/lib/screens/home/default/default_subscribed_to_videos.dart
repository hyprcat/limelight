import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/video/fake_video.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class DefaultSubscribedToVideos extends StatefulWidget {
  const DefaultSubscribedToVideos({super.key});

  @override
  State<DefaultSubscribedToVideos> createState() =>
      _DefaultSubscribedToVideosState();
}

class _DefaultSubscribedToVideosState extends State<DefaultSubscribedToVideos> {
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

  void setBadge() async {
    var temp = await NotifierEngine().getNotificationsCount();
    notificationCount.value = temp;
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
            setBadge();
            paginationScrollController.reset();
            subscriptionBloc.recommendationsRepo = VideoRepo();
            subscriptionBloc.add(LoadSubscribedVideos());
          },
          child: ListView.builder(
              itemCount: 5,
              padding: EdgeInsets.zero,
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
            setBadge();
            paginationScrollController.reset();
            subscriptionBloc.recommendationsRepo = VideoRepo();
            subscriptionBloc.add(LoadSubscribedVideos());
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
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecommendedBloc, RecommendedState>(
      bloc: subscriptionBloc,
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
