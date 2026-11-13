import 'package:code_arrow_creator_studio/screens/not_found.dart';
import 'package:code_arrow_creator_studio/screens/home/home.dart';
import 'package:code_arrow_creator_studio/screens/login/create_user_profile.dart';
import 'package:code_arrow_creator_studio/screens/login/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:code_arrow_creator_studio/configure_nonweb.dart' if (dart.library.html) 'package:code_arrow_creator_studio/configure_web.dart';

const storage = FlutterSecureStorage();
Map<String, String>? sessionData;

String buildRoute() {
  if (sessionData!['token'] != null) {
    return '/home';
  } else {
    return '/';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sessionData = await storage.readAll();
  configureApp();
  final defaultRoute = buildRoute();
  runApp(MyApp(
    route: defaultRoute,
  ));
}

class MyApp extends StatefulWidget {
  final String route;
  const MyApp({super.key, required this.route});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creator Studio',
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      themeMode: _themeMode, // device controls theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemYellow,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.nunito(),
          bodyMedium: GoogleFonts.lato(),
          displaySmall: GoogleFonts.lato(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: CupertinoColors.systemYellow, brightness: Brightness.dark, background: const Color(0xff010101), outline: Colors.grey.shade900),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.raleway(),
          bodyMedium: GoogleFonts.raleway(),
          displaySmall: GoogleFonts.raleway(),
        ),
      ),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      initialRoute: "/",

      routes: {
        '/home': (context) => const CreatorStudioHome(),
        '/': (context) => const SignupScreen(),
        '/404': (context) => const Error404(),
        '/user_profile': (context) => const CreateUserProfile()
      },
    );
  }
}
