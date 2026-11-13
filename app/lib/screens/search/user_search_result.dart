import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/search/search_screen.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:loading_indicator/loading_indicator.dart';

class UserSearchResult extends StatefulWidget {
  const UserSearchResult({super.key});

  @override
  State<UserSearchResult> createState() => _UserSearchResultState();
}

class _UserSearchResultState extends State<UserSearchResult> {
  Widget buildState(context, state) {
    if (state is LoadingSearchResults) {
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
    if (state is UserSearchState) {
      return AnimatedCoolRefresh(
          onRefresh: () async {},
          child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: state.repo.renderProfiles(context)),
            ],
          ));
    }
    if (state is SearchError) {
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
    return ValueListenableBuilder<String>(
        valueListenable: query,
        builder: (context, String value, _) {
          searchBloc.add(SearchUsers(value));
          return BlocConsumer<SearchBloc, SearchState>(
            bloc: searchBloc,
            listener: (context, state) {},
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: buildState(context, state),
              );
            },
          );
        });
  }
}
