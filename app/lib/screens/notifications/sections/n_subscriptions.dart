import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/notifications/subscriptions/n_subscriptions_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/notifications/subscriptions.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NSubscriptions extends StatefulWidget {
  const NSubscriptions({super.key});

  @override
  State<NSubscriptions> createState() => _NSubscriptionsState();
}

class _NSubscriptionsState extends State<NSubscriptions> {
  NSubscriptionsBloc nForYou = NSubscriptionsBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nForYou.add(LoadSubscriptionsNotification());

    paginationScrollController.init(loadAction: () async {
      int lastPage = nForYou.repo.lastPage + 1;
      int currentPage = nForYou.repo.currentPage;
      if (lastPage > currentPage) {
        nForYou.add(LoadSubscriptionsNotification());
      } else if (lastPage == currentPage) {
        return true;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NSubscriptionsBloc, NSubscriptionsState>(
      bloc: nForYou,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NSubscriptionLoaded) {
          if (state.repo.subscriptions.isEmpty) {
            return Center(
              child: Text(
                "Wow, such empty.",
                style: defaultSmallLabel(context,
                    fontColor: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          return AnimatedCoolRefresh(
            onRefresh: () async {
              nForYou.repo = SubscriptionsRepo();
              nForYou.add(LoadSubscriptionsNotification());
            },
            child: ListView(
              addAutomaticKeepAlives: true,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: paginationScrollController.scrollController,
              children: state.repo.getCombinedNotifications(),
            ),
          );
        }

        if (state is NSubscriptionError) {
          return const Center(
            child: Text("ERror"),
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
