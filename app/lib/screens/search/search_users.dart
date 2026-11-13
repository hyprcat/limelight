import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/screens/settings/main/settings.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class SearchUsersScreen extends StatefulWidget {
  final bool withScaffold;
  const SearchUsersScreen({super.key, required this.withScaffold});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  SearchBloc searchBloc = SearchBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    super.initState();
    paginationScrollController.init(loadAction: () async {
      int lastPage = searchBloc.userRepo.lastPage + 1;
      int currentPage = searchBloc.userRepo.currentPage;
      if (lastPage > currentPage) {
        if (context.mounted) {
          searchBloc.add(SearchUsers(searchQuery.value));
        }
      } else if (lastPage == currentPage) {
        return true;
      }
    });
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  Widget searchUserField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: true,
          maxLength: 100,
          style: defaultSmallXLabelCustom(context, fontWeight: FontWeight.w600),
          onChanged: (text) {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            searchQuery.value = text;
          },
          maxLines: 1,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: "What are you looking for?",
            hintStyle: defaultSmallXLabelCustom(context,
                fontWeight: FontWeight.w500, fontColor: Colors.grey.shade700),
            suffixIcon: InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
              },
              child: Icon(
                Iconsax.search_normal_1_outline,
                color: Theme.of(context).colorScheme.inverseSurface,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = ValueListenableBuilder<String>(
        valueListenable: searchQuery,
        builder: (context, String value, _) {
          searchBloc.userRepo = UserRepo();
          searchBloc.add(SearchUsers(value));
          return BlocConsumer<SearchBloc, SearchState>(
            bloc: searchBloc,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is VideoSearchState) {
                return AnimatedCoolRefresh(
                    onRefresh: () async {
                      paginationScrollController.reset();
                    },
                    child: Stack(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: state.repo
                                .buildSmallCard(context, checkCanBuildVideo)),
                      ],
                    ));
              }
              if (state is UserSearchState) {
                return AnimatedCoolRefresh(
                    onRefresh: () async {
                      paginationScrollController.reset();
                    },
                    child: Stack(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: state.repo.renderProfiles(context)),
                      ],
                    ));
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
              if (state is CommentSearchState) {
                return AnimatedCoolRefresh(
                    onRefresh: () async {
                      paginationScrollController.reset();
                    },
                    child: Stack(
                      children: [
                        (state.repo.comments.isNotEmpty)
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.repo.comments.length,
                                itemBuilder: (context, index) {
                                  return VideoCommentWidget(
                                    comment: state.repo.comments[index],
                                    videoPost: state.repo.rootVideo,
                                    showReplyButton: true,
                                    baseComments: [state.repo.comments[index]],
                                    blocDeleteCallback: () {},
                                  );
                                })
                            : Center(
                                child: Text(
                                  "Wow, such empty.",
                                  style: defaultSmallLabel(context,
                                      fontColor:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
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
              return ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      itemCount: 2,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return const FakePost();
                      }),
                ],
              );
            },
          );
        });
    if (!widget.withScaffold) {
      return body;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: Hero(
          tag: 'appbar-k',
          child: AppBar(
            elevation: 0,
            titleSpacing: 10,
            backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
            surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
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
            leading: InkWell(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: UserProfilePicture(
                    radius: 16,
                    userObj: authHandler.loggedInUser!,
                    doNothing: true,
                    callback: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const SettingsMain(),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                )),
          ),
        ),
      ),
      body: body,
    );
  }
}
