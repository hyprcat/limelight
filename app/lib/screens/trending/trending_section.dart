// ignore_for_file: must_be_immutable, must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/trending/trending_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/video/fake_video.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class TrendingSection extends StatefulWidget {
  String? city;
  String? categoryId;
  String? country;
  String? region;

  bool? dayView = true;
  bool? yearView = false;
  bool? weekView = false;
  bool? monthView = false;
  bool? onlyShortVideos = false;

  TrendingSection(
      {this.city,
      this.categoryId,
      this.country,
      this.region,
      this.dayView,
      this.yearView,
      this.weekView,
      this.monthView,
      this.onlyShortVideos,
      super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  TrendingBloc trendingBloc = TrendingBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    trendingBloc.add(LoadTrendingVideos({
      'category_id': widget.categoryId,
      'city': widget.city,
      'country': widget.country,
      'region': widget.region
    }, widget.dayView!, widget.weekView!, widget.monthView!, widget.yearView!,
        widget.onlyShortVideos!));
    analytics!
        .logEvent(name: 'leaderboards_loaded', parameters: <String, Object>{
      'category_id': widget.categoryId.toString(),
      'clicked_by': authHandler.loggedInUser!.userId!.toString(),
      'city': widget.city.toString(),
      'country': widget.country.toString(),
      'region': widget.region.toString()
    });
    paginationScrollController.init(loadAction: () async {
      int lastPage = trendingBloc.videoRepo.lastPage + 1;
      int currentPage = trendingBloc.videoRepo.currentPage;
      if (lastPage > currentPage) {
        trendingBloc.add(LoadTrendingVideos({
          'category_id': widget.categoryId,
          'city': widget.city,
          'country': widget.country,
          'region': widget.region
        }, widget.dayView!, widget.weekView!, widget.monthView!,
            widget.yearView!, widget.onlyShortVideos!));
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrendingBloc, TrendingState>(
      bloc: trendingBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoadErrorTrendingVideos) {
          return Center(
              child: Text(
            "Error occurred",
            style: defaultLabelText(context, fontWeight: FontWeight.bold),
          ));
        }
        if (state is LoadedTrendingVideosSuccessfully) {
          if (state.repo.videos.isEmpty) {
            return AnimatedCoolRefresh(
              onRefresh: () async {
                paginationScrollController.reset();
                trendingBloc.videoRepo = VideoRepo();
                trendingBloc.add(LoadTrendingVideos({
                  'category_id': widget.categoryId,
                  'city': widget.city,
                  'country': widget.country,
                  'region': widget.region
                }, widget.dayView!, widget.weekView!, widget.monthView!,
                    widget.yearView!, widget.onlyShortVideos!));
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: paginationScrollController.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 500,
                      child: Center(
                        child: Text(
                          "Wow, such empty.",
                          style: defaultSmallLabel(context,
                              fontColor: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimatedCoolRefresh(
              onRefresh: () async {
                paginationScrollController.reset();
                trendingBloc.videoRepo = VideoRepo();
                trendingBloc.add(LoadTrendingVideos({
                  'category_id': widget.categoryId,
                  'city': widget.city,
                  'country': widget.country,
                  'region': widget.region
                }, widget.dayView!, widget.weekView!, widget.monthView!,
                    widget.yearView!, widget.onlyShortVideos!));
              },
              child: state.repo.renderVideos(
                context,
                shouldSetImpression: true,
                renderAsGrid: widget.onlyShortVideos,
                verticalGrid: widget.onlyShortVideos,
                controller: paginationScrollController.scrollController,
              ));
        }
        return AnimatedCoolRefresh(
          onRefresh: () async {
            paginationScrollController.reset();
            trendingBloc.videoRepo = VideoRepo();
            trendingBloc.add(LoadTrendingVideos({
              'category_id': widget.categoryId,
              'city': widget.city,
              'country': widget.country,
              'region': widget.region
            }, widget.dayView!, widget.weekView!, widget.monthView!,
                widget.yearView!, widget.onlyShortVideos!));
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 140),
                child: ListView.builder(
                    itemCount: 4,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      return const ShimmerVideo();
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
