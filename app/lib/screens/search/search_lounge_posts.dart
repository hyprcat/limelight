import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class SearchLoungePostsScreen extends StatefulWidget {
  const SearchLoungePostsScreen({super.key});

  @override
  State<SearchLoungePostsScreen> createState() =>
      _SearchLoungePostsScreenState();
}

class _SearchLoungePostsScreenState extends State<SearchLoungePostsScreen> {
  SearchBloc searchBloc = SearchBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    super.initState();
    paginationScrollController.init(loadAction: () async {
      int lastPage = searchBloc.postRepo.totalPage + 1;
      int currentPage = searchBloc.postRepo.currentPage;
      if (lastPage > currentPage) {
        if (context.mounted) {
          searchBloc.add(SearchLoungePosts(searchQuery.value));
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: searchQuery,
        builder: (context, String value, _) {
          searchBloc.postRepo = PostRepo();
          if (context.mounted) {
            searchBloc.add(SearchLoungePosts(value));
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
                  if (state.repo.posts.isEmpty) {
                    return SizedBox(
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "😭",
                            style: defaultHeadingXText(context, fontsize: 40),
                          ),
                          Text(
                            "Wow, such empty.",
                            style: defaultLabelTextForPost(context,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }
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
                                      baseComments: [
                                        state.repo.comments[index]
                                      ],
                                      blocDeleteCallback: () {},
                                    );
                                  })
                              : Center(
                                  child: Text(
                                    "Wow, such empty.",
                                    style: defaultSmallLabel(context,
                                        fontColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
          }
          return Container();
        });
  }
}
