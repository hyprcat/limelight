import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/user_profile/subscribed_to/subscribed_to_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class AllSubscriptions extends StatefulWidget {
  const AllSubscriptions({super.key});

  @override
  State<AllSubscriptions> createState() => _AllSubscriptionsState();
}

class _AllSubscriptionsState extends State<AllSubscriptions> {
  SubscribedToBloc subscribedToBloc = SubscribedToBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    subscribedToBloc.add(LoadSubscribedTo());
    paginationScrollController.init(loadAction: () async {
      int lastPage = subscribedToBloc.repo.lastPage + 1;
      int currentPage = subscribedToBloc.repo.currentPage;
      if (lastPage > currentPage) {
        subscribedToBloc.add(LoadSubscribedTo());
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
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
          "Your subscriptions",
          style: defaultNormalText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<SubscribedToBloc, SubscribedToState>(
        bloc: subscribedToBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoadingSuccess) {
            return ListView(
              controller: paginationScrollController.scrollController,
              addAutomaticKeepAlives: false,
              physics: const BouncingScrollPhysics(),
              children: [
                state.repo.renderProfiles(
                  context,
                )
              ],
            );
          }
          if (state is FetchingError) {
            return Center(
                child: Text(
              "Error occurred",
              style: defaultLabelText(context),
            ));
          }
          return Container();
        },
      ),
    );
  }
}
