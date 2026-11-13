import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';

class FollowUpComments extends StatefulWidget {
  final VideoPost video;
  final List<VideoComment> baseComments;
  final bool hasRootComment;
  const FollowUpComments(
      {required this.video,
      required this.baseComments,
      required this.hasRootComment,
      super.key});

  @override
  State<FollowUpComments> createState() => _FollowUpCommentsState();
}

class _FollowUpCommentsState extends State<FollowUpComments> {
  late VideoCommentRepo repo;
  late VideoCommentsBloc commentBloc;

  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    repo = VideoCommentRepo(widget.video);
    repo.currentComment = widget.baseComments.last;

    commentBloc = VideoCommentsBloc(repo);
    commentBloc.add(LoadThreadedComments(true));

    paginationScrollController.init(loadAction: () async {
      int lastPage = commentBloc.commentsRepo.lastPage + 1;
      int currentPage = commentBloc.commentsRepo.currentPage;
      if (lastPage > currentPage) {
        commentBloc.add(LoadThreadedComments(true));
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

  ScrollController controller = ScrollController();

  Widget noVideosFound(BuildContext context) {
    return Center(
      child: Text(
        "Wow, such empty.",
        style: defaultSmallLabel(context,
            fontColor: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
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
          "Follow Up",
          style: defaultHeadingXText(context),
        ),
      ),
      body: AnimatedCoolRefresh(
        onRefresh: () async {
          paginationScrollController.reset();
          commentBloc = VideoCommentsBloc(repo);
          commentBloc.add(LoadThreadedComments(true));
        },
        child: ListView(
          physics: const BouncingScrollPhysics(),
          controller: paginationScrollController.scrollController,
          shrinkWrap: true,
          children: [
            ListView.builder(
                shrinkWrap: true,
                controller: paginationScrollController.scrollController,
                itemCount: widget.baseComments.length,
                itemBuilder: (context, index) {
                  return VideoCommentWidget(
                    videoPost: widget.video,
                    comment: widget.baseComments[index],
                    showReplyButton: true,
                    showCommentedByText: false,
                    blocDeleteCallback: () {
                      Navigator.popUntil(context,
                          (Route<dynamic> route) => route is ExpandedVideo);
                      var data = {
                        'comment_id': widget.baseComments[index].id,
                      };
                      videoCommentsBloc!.add(RemoveComment(data));
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                  );
                }),
            Divider(
              color: Theme.of(context).dividerColor,
              thickness: 2,
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Replies",
                style: defaultHeadingText(context),
              ),
            ),
            BlocConsumer<VideoCommentsBloc, VideoCommentsState>(
              bloc: commentBloc,
              listener: (context, state) {
                if (state is CommentAddedSuccessfully) {
                  throwHappySnackBar(context, 'Comment added.');
                  commentBloc.add(LoadThreadedComments(true));
                }
                if (state is CommentRemovedSuccessfully) {
                  throwHappySnackBar(context, 'Comment removed.');
                  commentBloc.add(LoadThreadedComments(true));
                }
              },
              builder: (context, state) {
                if (state is CommentLoadError || state is CommentActionError) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(
                      child: Text(
                        "Error occured.",
                        style: defaultSmallLabel(context,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                if (state is LoadingComments) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
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
                              pathBackgroundColor:
                                  Theme.of(context).canvasColor),
                        ),
                      ));
                }

                if (state is SuccessfulCommentFetch) {
                  if (state.repo.comments.isEmpty) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: noVideosFound(context));
                  }
                  return state.repo.comments.isEmpty
                      ? noVideosFound(context)
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.repo.comments.length,
                          controller:
                              paginationScrollController.scrollController,
                          itemBuilder: (context, index) {
                            return VideoCommentWidget(
                              comment: state.repo.comments[index],
                              videoPost: state.repo.rootVideo,
                              showReplyButton: true,
                              baseComments: widget.baseComments,
                              expandedComment: false,
                              blocDeleteCallback: () {
                                var data = {
                                  'comment_id': state.repo.comments[index].id,
                                };
                                commentBloc.add(RemoveComment(data));
                              },
                            );
                          });
                }
                return noVideosFound(context);
              },
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
