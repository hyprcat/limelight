// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/leaderboards/leaderboard_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class LeaderboardSection extends StatefulWidget {
  String? city;
  String? categoryId;
  String? country;
  String? region;

  bool? dayView = true;
  bool? weekView = false;
  bool? monthView = false;

  LeaderboardSection({
    super.key,
    this.city,
    this.categoryId,
    this.country,
    this.region,
    this.dayView,
    this.weekView,
    this.monthView,
  });

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  LeaderboardBloc leaderboardBloc = LeaderboardBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    leaderboardBloc.add(LoadLeaderboard(
        isDay: widget.dayView!,
        isWeek: widget.weekView!,
        isMonth: widget.monthView!,
        data: {
          'city': widget.city,
          'country': widget.country,
          'region': widget.region
        }));

    analytics!
        .logEvent(name: 'leaderboards_loaded', parameters: <String, Object>{
      'clicked_by': authHandler.loggedInUser!.userId!,
      'city': widget.city.toString(),
      'country': widget.country.toString(),
      'region': widget.region.toString()
    });
    paginationScrollController.init(loadAction: () async {
      int lastPage = leaderboardBloc.repo.lastPage + 1;
      int currentPage = leaderboardBloc.repo.currentPage;
      if (lastPage > currentPage) {
        leaderboardBloc.add(LoadLeaderboard(
            isDay: widget.dayView!,
            isWeek: widget.weekView!,
            isMonth: widget.monthView!,
            data: {
              'city': widget.city,
              'country': widget.country,
              'region': widget.region
            }));
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  Widget buildState(context, state) {
    if (state is LoadedLeaderboards) {
      if (state.repo.profiles.isEmpty) {
        return AnimatedCoolRefresh(
          onRefresh: () async {
            paginationScrollController.reset();
            leaderboardBloc.repo = UserRepo();
            leaderboardBloc.add(LoadLeaderboard(
                isDay: widget.dayView!,
                isWeek: widget.weekView!,
                isMonth: widget.monthView!,
                data: {
                  'city': widget.city,
                  'country': widget.country,
                  'region': widget.region
                }));
          },
          child: ListView(
            controller: paginationScrollController.scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Wow, such empty.",
                        style: defaultSmallXLabelCustom(context,
                            fontColor: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }

      return AnimatedCoolRefresh(
        onRefresh: () async {
          paginationScrollController.reset();
          leaderboardBloc.repo = UserRepo();
          leaderboardBloc.add(LoadLeaderboard(
              isDay: widget.dayView!,
              isWeek: widget.weekView!,
              isMonth: widget.monthView!,
              data: {
                'city': widget.city,
                'country': widget.country,
                'region': widget.region
              }));
        },
        child: ListView(
          controller: paginationScrollController.scrollController,
          addAutomaticKeepAlives: false,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [state.repo.renderProfiles(context, showRanks: true)],
        ),
      );
    }
    if (state is LeaderboardsError) {
      return Center(
          child: Text(
        "Error occurred",
        style: defaultLabelText(context),
      ));
    }
    return AnimatedCoolRefresh(
      onRefresh: () async {
        paginationScrollController.reset();
        leaderboardBloc.repo = UserRepo();
        leaderboardBloc.add(LoadLeaderboard(
            isDay: widget.dayView!,
            isWeek: widget.weekView!,
            isMonth: widget.monthView!,
            data: {
              'city': widget.city,
              'country': widget.country,
              'region': widget.region
            }));
      },
      child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return const FakeProfileCard();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaderboardBloc, LeaderboardState>(
      bloc: leaderboardBloc,
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
