// ignore_for_file: unused_local_variable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/lounge_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class LoungeSearch extends StatefulWidget {
  const LoungeSearch({super.key});

  @override
  State<LoungeSearch> createState() => _LoungeSearchState();
}

class _LoungeSearchState extends State<LoungeSearch> {
  SearchBloc searchBloc = SearchBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void initState() {
    paginationScrollController.init(loadAction: () async {
      searchBloc.add(SearchLoungePosts(controller.text));
      return true;
    });
    super.initState();
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(
        right: 10,
      ),
      decoration: BoxDecoration(
          color: theme == ThemeMode.light
              ? Theme.of(context).splashColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(150)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  TextEditingController controller = TextEditingController();
  Widget searchUserField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: false,
          maxLength: 100,
          controller: controller,
          style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
          onChanged: (text) {
            searchBloc.postRepo = PostRepo();
            searchBloc.add(SearchLoungePosts(text));
          },
          maxLines: 1,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: "Search for a post",
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
            suffixIcon: InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                searchBloc.postRepo = PostRepo();
                searchBloc.add(SearchLoungePosts(controller.text));
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: _backgroundWrapper([
                  Icon(
                    Iconsax.search_normal_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Search",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ScrollController controllerX = ScrollController();
  @override
  Widget build(BuildContext context) {
    TextEditingController control = TextEditingController();

    Widget buildState(context, state) {
      if (state is LoungeLoading) {
        return ListView.builder(
            itemCount: 2,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return const FakePost();
            });
      }
      if (state is LoungePostSearchState) {
        return ListView.builder(
            controller: paginationScrollController.scrollController,
            shrinkWrap: true,
            itemCount: state.repo.posts.length,
            itemBuilder: (context, index) {
              Post post = state.repo.posts[index];
              return PostWidget(
                post: post,
                baseComments: [post],
                deleteCallbackPost: () {},
                isThreadable: true,
                showTail: false,
                isFirst: true,
                forLoungeHome: true,
              );
            });
      }
      if (state is SearchError) {
        return Center(
            child: Text(
          "Error occurred",
          style: defaultLabelText(context),
        ));
      }
      if (state is LoadingSearchResults) {
        return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return const FakePost();
            });
      }
      return Center(
          child: Text(
        "Start typing to see the results.",
        style: defaultLabelText(context, fontWeight: FontWeight.w600),
      ));
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Hero(
          tag: 'appbar-k',
          child: AppBar(
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
            automaticallyImplyLeading: false,
            title: searchUserField(),
          ),
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        bloc: searchBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: buildState(context, state),
          );
        },
      ),
    );
  }
}
