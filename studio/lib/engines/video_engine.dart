// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:code_arrow_creator_studio/defaults/constants.dart';
import 'package:code_arrow_creator_studio/engines/models/video_repo.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:dio/dio.dart';

class VideoEngine {
  final Dio dio = Dio();
  final String url = URL;

  Future<VideoPost> saveInitialDraft(Map<String, dynamic> data) async {
    var apiEndpoint = 'video_engine/save_video_draft';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);

      VideoPost video = VideoPost.fromJson(result);
      return video;
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoPost> getVideoInfo(String video_id) async {
    var apiEndpoint = 'video_engine/get_video_info';
    try {
      final response = await dio.post(url + apiEndpoint, data: {'video_id': video_id});
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
      final response = await dio.post(url + apiEndpoint, data: {'video_id': video_id});
      final result = json.decode(response.data)['message'];
      return result;
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

  Future<String> saveDraft_II() async {
    return "";
  }

  Future<String> saveDraft_III() async {
    return "";
  }

  Future<void> loadVideoDraftInfo() async {}

  Future<VideoRepo> loadDrafts(String endPoint, VideoRepo repo) async {
    var apiEndpoint = 'video_engine/$endPoint';
    if (repo.currentPage <= repo.lastPage) {
      var data = {'token': sessionData!['token'], 'page_number': repo.currentPage};
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
