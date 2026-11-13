import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/lounge_expanded/lounge_expanded_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoungeExpandedUsers extends StatefulWidget {
  final String sectionName;
  final bool alternateSourceData;
  const LoungeExpandedUsers(
      {super.key,
      required this.sectionName,
      required this.alternateSourceData});

  @override
  State<LoungeExpandedUsers> createState() => _LoungeExpandedUsersState();
}

class _LoungeExpandedUsersState extends State<LoungeExpandedUsers> {
  late LoungeExpandedBloc localBloc;
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    UserRepo repo = UserRepo();
    localBloc = LoungeExpandedBloc(null, repo);
    String endpoint = "";
    if (!widget.alternateSourceData) {
      endpoint = 'get_top_lounges';
    } else {
      endpoint = 'get_top_user_joined_lounges';
    }
    localBloc.add(LoadMoreUsers(endpoint));

    paginationScrollController.init(loadAction: () async {
      int lastPage = localBloc.userRepo!.lastPage + 1;
      int currentPage = localBloc.userRepo!.currentPage;
      if (lastPage > currentPage) {
        localBloc.add(LoadMoreUsers(endpoint));
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
          "Top users",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        controller: paginationScrollController.scrollController,
        children: [
          BlocConsumer<LoungeExpandedBloc, LoungeExpandedState>(
            bloc: localBloc,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is UsersFetchedSuccess) {
                return state.repo.renderProfiles(context, forLounge: true);
              }
              if (state is ExpandedError) {
                return Center(
                    child: Text(
                  "Error occurred",
                  style: defaultLabelText(context),
                ));
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
          ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
