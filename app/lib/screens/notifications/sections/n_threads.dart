import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/notifications/threads/n_threads_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/notifications/threads.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NThreads extends StatefulWidget {
  const NThreads({super.key});

  @override
  State<NThreads> createState() => _NThreadsState();
}

class _NThreadsState extends State<NThreads> {
  NThreadsBloc nThreadsBloc = NThreadsBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nThreadsBloc.add(LoadNThreads());
    paginationScrollController.init(loadAction: () async {
      int lastPage = nThreadsBloc.repo.lastPage + 1;
      int currentPage = nThreadsBloc.repo.currentPage;
      if (lastPage > currentPage) {
        nThreadsBloc.add(LoadNThreads());
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NThreadsBloc, NThreadsState>(
      bloc: nThreadsBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NThreadsSuccess) {
          if (state.repo.loungePostReply.isEmpty &&
              state.repo.videoCommentReply.isEmpty &&
              state.repo.loungeReply.isEmpty &&
              state.repo.videoComments.isEmpty) {
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
              nThreadsBloc.repo = ThreadNotifications();
              nThreadsBloc.add(LoadNThreads());
            },
            child: ListView(
              physics: const BouncingScrollPhysics(),
              controller: paginationScrollController.scrollController,
              children: state.repo.getCombinedNotifications(),
            ),
          );
        }

        if (state is NThreadsError) {
          return const Center(
            child: Text("Error occurred."),
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
