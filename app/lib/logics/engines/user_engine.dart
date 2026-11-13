// ignore_for_file: depend_on_referenced_packages, unused_local_variable

import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/contests/september_contest.dart';
import 'package:lime_time_app/logics/models/users/user_channel.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/main.dart';

import 'package:lime_time_app/logics/models/videos/video_post.dart';

class UserEngine {
  Dio dio = Dio(
    BaseOptions(
      headers: {"authorization": sessionData?['token'] ?? ""},
      followRedirects: false,
    ),
  );
  final String url = URL;

  void _putKeyToStorage(String key) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.write(key: "token", value: key);
      sessionData = await storage.readAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cacheUserInfo(UserProfile userProfile) async {
    try {
      var box = await Hive.openBox('logged-in-user');
      await box.put('user_obj', userProfile);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile?> getCachedUserInfo() async {
    try {
      var box = await Hive.openBox('logged-in-user');
      return box.get('user_obj', defaultValue: null);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sendMailOTP(dynamic data) async {
    var apiEndpoint = 'user_eng/start_reset_pipeline';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data['message'];
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> verifyOTP(dynamic data) async {
    var apiEndpoint = 'user_eng/verify_otp';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data['message'];
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resetPassword(dynamic data) async {
    var apiEndpoint = 'user_eng/reset_password';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      return response.data['message'];
    } on DioException catch (e) {
      throw (e.response!.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createUser(dynamic data) async {
    var apiEndpoint = 'user_eng/create_user';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      return json.decode(response.data)['message'];
    } on DioException catch (e) {
      throw (e.response!.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoRepo> loadSubscribedToVideos(VideoRepo repo) async {
    var apiEndpoint = 'video_engine/fetch_subscribed_to_videos';

    try {
      var data = {
        'page_number': repo.currentPage,
        'token': sessionData!['token']
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      if (repo.currentPage <= result['total_pages']) {
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
      }
    } catch (e) {}
    return repo;
  }

  Future<String> partialLogin(dynamic data) async {
    var apiEndpoint = 'user_engine/login/';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      final key = result['key'];
      dio = Dio(
        BaseOptions(
          headers: {"authorization": result['key'] ?? ""},
          followRedirects: false,
        ),
      );

      _putKeyToStorage(key);
      sessionData = await storage.readAll();

      return key;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> login(dynamic data) async {
    var apiEndpoint = 'user_engine/login/';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      final key = result['key'];
      dio = Dio(
        BaseOptions(
          headers: {"Authorization": key ?? ""},
          followRedirects: false,
        ),
      );
      _putKeyToStorage(key);
      sessionData = await storage.readAll();
      var profile = await fetchUserInfo(true);
      analytics!.setUserId(id: profile!.userId!.toString());
      analytics!.logLogin(loginMethod: 'email');
      await updateGeoDetails();
      return key;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile?> fetchUserInfo(bool refresh) async {
    try {
      var apiEndpoint = 'user_eng/get_user_info';
      var getCurrentUser = 'user_eng/get_logged_in_user';

      var userTokens = {'token': sessionData!['token']};
      final response = await dio.post(url + getCurrentUser, data: userTokens);
      final result = await jsonDecode(response.data);

      final userProfileObj = UserProfile.fromJson(result);
      authHandler.loggedInUser = userProfileObj;
      await cacheUserInfo(userProfileObj);
      return userProfileObj;
    } catch (e) {
      rethrow;
    }
  }

  String generateRandomFilename(int length) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) {
      final randomIndex = random.nextInt(charset.length);
      return charset[randomIndex];
    }).join();
  }

  Future<String> updateUserProfile(dynamic data) async {
    var apiEndpoint = 'user_eng/create_user_profile';
    try {
      data['token'] = sessionData!['token'];

      var formData = FormData.fromMap(<String, dynamic>{
        'bio': data['bio'],
        'age': data['age'],
        'gender': data['gender'],
        'token': sessionData!['token']
      });
      if (data['media'] != null) {
        var mediaFile = MultipartFile.fromBytes(
          data['media']!.files.first.bytes!,
          filename: "${generateRandomFilename(16)}.jpeg",
          contentType: MediaType('image', 'jpeg'),
        );
        formData.files.add(MapEntry('media', mediaFile));
      }

      final response = await dio.post(url + apiEndpoint, data: formData);
      final result = json.decode(response.data)['message'];

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> getLoggedInUser() async {
    var apiEndpoint = 'user_eng/get_logged_in_user';
    try {
      var data = {};
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = json.decode(response.data);
      UserProfile userProfile = UserProfile.fromJson(result);
      return userProfile;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> handleGoogleSignIn(String? token) async {
    var apiEndpoint = 'user_eng/validate_google_id_token';
    try {
      final response =
          await dio.post(url + apiEndpoint, data: {'token': token});
      final result = response.data;
      final key = result['key'];
      _putKeyToStorage(key);
      sessionData = await storage.readAll();
      final userProfileObj = UserProfile.fromJson(result['user_info']);
      analytics!.setUserId(id: userProfileObj.userId!.toString());
      analytics!.logLogin(loginMethod: 'google_sign_in');
      authHandler.loggedInUser = userProfileObj;
      await cacheUserInfo(userProfileObj);
      return key;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> handleAppleSignIn(String? token) async {
    var apiEndpoint = 'user_eng/validate_apple_id_token';
    try {
      final response =
          await dio.post(url + apiEndpoint, data: {'token': token});
      final result = response.data;
      final key = result['key'];
      _putKeyToStorage(key);
      sessionData = await storage.readAll();
      final userProfileObj = UserProfile.fromJson(result['user_info']);
      analytics!.setUserId(id: userProfileObj.userId!.toString());
      analytics!.logLogin(loginMethod: 'apple_sign_in');
      authHandler.loggedInUser = userProfileObj;
      await cacheUserInfo(userProfileObj);
      return key;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> subscribeChannel(UserChannel userChannel) async {
    var apiEndpoint = 'user_eng/subscribe_channel';
    try {
      final data = {
        'token': sessionData!['token'],
        'channel_id': userChannel.id
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> blockUser(String userId) async {
    var apiEndpoint = 'user_eng/block_user';
    try {
      final data = {
        'token': sessionData!['token'],
        'user_id': userId,
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> unblockUser(String userId) async {
    var apiEndpoint = 'user_eng/unblock_user';
    try {
      final data = {
        'token': sessionData!['token'],
        'user_id': userId,
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addUserAccountRemoval(String reason) async {
    var apiEndpoint = 'user_eng/add_user_account_removal_request';
    try {
      final data = {'token': sessionData!['token'], 'reason': reason};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUserAccountRemoval() async {
    var apiEndpoint = 'user_eng/check_user_account_removal_request';
    try {
      final data = {'token': sessionData!['token']};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> unsubscribeChannel(UserChannel userChannel) async {
    var apiEndpoint = 'user_eng/unsubscribe_channel';
    try {
      final data = {
        'token': sessionData!['token'],
        'channel_id': userChannel.id
      };
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data['message'];
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> subscriptionStatus(UserChannel userChannel, int userId) async {
    var apiEndpoint = 'user_eng/subscription_status';
    try {
      final data = {'user_id': userId, 'channel_id': userChannel.id};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      return result['message'];
    } catch (e) {
      return false;
    }
  }

  Future<UserProfile?> getUserInfo(int userId) async {
    var apiEndpoint = 'user_eng/get_user_info';
    try {
      final data = {'user_id': userId, 'token': sessionData!['token']};
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      return UserProfile.fromJson(result);
    } catch (e) {
      return null;
    }
  }

  Future<bool> uploadUserProfilePic(MultipartFile? image) async {
    try {
      var apiEndpoint = 'user_eng/update_profile_picture';

      var data = {'token': sessionData!['token'], 'media': image};

      final formData = FormData.fromMap(data);

      final response = await dio.post(url + apiEndpoint, data: formData);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.data);
        return result['message'] == "updated.";
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadUserProfileBanner(MultipartFile? image) async {
    try {
      var apiEndpoint = 'user_eng/update_profile_banner';

      var data = {'token': sessionData!['token'], 'media': image};

      final formData = FormData.fromMap(data);

      final response = await dio.post(url + apiEndpoint, data: formData);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.data);
        return result['message'] == "updated.";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    try {
      var apiEndpoint = 'user_eng/delete_user_profile_picture';

      var data = {'token': sessionData!['token']};
      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "updated.";
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteProfileBanner() async {
    try {
      var apiEndpoint = 'user_eng/delete_user_profile_banner';

      var data = {'token': sessionData!['token']};

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "updated.";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> updateChannelDetails(dynamic data) async {
    try {
      var apiEndpoint = 'user_eng/update_channel_details';

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "Updated successfully.";
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., log an error)
      return false;
    }
  }

  Future<bool> updateProfileDetails(dynamic data) async {
    try {
      var apiEndpoint = 'user_eng/update_profile_details';
      Map locationData = await UserEngine().fetchUserLocation();
      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "Updated successfully.";
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkBan(String userId) async {
    try {
      var apiEndpoint = 'user_eng/check_ban';
      var data = {'user_id': userId};

      final response = await dio.post(url + apiEndpoint, data: data);

      if (response.statusCode == 200) {
        return response.data['message'] == "Updated successfully.";
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<SeptemberContestData> getSeptemberContestDetails() async {
    try {
      var apiEndpoint = 'user_eng/get_september_contest_details';
      Map locationData = await UserEngine().fetchUserLocation();
      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});
      SeptemberContestData contest =
          SeptemberContestData.fromJson(response.data);
      return contest;
    } catch (e) {
      return SeptemberContestData();
    }
  }

  Future<bool> reCheckToken() async {
    try {
      var apiEndpoint = 'user_eng/recheck_token';
      Map locationData = await UserEngine().fetchUserLocation();
      final response = await dio
          .post(url + apiEndpoint, data: {'token': sessionData!['token']});

      if (response.statusCode == 200) {
        return response.data['message'] == "Updated successfully.";
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> reportUser(dynamic data) async {
    try {
      var apiEndpoint = 'user_eng/report_user';

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

  Future<Map<String, dynamic>> getTokenAndRegisterDevice() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceModel = '';
    String osVersion = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
    }

    // Send the device information to your backend
    return {
      'fcm_token': token,
      'device_model': deviceModel,
      'os_version': osVersion,
    };
  }

  Future<bool> updateGeoDetails() async {
    try {
      var position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      Map<String, dynamic> data = {
        'token': sessionData!['token'],
        'city': place.locality,
        'country': place.country,
        'region': place.administrativeArea,
      };

      Map<String, dynamic> notificationData = await getTokenAndRegisterDevice();
      data.addAll(notificationData);

      var apiEndpoint = 'user_eng/update_geo_location';
      data['token'] = sessionData!['token'];
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

  Future<bool> logout() async {
    var apiEndpoint = 'user_engine/logout/';
    try {
      var data = {'token': sessionData!['token']};
      final response = await dio.post(
        url + apiEndpoint,
        options: Options(
          headers: data,
        ),
      );

      if (response.data['detail'] == "Successfully logged out.") {
        await storage.delete(key: 'token');
        var box = await Hive.openBox('logged-in-user');
        await box.delete('user_obj');
        sessionData = await storage.readAll();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> fetchUserLocation() async {
    try {
      if (location.isEmpty) {
        var position = await Geolocator.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];

        location = {
          'city': place.locality,
          'country': place.country,
          'region': place.administrativeArea,
        };
      }
      return location;
    } catch (e) {
      // Handle other errors, e.g., network issues or unexpected exceptions.
      return {};
    }
  }

  Future<UserRepo> fetchSubscribedUsers(UserRepo repo) async {
    var apiEndpoint = 'user_eng/get_subscribed_to_api';

    try {
      Map data = {};
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile user = UserProfile.fromJson(i);
          repo.profiles.add(user);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {}
    return repo;
  }

  Future<UserRepo> fetchBlockedUsers(UserRepo repo) async {
    var apiEndpoint = 'user_eng/get_blocked_users';

    try {
      Map data = {};
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile user = UserProfile.fromJson(i);
          repo.profiles.add(user);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {
      rethrow;
    }
    return repo;
  }

  Future<UserRepo> getTopUsersDay(UserRepo repo, Map data) async {
    var apiEndpoint = 'user_eng/get_top_users_day_view';

    try {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile user = UserProfile.fromJson(i);
          repo.profiles.add(user);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {}
    return repo;
  }

  Future<UserRepo> getTopUsersWeek(UserRepo repo, Map data) async {
    var apiEndpoint = 'user_eng/get_top_users_week_view';

    try {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile user = UserProfile.fromJson(i);
          repo.profiles.add(user);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {}
    return repo;
  }

  Future<UserRepo> getTopUsersMonth(UserRepo repo, Map data) async {
    var apiEndpoint = 'user_eng/get_top_users_month_view';

    try {
      data['page_number'] = repo.currentPage;
      data['token'] = sessionData!['token'];
      final response = await dio.post(url + apiEndpoint, data: data);
      final result = response.data;
      if (repo.currentPage <= result['total_pages']) {
        List<UserProfile> tmpProfiles = [];
        for (var i in result['data']) {
          UserProfile user = UserProfile.fromJson(i);
          repo.profiles.add(user);
        }
        int x = result['page_number'];
        int y = result['total_pages'];

        repo.currentPage = x + 1;
        repo.lastPage = y;
      }
    } catch (e) {}
    return repo;
  }
}
