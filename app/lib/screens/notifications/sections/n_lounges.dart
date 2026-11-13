import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/notifications/lounges/n_lounges_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/notifications/lounges.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NLoungeScreen extends StatefulWidget {
  const NLoungeScreen({super.key});

  @override
  State<NLoungeScreen> createState() => _NLoungeScreenState();
}

class _NLoungeScreenState extends State<NLoungeScreen> {
  NLoungesBloc nLoungesBloc = NLoungesBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nLoungesBloc.add(LoadNLounges());

    paginationScrollController.init(loadAction: () async {
      int lastPage = nLoungesBloc.repo.lastPage + 1;
      int currentPage = nLoungesBloc.repo.currentPage;
      if (lastPage > currentPage) {
        nLoungesBloc.add(LoadNLounges());
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NLoungesBloc, NLoungesState>(
      bloc: nLoungesBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NLoungeSuccess) {
          if (state.repo.loungePostNotification.isEmpty) {
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
              nLoungesBloc.repo = LoungeNotificationRepo();
              nLoungesBloc.add(LoadNLounges());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: paginationScrollController.scrollController,
              children: state.repo.getCombinedNotifications(),
            ),
          );
        }
        if (state is NLoungeError) {
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
