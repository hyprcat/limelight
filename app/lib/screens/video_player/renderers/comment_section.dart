import 'package:flutter/material.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/screens/video_player/renderers/comment_renderer.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';

class CommentSection extends StatefulWidget {
  final VideoPost video;
  final Function activeIndexCallback;

  const CommentSection(
      {super.key, required this.video, required this.activeIndexCallback});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late CommentsRenderer commentsRenderer;
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  ScrollController controller = ScrollController();
  void refreshCallback() {
    setState(() {});
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    commentsRenderer = CommentsRenderer(
      videoPost: widget.video,
      callback: refreshCallback,
      controller: controller,
    );

    paginationScrollController.init(loadAction: () async {
      int lastPage = videoCommentsBloc!.commentsRepo.lastPage + 1;
      int currentPage = videoCommentsBloc!.commentsRepo.currentPage;
      if (lastPage > currentPage) {
        videoCommentsBloc!.add(LoadComments(true));
      } else if (lastPage == currentPage) {
        return true;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCoolRefresh(
      onRefresh: () async {
        videoCommentsBloc!.commentsRepo = VideoCommentRepo(widget.video);
        videoCommentsBloc!.add(LoadComments(true));
      },
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        controller: paginationScrollController.scrollController,
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 12, right: 10, bottom: 15, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text("Threads talking about this video",
                        style: defaultHeadingText(context,
                            fontsize: 20, fontWeight: FontWeight.bold))),
                InkWell(
                  onTap: () {
                    widget.activeIndexCallback(0);
                  },
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              child: commentsRenderer),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
