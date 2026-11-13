import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const primaryAccentColor = Colors.yellow;
Color buttonColor = Colors.green;
Color hoverColor = Colors.green.shade300;
Color activeColor = Colors.green;

Color appBarColor = const Color(0xff101010);

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemTeal,
        brightness: Brightness.light,
        surface: Colors.white,
        surfaceTint: Colors.transparent,
        outline: Colors.grey.shade200),
    dividerColor: Colors.grey.shade200,
    focusColor: Colors.grey.shade200);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.systemPink,
      primary: CupertinoColors.systemPink,
      surface: const Color(0xff111111),
      brightness: Brightness.dark,
      surfaceTint: Colors.transparent,
      outline: Colors.grey.shade900),
);

List<Color> colorsForPosts = [
  CupertinoColors.systemGreen,
  CupertinoColors.systemOrange,
  CupertinoColors.systemTeal,
  CupertinoColors.systemIndigo,
  CupertinoColors.systemYellow,
  CupertinoColors.systemBrown
];
