import 'package:dio/dio.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/repos/notifications/for_you.dart';
import 'package:lime_time_app/logics/repos/notifications/lounges.dart';
import 'package:lime_time_app/logics/repos/notifications/subscriptions.dart';
import 'package:lime_time_app/logics/repos/notifications/threads.dart';

class NotifierEngine {
  final Dio dio = Dio(
    BaseOptions(
      headers: {"authorization": sessionData?['token'] ?? ""},
      followRedirects: false,
    ),
  );
  final String url = URL;

  Future<LoungeNotificationRepo> renderLoungeNotifications(
      LoungeNotificationRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'notifier_engine/render_lounge_notifications';

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
        LoungeNotificationRepo newRepo =
            LoungeNotificationRepo.fromJson(result['data']);

        repo.mergeNewRepo(newRepo);
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;

        return repo;
      }
    } catch (e) {
      rethrow;
    }
    return repo;
  }

  Future<void> renderReplies() async {
    var apiEndpoint = 'notifier_engine/render_replies';

    final response = await dio.post(url + apiEndpoint,
        data: {'token': sessionData!['token'], 'page_number': 1});
  }

  Future<SubscriptionsRepo> renderSubscriptions(SubscriptionsRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'notifier_engine/render_subscriptions';

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
        SubscriptionsRepo newRepo = SubscriptionsRepo.fromJson(result['data']);
        repo.mergeNewRepo(newRepo);
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;

        return repo;
      }
    } catch (e) {
      return repo;
    }
    return repo;
  }

  Future<ThreadNotifications> renderThreads(ThreadNotifications repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'notifier_engine/render_replies';

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
        ThreadNotifications newRepo =
            ThreadNotifications.fromJson(result['data']);
        repo.mergeNewRepo(newRepo);
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;

        return repo;
      }
    } catch (e) {
      rethrow;
    }
    return repo;
  }

  Future<ForYouRepo> renderForYou(ForYouRepo repo,
      {bool refresh = false}) async {
    var apiEndpoint = 'notifier_engine/render_for_you';
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
        ForYouRepo newRepo = ForYouRepo.fromJson(result['data']);
        repo.mergeNewRepo(newRepo);
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;

        return repo;
      }
    } catch (e) {
      rethrow;
    }
    return repo;
  }

  Future<String?> markNotificationAsSeen(Map data) async {
    try {
      var apiEndpoint = 'notifier_engine/mark_notification_as_seen';
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        return null;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      rethrow;
    }
  }

  Future<int> getNotificationsCount() async {
    try {
      var apiEndpoint = 'notifier_engine/get_unread_notification_count';

      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
