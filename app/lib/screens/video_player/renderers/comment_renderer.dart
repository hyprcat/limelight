// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';

import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class CommentsRenderer extends StatefulWidget {
  final VideoPost videoPost;
  VideoComment? rootComment;
  VideoComment? parentComment;
  final Function? callback;
  final ScrollController? controller;
  CommentsRenderer(
      {super.key,
      required this.videoPost,
      this.rootComment,
      this.parentComment,
      this.callback,
      this.controller});

  @override
  State<CommentsRenderer> createState() => _CommentsRendererState();
}

class _CommentsRendererState extends State<CommentsRenderer> {
  @override
  void initState() {
    commentsRepo = VideoCommentRepo(widget.videoPost);
    commentsRepo!.rootComment = widget.rootComment ?? VideoComment();

    videoCommentsBloc = VideoCommentsBloc(commentsRepo!);
    videoCommentsBloc!.add(LoadComments(true));
    super.initState();
  }

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCommentsBloc, VideoCommentsState>(
      bloc: videoCommentsBloc,
      listener: (context, state) {
        if (state is CommentAddedSuccessfully) {
          throwHappySnackBar(context, 'Comment added.');
          widget.callback!();
          videoCommentsBloc!.add(LoadComments(true));
        }
        if (state is CommentRemovedSuccessfully) {
          throwHappySnackBar(context, 'Comment removed.');
          widget.callback!();
          videoCommentsBloc!.add(LoadComments(true));
        }
      },
      builder: (context, state) {
        if (state is CommentLoadError || state is CommentActionError) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Text(
                "Error occured.",
                style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state is LoadingComments) {
          return SizedBox(
              height: MediaQuery.of(context).size.height / 2,
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
                      pathBackgroundColor: Theme.of(context).canvasColor),
                ),
              ));
        }

        if (state is SuccessfulCommentFetch) {
          if (state.repo.comments.isEmpty) {
            return SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(child: noVideosFound(context)));
          }
          return DynMouseScroll(
              durationMS: 200,
              scrollSpeed: 4.4,
              animationCurve: Curves.easeInOut,
              builder: (context, controller, physics) {
                return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.repo.comments.length,
                    controller: widget.controller,
                    itemBuilder: (context, index) {
                      return VideoCommentWidget(
                        comment: state.repo.comments[index],
                        videoPost: state.repo.rootVideo,
                        showReplyButton: true,
                        baseComments: [state.repo.comments[index]],
                        blocDeleteCallback: () {
                          var data = {
                            'comment_id': state.repo.comments[index].id,
                          };
                          videoCommentsBloc!.add(RemoveComment(data));
                        },
                      );
                    });
              });
        }
        return Container();
      },
    );
  }
}
