import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/notifications/for_you.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:lime_time_app/bloc/notifications/for_you/n_for_you_bloc.dart';

class NForYou extends StatefulWidget {
  const NForYou({super.key});

  @override
  State<NForYou> createState() => _NForYouState();
}

class _NForYouState extends State<NForYou> {
  NForYouBloc nForYou = NForYouBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nForYou.add(LoadNForYOu());
    paginationScrollController.init(loadAction: () async {
      int lastPage = nForYou.repo.lastPage + 1;
      int currentPage = nForYou.repo.currentPage;
      if (lastPage > currentPage) {
        nForYou.add(LoadNForYOu());
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NForYouBloc, NForYouState>(
      bloc: nForYou,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NForYouSuccess) {
          if (state.repo.promotions.isEmpty &&
              state.repo.videoProcessed.isEmpty) {
            return SizedBox(
              height: 500,
              child: Center(
                child: Text(
                  "Wow, such empty.",
                  style: defaultSmallLabel(context,
                      fontColor: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          return AnimatedCoolRefresh(
            onRefresh: () async {
              nForYou.repo = ForYouRepo();
              nForYou.add(LoadNForYOu());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: paginationScrollController.scrollController,
              children: state.repo.getCombinedNotifications(),
            ),
          );
        }

        if (state is NForYouError) {
          return const Center(
            child: Text("Error"),
          );
        }

        return Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary
                ],
                strokeWidth: 2,
                backgroundColor: Theme.of(context).canvasColor,
                pathBackgroundColor: Theme.of(context).canvasColor),
          ),
        );
      },
    );
  }
}
