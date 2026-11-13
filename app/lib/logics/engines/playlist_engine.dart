import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lime_time_app/logics/models/videos/playlist_item.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/playlist_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';

import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/models/videos/playlist.dart';

class PlaylistHelper {
  final Dio dio = Dio(
    BaseOptions(
      headers: {"authorization": sessionData?['token'] ?? ""},
      followRedirects: false,
    ),
  );
  final String url = URL;

  Future<String> createPlaylist(
      String playlistName, String playlistDescription) async {
    var apiEndpoint = 'video_engine/create_playlist_view';
    try {
      var data = {};
      data['playlist_name'] = playlistName;
      data['playlist_description'] = playlistDescription;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> modifyPlaylist(String playlistName, String playlistDescription,
      String playlistId) async {
    var apiEndpoint = 'video_engine/modify_playlist_view';
    try {
      var data = {};
      data['playlist_id'] = playlistId;
      data['playlist_name'] = playlistName;
      data['playlist_description'] = playlistDescription;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removePlaylist(String playlistId) async {
    var apiEndpoint = 'video_engine/delete_playlist';
    try {
      var data = {};
      data['playlist_id'] = playlistId;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addVideoToPlaylist(String playlistId, String videoId) async {
    var apiEndpoint = 'video_engine/add_video_to_playlist';
    try {
      var data = {};
      data['playlist_id'] = playlistId;
      data['video_id'] = videoId;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> removeVideoToPlaylist(
      String playlistId, String videoId) async {
    var apiEndpoint = 'video_engine/remove_video_from_playlist';
    try {
      var data = {};
      data['playlist_id'] = playlistId;
      data['video_id'] = videoId;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAllPlaylistItems(String playlistId, int pageNumber) async {
    var apiEndpoint = 'video_engine/get_all_playlist_items';
    try {
      var data = {};
      data['playlist_id'] = playlistId;
      data['page_number'] = pageNumber;
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<PlayListRepo> getAllPlaylist(String userId, PlayListRepo repo) async {
    var apiEndpoint = 'video_engine/get_all_playlists';

    try {
      var data = {};
      data['user_id'] = userId;
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      var tmp = await dio.post(url + apiEndpoint, data: data);
      final response = jsonDecode(tmp.data);
      if (repo.currentPage <= response['total_pages']) {
        List<PlayList> tmpPlaylists = [];

        if (response['data'] != null) {
          for (var i in response['data']) {
            PlayList playlist = PlayList.fromJson(i);
            tmpPlaylists.add(playlist);
          }

          if (tmpPlaylists.isEmpty) {
            return repo;
          }

          int x = response['page_number'];
          int y = response['total_pages'];

          repo.currentPage = x + 1;
          repo.lastPage = y;

          repo.playlists.addAll(tmpPlaylists);
        }
      }
    } catch (e) {}

    return repo;
  }

  Future<PlayListRepo> quickFetchPlaylists(
      String videoId, PlayListRepo repo) async {
    var apiEndpoint = 'video_engine/quick_fetch_playlists_view';

    try {
      var data = {};
      data['video_id'] = videoId;
      data['token'] = sessionData!['token'];
      var tmp = await dio.post(url + apiEndpoint, data: data);
      final response = jsonDecode(tmp.data);
      List<PlayList> tmpPlaylists = [];
      if (repo.currentPage <= response['total_pages']) {
        if (response['data'] != null) {
          for (var i in response['data']) {
            PlayList playlist = PlayList.fromJson(i);
            tmpPlaylists.add(playlist);
          }

          if (tmpPlaylists.isEmpty) {
            return repo;
          }

          int x = response['page_number'];
          int y = response['total_pages'];

          repo.currentPage = x + 1;
          repo.lastPage = y;

          repo.playlists.addAll(tmpPlaylists);
        }
      }
    } catch (e) {}
    return repo;
  }

  Future<VideoRepo> loadPlaylistVideos(
      String playlistId, VideoRepo repo) async {
    var apiEndpoint = 'video_engine/get_all_playlist_items';

    try {
      var data = {'page_number': repo.currentPage, 'playlist_id': playlistId};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      if (repo.currentPage <= repo.lastPage) {
        List<VideoPost> tmpVideos = [];
        for (var i in result['data']) {
          PlayListItem item = PlayListItem.fromJson(i);
          repo.videos.add(item.video!);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
        repo.videos.addAll(tmpVideos);
      }
    } catch (e) {}
    return repo;
  }
}
