import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/repos/threads/video_comment_thread.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/small_card.dart';
import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';

class VideoCommentThreadWidget extends StatefulWidget {
  final VideoCommentThread repo;
  final bool disablePadding;
  const VideoCommentThreadWidget(
      {super.key, required this.repo, this.disablePadding = false});

  @override
  State<VideoCommentThreadWidget> createState() =>
      _VideoCommentThreadWidgetState();
}

class _VideoCommentThreadWidgetState extends State<VideoCommentThreadWidget> {
  @override
  Widget build(BuildContext context) {
    widget.repo.posts!
        .sort((a, b) => a.commentDepth!.compareTo(b.commentDepth!));
    return Column(
      children: [
        Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SmallCard(
                    video: widget.repo.linkedVideo!,
                    canBuildVideo: checkCanBuildVideo,
                    inLine: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Positioned(
                left: 28,
                top: 70,
                child: Container(
                  height: 1000,
                  width: 2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                  ),
                ))
          ],
        ),
        ListView.builder(
            padding: widget.disablePadding ? EdgeInsets.zero : null,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            addAutomaticKeepAlives: true,
            itemCount: widget.repo.posts!.length,
            itemBuilder: (context, index) {
              return VideoCommentWidget(
                videoPost: widget.repo.linkedVideo!,
                comment: widget.repo.posts![index],
                showReplyButton: true,
                showCommentedByText: (widget.repo.posts!.length - 1) == index,
                blocDeleteCallback: () {},
                baseComments: widget.repo.posts!.sublist(0, index),
              );
            }),
      ],
    );
  }
}
