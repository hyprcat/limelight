import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post_renderer.dart';
import 'package:lime_time_app/v1_200/renderers/post_renderer.dart';

import 'package:lime_time_app/logics/models/lounge/post.dart';

class PostRepo {
  int currentPage = 1;
  int totalPage = 1;
  Post currentPost = Post();
  List<Post> posts = [];

  late Map<String, Map<dynamic, dynamic>> commentsTree = {};
  late Map<String, dynamic> commentsMap = {};
  late Map<String, dynamic> commentUsers = {};

  void dump() {
    posts.clear();
  }

  void removeDuplicates() {
    final seen = <String>{}; // Set to store seen videoIds
    posts.retainWhere((video) => seen.add(video.id!));
  }

  Post getCommentObj(String commentId) {
    return commentsMap[commentId];
  }

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

  void merge(PostRepo otherRepo) {
    commentsTree.addAll(otherRepo.commentsTree);
    commentsMap.addAll(otherRepo.commentsMap);
    commentUsers.addAll(otherRepo.commentUsers);
    sortRootComments();
  }

  Widget noPostFound(BuildContext context) {
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

  Widget buildPosts(BuildContext context, Function deleteCallback,
      {enablePadding = true, renderAsGrid = false, forLoungeHome = false}) {
    if (posts.isEmpty) {
      return noPostFound(context);
    }
    removeDuplicates();
    return PostRenderer(
      data: posts,
      deleteCallback: deleteCallback,
      enablePadding: enablePadding,
      renderAsGrid: renderAsGrid,
      forLoungeHome: forLoungeHome,
    );
  }

  Widget buildPostsExperimental(BuildContext context, Function deleteCallback,
      {enablePadding = true, renderAsGrid = false, forLoungeHome = false}) {
    if (posts.isEmpty) {
      return noPostFound(context);
    }
    removeDuplicates();
    return PostRendererExperimental(
      data: posts,
      deleteCallback: deleteCallback,
      enablePadding: enablePadding,
      renderAsGrid: renderAsGrid,
      forLoungeHome: forLoungeHome,
    );
  }
}
