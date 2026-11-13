// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

final List<String> topicCategories = [
  "Cars and vehicles",
  "Comedy",
  "Education",
  "Entertainment",
  "Film and animation",
  "Gaming",
  "How-to and style",
  "Music",
  "News and politics",
  "Non-profits and activism",
  "People and blogs",
  "Pets and animals",
  "Science and technology",
  "Sport",
  "Travel and events"
];

/// Base URL of the core API (the `core/` directory of this repository).
/// Override with `--dart-define=LIMELIGHT_API_URL=https://your-host/`.
String URL = const String.fromEnvironment('LIMELIGHT_API_URL', defaultValue: 'http://127.0.0.1:8000/');

bool checkEmail(text) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
}

String activeTheme = "dark";

Icon buildThemeIcon() {
  if (activeTheme == 'dark') {
    return const Icon(Icons.brightness_1_outlined);
  } else {
    return const Icon(Icons.brightness_2_rounded);
  }
}
