import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/screens/authentication/signin.dart';
import 'package:lime_time_app/screens/notifications/notifications_home.dart';

import 'package:lime_time_app/firebase_options.dart';

bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // If a FirebaseException is thrown with the code 'duplicate-app', it means the app has already been initialized.
    // To handle this, we try to initialize Firebase again without any options.
    if (e.code == 'duplicate-app') {
      await Firebase.initializeApp();
    }
  }

  await setupFlutterNotifications();
  showFlutterNotification(message);
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('drawable/icon');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  Map data = message.data;
  flutterLocalNotificationsPlugin.show(
    data.hashCode,
    data['title'],
    data['body'],
    payload: jsonEncode(message.data),
    NotificationDetails(
      android: AndroidNotificationDetails(channel.id, channel.name,
          color: Colors.yellow,
          channelDescription: channel.description,
          icon: 'drawable/icon'),
    ),
  );
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  Map payload = jsonDecode(notificationResponse.payload!);
  if (sessionData!['token'] != null) {
    Navigator.of(navigatorKey.currentState!.context, rootNavigator: false).push(
        MaterialPageRoute(builder: (context) => const NotificationsHome()));
  } else {
    Navigator.of(navigatorKey.currentState!.context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => const SignIn()));
  }

  // handle action
}
