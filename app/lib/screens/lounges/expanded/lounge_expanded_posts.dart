import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/lounge_expanded/lounge_expanded_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';

class LoungeExpandedVideo extends StatefulWidget {
  final String sectionName;
  final bool alternateSourceData;
  const LoungeExpandedVideo(
      {super.key,
      required this.sectionName,
      required this.alternateSourceData});

  @override
  State<LoungeExpandedVideo> createState() => _LoungeExpandedVideoState();
}

class _LoungeExpandedVideoState extends State<LoungeExpandedVideo> {
  late LoungeExpandedBloc localBloc;
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    PostRepo repo = PostRepo();
    localBloc = LoungeExpandedBloc(repo, null);

    String endpoint = "";
    if (!widget.alternateSourceData) {
      endpoint = 'get_top_user_joined_lounge_posts';
    } else {
      endpoint = 'get_top_lounge_posts';
    }
    localBloc.add(LoadMorePosts(endpoint));
    paginationScrollController.init(loadAction: () async {
      int lastPage = localBloc.repo!.totalPage + 1;
      int currentPage = localBloc.repo!.currentPage;
      if (lastPage > currentPage) {
        // do some data fetching here, e.g.
        localBloc.add(LoadMorePosts(endpoint));
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
          "Top Threads",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<LoungeExpandedBloc, LoungeExpandedState>(
        bloc: localBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is PostFetchedSuccess) {
            return state.repo.posts.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    controller: paginationScrollController.scrollController,
                    itemCount: state.repo.posts.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return PostWidget(
                        post: state.repo.posts[index],
                        isThreadable: true,
                        showTail: false,
                        isFirst: true,
                        forLoungeHome: true,
                        isExpanded: false,
                        deleteCallbackPost: () {},
                        baseComments: const [],
                      );
                    })
                : SizedBox(
                    height: 240,
                    child: Center(
                      child: Text(
                        "Wow, such empty.",
                        style: defaultLabelText(context,
                            fontColor: Theme.of(context).colorScheme.primary),
                      ),
                    ));
          }
          if (state is ExpandedError) {
            return Center(
                child: Text(
              "Error occurred",
              style: defaultLabelText(context),
            ));
          }
          if (state is LoadingExpanded) {
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
          }
          return Container();
        },
      ),
    );
  }
}
