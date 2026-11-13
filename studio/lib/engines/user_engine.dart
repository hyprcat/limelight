import 'dart:convert';
import 'dart:math';

import 'package:code_arrow_creator_studio/defaults/constants.dart';
import 'package:code_arrow_creator_studio/engines/models/user_profile.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class UserEngine {
  final Dio dio = Dio();
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

  Future<String> createUser(dynamic data) async {
    var apiEndpoint = 'user_eng/create_user';
    try {
      final response = await dio.post(url + apiEndpoint, data: data);
      return json.decode(response.data)['message'];
    } on DioException catch (e) {
      throw (e.response!.data!);
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

      _putKeyToStorage(key);
      return key;
    } on DioException catch (e) {
      throw (e.response!.data['non_field_errors'][0]);
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

      var formData =
          FormData.fromMap(<String, dynamic>{'bio': data['bio'], 'age': data['age'], 'gender': data['gender'], 'token': sessionData!['token']});
      var mediaFile = MultipartFile.fromBytes(
        data['media']!.files.first.bytes!,
        filename: "${generateRandomFilename(16)}.jpeg",
        contentType: MediaType('image', 'jpeg'),
      );

      formData.files.add(MapEntry('media', mediaFile));
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
}
