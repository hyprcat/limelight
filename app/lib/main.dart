// ignore_for_file: depend_on_referenced_packages, unused_field, unused_local_variable

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';
import 'package:lime_time_app/logics/services/push_notification_service.dart';
import 'package:lime_time_app/logics/models/users/user_channel.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/screens/authentication/signin.dart';
import 'package:lime_time_app/screens/authentication/user_details.dart';
import 'package:lime_time_app/screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lime_time_app/screens/settings/contests/september_contest.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/widgets/ban_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import 'package:lime_time_app/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lime_time_app/configure_nonweb.dart'
    if (dart.library.html) 'package:lime_time_app/configure_web.dart';
import 'package:lime_time_app/defaults/colors.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/scheduler.dart' show timeDilation;
import 'dart:io' show Platform;

Future<Position> determinePosition() async {
  // Checks if location services are enabled on the device.
  // If location services are disabled, an error is returned.
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Checks the current location permission status.
  // If permission is denied, a request for permission is made.
  // If permission is denied again, an error is returned.
  permission = await Geolocator.checkPermission();

  // If the permission is denied forever, an error is returned,
  // indicating that location permissions cannot be requested again.
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Fetches the user's location details from a custom UserEngine service.
  // The details include city, country, and region.
  Map locationData = await UserEngine().fetchUserLocation();
  var data = {
    'user_city': locationData['city'],
    'user_country': locationData['country'],
    'user_region': locationData['region'],
  };

  // Gets the current position of the device using the Geolocator package.
  // This provides the latitude and longitude of the device's location.
  return await Geolocator.getCurrentPosition();
}

void requestNotificationPermissions() async {
  // Initializes Firebase Messaging instance.
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Requests notification permissions from the user.
  // The request includes permissions for alert, badge, and sound notifications.
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Checks the authorization status of the requested permissions.
  // If the permissions are granted, you can proceed with setting up notifications.
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  } else {}
}

Future<String> buildRoute() async {
  // Checks if a session token exists.
  // If a session token is available, fetches user info and loads cached user data,
  // then returns the route for the home screen.

  if (sessionData!['token'] != null) {
    await UserEngine().fetchUserInfo(true);
    await authHandler.loadCachedUser();
    if (authHandler.loggedInUser!.isBanned!) {
      return '/banned';
    }
    return '/home';
  } else {
    // If no session token is available, returns the route for the login screen.
    return '/';
  }
}

Future<void> initialiseHive() async {
  // Initializes Hive, a lightweight key-value database for Flutter.
  await Hive.initFlutter();

  // Registers adapters for various data models that will be stored in the Hive database.
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(UserLoungeAdapter());
  Hive.registerAdapter(LoungeCategoryAdapter());
  Hive.registerAdapter(LoungeSectionAdapter());
  Hive.registerAdapter(UserChannelAdapter());

  // Reads all session data from secure storage and assigns it to the sessionData variable.
  sessionData = await storage.readAll();
}

FirebaseAnalytics? analytics;

checkReinstall() async {
  final prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('first_run') ?? true) {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.deleteAll();
    prefs.setBool('first_run', false);
  }
}

void main() async {
  // Ensures that Flutter's binding is initialized before any other code is run.
  WidgetsFlutterBinding.ensureInitialized();

  // MediaKit.ensureInitialized();
  // Adjusts the time dilation for animations. Setting timeDilation to 0.85 slows down animations slightly,
  // making them appear smoother to the human eye. This can improve the user experience.
  timeDilation = 0.75;

  // If the application is running on an Android device, enable resampling to smooth out gesture inputs
  // and set the display mode to the highest available refresh rate for a smoother visual experience.
  if (Platform.isAndroid) {
    GestureBinding.instance.resamplingEnabled = true;
    await FlutterDisplayMode.setHighRefreshRate();
  }

  // Initializes Firebase, which is a backend service that provides a wide range of functionality,
  // including analytics, authentication, database, and notifications.
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

  // Initializes Firebase Analytics, a service that helps in tracking user behavior within the app.
  analytics = FirebaseAnalytics.instance;

  // Checks if this is the first time the app is being run after installation.
  // If it is the first run, certain setup actions can be performed, such as showing a tutorial.
  firstRun = await IsFirstRun.isFirstCall();

  // Initializes the push notification service, which will handle the receipt and display of push notifications.
  requestNotificationPermissions();
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    showFlutterNotification(message);
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

  // Initializes Hive, a lightweight and fast key-value database for Flutter that is used for local storage.
  await initialiseHive();

  // This function checks if the application has been reinstalled.
  // If so, it clears the secure storage to remove any stale data from a previous installation.
  await checkReinstall();

  // Determines the device's current geolocation, which is used to update data for features like trending topics and leaderboards.
  // This might involve accessing the device's GPS to get the current location.
  var x = determinePosition();

  // Builds the default route for the app's navigation. This could involve setting up initial routes and
  // determining where the user should be directed first, such as a login screen or home screen.
  final defaultRoute = await buildRoute();

  // Configures the app by performing various setup actions.
  // This might include setting global settings, initializing services, and preparing the app for use.
  configureApp();

  // Checks if there is a valid session token available.
  // If there is, it updates the user's geographical details, possibly by sending the location data to a server.
  if (sessionData!['token'] != null) {
    await UserEngine().updateGeoDetails();
  }

  // Runs the Flutter application with the main widget `MyApp`, and passes in the initial route determined earlier.
  runApp(MyApp(route: defaultRoute));
}

class MyApp extends StatefulWidget {
  final route;
  const MyApp({required this.route, super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  void toggleDeveloperSettings() {
    setState(() {
      debugSettings = !debugSettings;
    });
  }

  void toggleExperimentalUI() {
    setState(() {
      isExperimental = !isExperimental;
    });
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      theme = themeMode;
    });
  }

  buildApp() {
    Map<String, UpgradeAlert Function(dynamic context)> routes;

    if (widget.route == '/home') {
      UserEngine().updateGeoDetails();
      routes = {
        '/': (context) => UpgradeAlert(child: const Home()),
        '/home': (context) => UpgradeAlert(child: const Home()),
        '/banned': (context) => UpgradeAlert(child: ErrorBanned()),
        '/sept_contest_banner': (context) =>
            UpgradeAlert(child: const SeptemberContest()),
        '/user_details': (context) =>
            UpgradeAlert(child: const UserDetailsSection()),
      };
    } else if (widget.route == '/banned') {
      routes = {
        '/': (context) => UpgradeAlert(child: ErrorBanned()),
        '/home': (context) => UpgradeAlert(child: const Home()),
        '/banned': (context) => UpgradeAlert(child: ErrorBanned()),
        '/sept_contest_banner': (context) =>
            UpgradeAlert(child: const SeptemberContest()),
        '/user_details': (context) =>
            UpgradeAlert(child: const UserDetailsSection())
      };
    } else {
      routes = {
        '/': (context) => UpgradeAlert(child: const SignIn()),
        '/home': (context) => UpgradeAlert(child: const Home()),
        '/banned': (context) => UpgradeAlert(child: ErrorBanned()),
        '/sept_contest_banner': (context) =>
            UpgradeAlert(child: const SeptemberContest()),
        '/user_details': (context) =>
            UpgradeAlert(child: const UserDetailsSection())
      };
    }

    if ((sessionData!['token'] != null) && authHandler.loggedInUser == null) {
      routes['/'] =
          (context) => UpgradeAlert(child: const UserDetailsSection());
    }

    return routes;
  }

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    if (videoPlayerController.value != null) {
      videoPlayerController.value!.dispose(forceDispose: true);
      videoPlayerController.value = null;
    }
    invalidateAllControllers();
    playerWidget.value = null;
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {}
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lime",
      navigatorObservers: [myNavigatorObserver],
      navigatorKey: navigatorKey,
      themeMode: theme,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: lightTheme,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 1.05, // Minimum scale factor allowed.
          maxScaleFactor: 1.15, // Maximum scale factor allowed.
        );
        return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: scale,
            ),
            child: child!);
      },
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: buildApp(),
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> _history = [];

  List<Route<dynamic>> get history => List.unmodifiable(_history);

  @override
  void didPush(Route route, Route? previousRoute) {
    _history.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _history.remove(route);
  }
}

final MyNavigatorObserver myNavigatorObserver = MyNavigatorObserver();

bool isExpandedScreenInStack(MyNavigatorObserver observer) {
  return observer._history.any((route) =>
      route is MaterialPageRoute &&
      route.builder is ExpandedVideo Function(BuildContext));
}
