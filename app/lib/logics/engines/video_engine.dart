// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/logics/repos/home/home.dart';
import 'package:lime_time_app/logics/repos/threads/video_comment_thread_repo.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
// ignore: unused_import
import 'package:lime_time_app/main.dart';

class VideoEngine {
  final Dio dio = Dio(
    BaseOptions(
      headers: {"authorization": sessionData?['token'] ?? ""},
      followRedirects: false,
    ),
  );
  final String url = URL;

  Future<VideoPost> saveInitialDraft(Map<String, dynamic> data) async {
    var apiEndpoint = 'video_engine/save_video_draft';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      VideoPost video = VideoPost.fromJson(result);
      return video;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoPost> getVideoInfo(String video_id) async {
    var apiEndpoint = 'video_engine/get_video_info';
    try {
      final response =
          await dio.post(url + apiEndpoint, data: {'video_id': video_id});
      final result = response.data;
      VideoPost video = VideoPost.fromJson(result);
      return video;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteVideo(String video_id) async {
    var apiEndpoint = 'video_engine/delete_video';
    try {
      final response =
          await dio.post(url + apiEndpoint, data: {'video_id': video_id});
      final result = response.data['message'];
      return result;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoCommentThreadRepo> renderUserThreads(
      String userId, VideoCommentThreadRepo repo) async {
    var data = {};
    var apiEndpoint = 'video_engine/render_threads_creator';

    if (repo.pageNumber <= repo.totalPages) {
      data['page_number'] = repo.pageNumber;
      data['token'] = sessionData!['token'];
      data['user_id'] = userId;
      final response = await dio.post(url + apiEndpoint, data: data);
      VideoCommentThreadRepo tmp =
          VideoCommentThreadRepo.fromJson(jsonDecode(response.data));
      repo.pageNumber = tmp.pageNumber;
      repo.totalPages = tmp.totalPages;
      repo.data.addAll(tmp.data);
      return repo;
    }
    return repo;
  }

  Future<ExperimentalHomeRepo> renderHomeV2Experiment() async {
    var apiEndpoint = 'video_engine/render_home_v2_api';
    try {
      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});

      ExperimentalHomeRepo repo =
          ExperimentalHomeRepo.fromJson(jsonDecode(response.data));
      return repo;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExperimentalHomeRepo> renderHomeV2Threads() async {
    var apiEndpoint = 'video_engine/render_threads_home';
    try {
      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});
      ExperimentalHomeRepo repo =
          ExperimentalHomeRepo.fromJson(jsonDecode(response.data));
      return repo;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExperimentalHomeRepo> renderHomeV2Videos() async {
    var apiEndpoint = 'video_engine/render_video_home';
    try {
      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});
      ExperimentalHomeRepo repo =
          ExperimentalHomeRepo.fromJson(jsonDecode(response.data));
      return repo;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateVideoStatus(dynamic data) async {
    var apiEndpoint = 'video_engine/update_video_status';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> saveDraft_I(dynamic data) async {
    var apiEndpoint = 'video_engine/save_video_draft_I';
    try {
      data['token'] = sessionData!['token'];
      final formData = FormData.fromMap(data);
      final response = await dio.post(url + apiEndpoint, data: formData);
      final result = json.decode(response.data)['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchVideoReactionStatus(VideoPost videoPost) async {
    var apiEndpoint = 'video_engine/fetch_video_reaction_status';
    try {
      var data = {};
      data['token'] = sessionData!['token'];
      data['video_id'] = videoPost.id;
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchCommentReactionStatus(VideoComment comment) async {
    var apiEndpoint = 'video_engine/fetch_comment_reaction_status';
    try {
      var data = {};
      data['token'] = sessionData!['token'];
      data['comment_id'] = comment.id;
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> likeVideo(VideoPost videoPost) async {
    var apiEndpoint = 'video_engine/like_video_view';
    try {
      var data = {};
      data['video_id'] = videoPost.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> dislikeVideo(VideoPost videoPost) async {
    var apiEndpoint = 'video_engine/dislike_video_view';
    try {
      var data = {};
      data['video_id'] = videoPost.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeLike(VideoPost videoPost) async {
    var apiEndpoint = 'video_engine/remove_like_video_view';
    try {
      var data = {};
      data['video_id'] = videoPost.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeDislike(VideoPost videoPost) async {
    var apiEndpoint = 'video_engine/remove_dislike_video_view';
    try {
      var data = {};
      data['video_id'] = videoPost.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> likeComment(VideoComment comment) async {
    var apiEndpoint = 'video_engine/like_comment_view';
    try {
      var data = {};
      data['comment_id'] = comment.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createCustomFeed(dynamic data) async {
    try {
      var apiEndpoint = 'video_engine/create_custom_feed_view';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return json.decode(response.data)['message'] == "success";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> reportVideo(dynamic data) async {
    try {
      var apiEndpoint = 'video_engine/report_video';

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

  Future<bool> reportComment(dynamic data) async {
    try {
      var apiEndpoint = 'video_engine/report_comment';

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

  Future<String> dislikeComment(VideoComment comment) async {
    var apiEndpoint = 'video_engine/dislike_comment_view';
    try {
      var data = {};
      data['comment_id'] = comment.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeLikeComment(VideoComment comment) async {
    var apiEndpoint = 'video_engine/remove_like_comment_view';
    try {
      var data = {};
      data['comment_id'] = comment.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeDislikeComment(VideoComment comment) async {
    var apiEndpoint = 'video_engine/remove_dislike_comment_view';
    try {
      var data = {};
      data['comment_id'] = comment.id;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoRepo> loadCreatorVideos(String user_id, VideoRepo repo) async {
    var apiEndpoint = 'video_engine/fetch_creator_videos';
    if (repo.currentPage <= repo.lastPage) {
      var data = {
        'page_number': repo.currentPage,
        'user_id': user_id,
        'token': sessionData!['token']
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);

      List<VideoPost> tmpVideos = [];

      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }

      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoCommentRepo> fetchSearchComments(
      VideoCommentRepo repo, String searchQuery) async {
    var apiEndpoint = 'video_engine/get_search_comments';
    try {
      var data = {
        'page_number': repo.currentPage,
        'query': searchQuery,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      if (repo.currentPage <= result['total_pages']) {
        List<VideoComment> tmpVideos = [];
        for (var i in result['data']) {
          VideoComment comment = VideoComment.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
        repo.comments.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<UserRepo> fetchSearchUsers(UserRepo repo, String searchQuery) async {
    var apiEndpoint = 'lounge_engine/search_users';
    if (repo.currentPage <= repo.lastPage) {
      var data = {
        'page_number': repo.currentPage,
        'query': searchQuery,
        'token': sessionData!['token']
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
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

  Future<VideoRepo> fetchSearchVideos(
      VideoRepo repo, String searchQuery) async {
    var apiEndpoint = 'video_engine/get_search_videos';
    if (repo.currentPage <= repo.lastPage) {
      var data = {'page_number': repo.currentPage, 'query': searchQuery};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> loadRecommendations(VideoRepo repo,
      {bool onlyShortVideos = false}) async {
    var apiEndpoint = 'video_engine/fetch_videos';
    if (repo.currentPage <= repo.lastPage) {
      var data = {
        'page_number': repo.currentPage,
        'exclude_short_videos': !onlyShortVideos,
        'only_short_videos': onlyShortVideos
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> fetchTopDailyVideos(Map data, VideoRepo repo,
      {bool onlyShortVideos = false}) async {
    var apiEndpoint = 'video_engine/get_top_videos_day_view';
    if (repo.currentPage <= repo.lastPage) {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      data['only_short_videos'] = onlyShortVideos;
      data['exclude_short_videos'] = !onlyShortVideos;
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> fetchTopWeekVideos(Map data, VideoRepo repo,
      {bool onlyShortVideos = false}) async {
    var apiEndpoint = 'video_engine/get_top_videos_week_view';
    if (repo.currentPage <= repo.lastPage) {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      data['only_short_videos'] = onlyShortVideos;
      data['exclude_short_videos'] = !onlyShortVideos;
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> fetchTopMonthVideos(Map data, VideoRepo repo,
      {bool refresh = false, bool onlyShortVideos = false}) async {
    var apiEndpoint = 'video_engine/get_top_videos_month_view';
    if (repo.currentPage <= repo.lastPage) {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      data['only_short_videos'] = onlyShortVideos;
      data['exclude_short_videos'] = !onlyShortVideos;
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> fetchTopYearVideos(Map data, VideoRepo repo,
      {bool refresh = false, bool onlyShortVideos = false}) async {
    var apiEndpoint = 'video_engine/get_top_videos_year_view';
    if (repo.currentPage <= repo.lastPage) {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      data['only_short_videos'] = onlyShortVideos;
      data['exclude_short_videos'] = !onlyShortVideos;
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoRepo> fetchWatchedVideos(VideoRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'video_engine/get_watched_videos_api';
    if (refresh || repo.currentPage <= repo.lastPage) {
      Map data = {};
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];
      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }

  Future<VideoCommentRepo> loadComments(VideoCommentRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'video_engine/fetch_video_comments';
    try {
      if (refresh) {
        repo.dump();
      }

      var data = {
        'page_number': repo.currentPage,
        'video_id': repo.rootVideo.id,
        'root_comment_id': null,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);

      if (repo.currentPage <= result['total_pages']) {
        List<VideoComment> tmpVideos = [];
        for (var i in result['data']) {
          VideoComment comment = VideoComment.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
        repo.comments.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<VideoCommentRepo> loadThreadedComments(VideoCommentRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'video_engine/fetch_threaded_comments';
    try {
      if (refresh) {
        repo.dump();
      }

      var data = {
        'page_number': repo.currentPage,
        'post_id': repo.currentComment.id,
        'is_root_comment':
            repo.currentComment.rootCommentId == repo.currentComment.id,
        'token': sessionData!['token']
      };

      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);

      if (repo.currentPage <= result['total_pages']) {
        List<VideoComment> tmpVideos = [];
        for (var i in result['data']) {
          VideoComment comment = VideoComment.fromJson(i);
          tmpVideos.add(comment);
        }

        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
        repo.comments.addAll(tmpVideos);

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<VideoCommentRepoV2> loadCommentsV2(String sectionId,
      VideoCommentRepoV2 repo, String endPoint, VideoComment parentPost) async {
    var apiEndpoint = 'video_engine/$endPoint';
    if (repo.currentPage <= repo.totalPage) {
      Map<String, Object> data;
      String parentId;
      if (parentPost.id == null) {
        parentId = "";
      } else {
        parentId = parentPost.id!;
      }

      if (parentId != "") {
        data = {'page_number': repo.currentPage, 'post_id': parentId};
      } else {
        data = {'page_number': repo.currentPage, 'section_id': sectionId};
      }

      if (endPoint == "fetch_total_posts") {
        data = {'page_number': repo.currentPage, 'post_id': parentPost.id!};
      }

      data['token'] = sessionData!['token']!;
      final response = await dio.post(url + apiEndpoint, data: data);

      List<VideoComment> tmpVideos = [];
      final commentSet = <String, dynamic>{};
      final commentUsers = <String, dynamic>{};
      final comments = <Map<String, dynamic>>[];

      if (response.data['data'] != null) {
        for (var i in response.data['data']) {
          VideoComment post = VideoComment.fromJson(i);

          commentSet[post.id!] = post;
          commentUsers[post.id!] = post.commentedBy;
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

  Future<String> addComment(data) async {
    var apiEndpoint = 'video_engine/add_comment_view';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addCommentV2(data) async {
    var apiEndpoint = 'video_engine/add_comment_view_v2';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeComment(data) async {
    var apiEndpoint = 'video_engine/remove_comment_view';
    try {
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> setImpression(data) async {
    var apiEndpoint = 'video_engine/set_impression';
    try {
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data)['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> setView(data) async {
    var apiEndpoint = 'video_engine/set_view';
    try {
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data)['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoRepo> loadDrafts(String endPoint, VideoRepo repo) async {
    var apiEndpoint = 'video_engine/$endPoint';
    if (repo.currentPage <= repo.lastPage) {
      var data = {
        'token': sessionData!['token'],
        'page_number': repo.currentPage
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      List<VideoPost> tmpVideos = [];

      for (var i in result['data']) {
        VideoPost video = VideoPost.fromJson(i);
        repo.videos.add(video);
      }
      int x = result['page_number'];
      int y = result['total_pages'];

      repo.currentPage = x + 1;
      repo.lastPage = y;
      repo.videos.addAll(tmpVideos);

      return repo;
    }
    return repo;
  }
}

class VideoCommentNode {
  final Map<String, dynamic> comment;
  final List<VideoCommentNode> children;

  VideoCommentNode({required this.comment, this.children = const []});
}

List<VideoCommentNode> constructCommentTree(
    List<Map<String, dynamic>> sortedComments,
    {int baseDepth = 1,
    bool useModifiedDepth = false}) {
  Map<String, VideoCommentNode> commentTree = {};

  for (var commentData in sortedComments) {
    final commentId = commentData['id'];
    final parentCommentId =
        commentData['parent_post'] == null ? "" : commentData['parent_post'].id;
    final commentNode = VideoCommentNode(comment: commentData, children: []);

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

Map<String, Map> convertTreeToMap(List<VideoCommentNode> nodes,
    {int depth = 0}) {
  Map<String, Map> result = {};

  for (var node in nodes) {
    final comment = node.comment['id'];
    result[comment] = convertTreeToMap(node.children, depth: depth + 1);
  }

  return result;
}
