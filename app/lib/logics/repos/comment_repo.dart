import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

class VideoCommentRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<VideoComment> comments = [];
  VideoComment rootComment = VideoComment();
  VideoComment currentComment = VideoComment();
  VideoPost rootVideo;

  VideoCommentRepo(this.rootVideo);

  Widget noVideosFound(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          "Wow, such empty.",
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void dump() {
    comments = [];
    currentPage = 1;
    lastPage = 1;
  }
}

class VideoCommentRepoV2 {
  int currentPage = 1;
  int totalPage = 1;
  List<VideoComment> posts = [];

  late Map<String, Map<dynamic, dynamic>> commentsTree = {};
  late Map<String, dynamic> commentsMap = {};
  late Map<String, dynamic> commentUsers = {};

  VideoCommentRepoV2();

  sortRootComments() {
    List<String> rootCommentsList = commentsTree.keys.toList();
    rootCommentsList.sort((a, b) => DateTime.parse(commentsMap[a]!.creationDate)
        .compareTo(DateTime.parse(commentsMap[b]!.creationDate)));
    var reversedList = List.from(rootCommentsList);
    Map<String, Map<dynamic, dynamic>> newMap = {};
    for (var i in reversedList) {
      newMap[i] = commentsTree[i]!;
    }
    commentsTree = newMap;
  }

  void merge(VideoCommentRepoV2 otherRepo) {
    commentsTree.addAll(otherRepo.commentsTree);
    commentsMap.addAll(otherRepo.commentsMap);
    commentUsers.addAll(otherRepo.commentUsers);
    sortRootComments();
  }

  Widget noCommentsFound(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          "Wow, such empty.",
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
