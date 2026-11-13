// ignore_for_file: unused_local_variable, duplicate_ignore

import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/repos/lounge_home.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';

import 'package:lime_time_app/logics/repos/user_repo.dart';

class LoungeEngine {
  final Dio dio = Dio(
    BaseOptions(
      headers: {"authorization": sessionData?['token'] ?? ""},
      followRedirects: false,
    ),
  );
  final String url = URL;

  Future<bool> createLoungeCategory(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/create_category';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> modifyLoungeCategory(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/modify_category';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> modifyLoungeDetails(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/modify_lounge_details';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> deleteLoungeCategory(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/delete_category';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> createLoungeSection(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/create_section';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> modifyLoungeSection(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/modify_section';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> deleteLoungeSection(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/delete_section';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<List<LoungeCategory>> fetchAvailableCategories(int userId) async {
    try {
      var apiEndpoint = 'lounge_engine/fetch_available_categories';

      final response =
          await dio.post(url + apiEndpoint, data: {'user_id': userId});

      final result = response.data['message'];
      List<LoungeCategory> endList = [];
      for (var i in result) {
        LoungeCategory obj = LoungeCategory.fromJson(i);
        endList.add(obj);
      }
      return endList;
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return [];
    }
  }

  Future<UserLounge?> renderLounge(int userId) async {
    try {
      var apiEndpoint = 'lounge_engine/render_lounge';

      final response = await dio.post(url + apiEndpoint,
          data: {'user_id': userId, 'token': sessionData!['token']});
      final nonJson = response.data['message'];

      if (nonJson == "Lounge is locked.") {
        var emptyLounge = UserLounge();
        emptyLounge.isLocked = true;
        return emptyLounge;
      }

      UserLounge lounge = UserLounge.fromJson(nonJson);

      return lounge;
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return null;
    }
  }

  Future<LoungeHome?> renderLoungeHome() async {
    try {
      var apiEndpoint = 'lounge_engine/render_lounge_home';

      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});
      final nonJson = response.data;

      LoungeHome lounge;
      if (nonJson != null) {
        lounge = LoungeHome.fromJson(nonJson);
      } else {
        lounge = LoungeHome();
      }

      return lounge;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createPost(dynamic data) async {
    var apiEndpoint = 'lounge_engine/create_lounge_post';
    try {
      var formData = FormData.fromMap(data);
      final response = await dio.post(url + apiEndpoint, data: formData);

      // ignore: unused_local_variable
      final result = json.decode(response.data)['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> leaveLounge(dynamic data) async {
    var apiEndpoint = 'lounge_engine/leave_lounge';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);

      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePost(dynamic data) async {
    var apiEndpoint = 'lounge_engine/remove_post';
    try {
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      // ignore: unused_local_variable
      final result = response.data['message'];
      if (response.statusCode == 200) {
        return result == "success";
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> loadPosts(dynamic data) async {
    var apiEndpoint = 'lounge_engine/fetch_section_posts';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PostRepo> loadExtraPosts(PostRepo repo, String endpoint,
      {bool refresh = false}) async {
    var apiEndpoint = 'lounge_engine/$endpoint';
    try {
      if (refresh) {
        repo.dump();
      }

      var data = {
        'page_number': repo.currentPage,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<Post> tmpVideos = [];
        for (var i in result['data']) {
          Post comment = Post.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.totalPage = y;
        repo.posts.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<UserRepo> fetchMoreUsers(UserRepo repo, String endpoint) async {
    var apiEndpoint = 'lounge_engine/$endpoint';
    Map data = {};
    data['page_number'] = repo.currentPage;
    data['token'] = sessionData!['token'];
    final response = await dio.post(url + apiEndpoint, data: data);
    final result = response.data;

    if (repo.currentPage <= result['total_pages']) {
      List<UserProfile> tmpProfiles = [];
      for (var i in result['data']) {
        UserProfile video = UserProfile.fromJson(i);
        repo.profiles.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;

      return repo;
    }
    return repo;
  }

  Future<bool> acceptLoungeInvitation(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/accept_lounge_invite';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> denyLoungeInvitation(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/deny_lounge_invite';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> reportContent(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/report_comment_view';

      final response = await dio.post(url + apiEndpoint, data: data);
      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> setPostImpressions(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/set_post_impression';

      final response = await dio.post(url + apiEndpoint, data: data);
      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeLoungeVisibility(dynamic data) async {
    try {
      var apiEndpoint = 'lounge_engine/change_lounge_visibility';

      final response = await dio.post(url + apiEndpoint, data: data);
      if (response.statusCode == 200) {
        return response.data['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<UserRepo> fetchLoungeInvitations(UserRepo repo) async {
    var apiEndpoint = 'lounge_engine/get_user_invites';
    try {
      Map data = {};
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile video = UserProfile.fromJson(i);
          repo.profiles.add(video);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.totalItems = result['total_requests'];
        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {}
    return repo;
  }

  Future<PostRepo> loadThreadedComments(PostRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'lounge_engine/fetch_threaded_comments_view';
    try {
      if (refresh) {
        repo.dump();
      }

      var data = {
        'page_number': repo.currentPage,
        'post_id': repo.currentPost.id,
        'is_root_comment': repo.currentPost.rootPost == repo.currentPost.id,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      if (repo.currentPage <= result['total_pages']) {
        List<Post> tmpVideos = [];
        for (var i in result['data']) {
          Post comment = Post.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.totalPage = y;
        repo.posts.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<PostRepo> loadSearchResults(PostRepo repo, String searchQuery,
      {bool refresh = false}) async {
    var apiEndpoint = 'lounge_engine/fetch_search_posts';
    try {
      if (refresh) {
        repo.dump();
      }

      var data = {
        'page_number': repo.currentPage,
        'query': searchQuery,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      if (repo.currentPage <= result['total_pages']) {
        List<Post> tmpVideos = [];
        for (var i in result['data']) {
          Post comment = Post.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.totalPage = y;
        repo.posts.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<PostRepo> loadLoungePostsLEGACY(
      String sectionId, PostRepo repo, String endPoint, Post parentPost) async {
    var apiEndpoint = 'lounge_engine/fetch_section_posts';
    if (repo.currentPage <= repo.totalPage) {
      Map<String, Object> data;
      String parentId;
      if (parentPost.id == null) {
        parentId = "";
      } else {
        parentId = parentPost.id!;
      }

      data = {'page_number': repo.currentPage, 'section_id': sectionId};

      data['token'] = sessionData!['token']!;
      final response = await dio.post(url + apiEndpoint, data: data);

      List<Post> tmpVideos = [];
      final commentSet = <String, dynamic>{};
      final commentUsers = <String, dynamic>{};
      final comments = <Map<String, dynamic>>[];
      if (response.data['data'] != null) {
        for (var i in response.data['data']) {
          Post post = Post.fromJson(i);

          commentSet[post.id!] = post;
          commentUsers[post.id!] = post.createdBy;
          tmpVideos.add(post);
          comments.add(post.toJson());
        }

        if (tmpVideos.isEmpty) {
          return repo;
        }
        final mTree = constructCommentTree(comments,
            baseDepth: comments[0]['post_depth'], useModifiedDepth: true);
        final tree = convertTreeToMap(mTree);

        int x = response.data['page_number'];
        int y = response.data['total_pages'];

        repo.currentPage = x + 1;
        repo.totalPage = y;

        repo.commentsTree = tree;
        repo.commentsMap = commentSet;
        repo.commentUsers = commentUsers;

        repo.sortRootComments();
        repo.posts.addAll(tmpVideos);

        return repo;
      }
      return repo;
    }
    return repo;
  }

  Future<String> likePost(Post post) async {
    var apiEndpoint = 'lounge_engine/like_post_view';
    try {
      var data = {};
      data['post_id'] = post.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> dislikePost(Post post) async {
    var apiEndpoint = 'lounge_engine/dislike_post_view';
    try {
      var data = {};
      data['post_id'] = post.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeLikePost(Post post) async {
    var apiEndpoint = 'lounge_engine/remove_like';
    try {
      var data = {};
      data['post_id'] = post.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeDislikePost(Post post) async {
    var apiEndpoint = 'lounge_engine/remove_dislike';
    try {
      var data = {};
      data['post_id'] = post.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchPostReaction(Post post) async {
    var apiEndpoint = 'lounge_engine/fetch_post_reaction_status';
    try {
      var data = {};
      data['token'] = sessionData!['token'];
      data['post_id'] = post.id;
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

class CommentNode {
  final Map<String, dynamic> comment;
  final List<CommentNode> children;

  CommentNode({required this.comment, this.children = const []});
}

List<CommentNode> constructCommentTree(
    List<Map<String, dynamic>> sortedComments,
    {int baseDepth = 1,
    bool useModifiedDepth = false}) {
  Map<String, CommentNode> commentTree = {};

  for (var commentData in sortedComments) {
    final commentId = commentData['id'];
    final parentCommentId =
        commentData['parent_post'] == null ? "" : commentData['parent_post'].id;
    final commentNode = CommentNode(comment: commentData, children: []);

    if (!commentTree.containsKey(commentId)) {
      commentTree[commentId] = commentNode;
    }

    if (parentCommentId != null) {
      if (commentTree.containsKey(parentCommentId)) {
        commentTree[parentCommentId]!.children.add(commentNode);
      }
    }
  }
  if (!useModifiedDepth) {
    return commentTree.values
        .where((node) => node.comment['post_depth'] == baseDepth)
        .toList();
  } else {
    return commentTree.values
        .where((node) =>
            node.comment['post_depth'] == sortedComments[0]['post_depth'])
        .toList();
  }
}

Map<String, Map> makeTreeAlternate(List<Post> posts) {
  Map<String, Map> tree = {};

  // Helper function to recursively build the tree
  void buildTree(Map<String, dynamic> node, int depth) {
    // Iterate over the posts
    for (var post in posts) {
      // If the post depth matches the current depth
      if (post.postDepth == depth) {
        // Create a new node with the post ID
        Map<String, dynamic> newNode = {};
        // Add the node to the parent node
        node[post.id!] = newNode;
        // Recursively build the tree with the new node as parent and incremented depth
        buildTree(newNode, depth + 1);
      }
    }
  }

  // Find the minimum depth among the posts
  int minDepth =
      posts.map((post) => post.postDepth!).reduce((a, b) => a < b ? a : b);

  // Start building the tree with the minimum depth
  buildTree(tree, minDepth);

  return tree;
}

Map<String, Map> makeTree(List<Post> posts) {
  // Map to store posts organized by their parent post ID
  Map<String?, List<Post>> postsByParentId = {};

  // Organize posts by parent post ID
  for (var post in posts) {
    String? parentId = post.parentPost;
    if (!postsByParentId.containsKey(parentId)) {
      postsByParentId[parentId] = [];
    }
    postsByParentId[parentId]?.add(post);
  }

  // Helper function to recursively build the tree
  Map<String, Map> buildTree(String? parentId) {
    Map<String, Map> node = {};
    List<Post>? children = postsByParentId[parentId];
    if (children != null) {
      for (var child in children) {
        node[child.id!] = buildTree(child.id);
      }
    }
    return node;
  }

  // Start building the tree with the root node (null parent ID)
  return buildTree(null);
}

Map<String, Map> convertTreeToMap(List<CommentNode> nodes, {int depth = 0}) {
  Map<String, Map> result = {};

  for (var node in nodes) {
    final comment = node.comment['id'];
    result[comment] = convertTreeToMap(node.children, depth: depth + 1);
  }

  return result;
}
