import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:convert';
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:lime_time_app/defaults/constants.dart';

Icon buildThemeIcon() {
  if (activeTheme == 'dark') {
    return const Icon(
      Icons.brightness_1_outlined,
      color: CupertinoColors.systemYellow,
    );
  } else {
    return const Icon(
      Icons.brightness_2_rounded,
      color: CupertinoColors.systemYellow,
    );
  }
}

String numToEng(int num) {
  if (num >= 1000000) {
    return '${(num / 1000000).toStringAsFixed(1)} mil';
  } else if (num >= 1000) {
    return '${(num / 1000).toStringAsFixed(1)}k';
  } else {
    return num.toString();
  }
}

Color randomOpaqueColor() {
  return Color(Random().nextInt(0xffffffff)).withAlpha(0xff);
}

String formatDuration(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = hours > 0 ? hours.toString() : "";
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return "$hoursStr:$minutesStr:$secondsStr";
  } else {
    return "$minutesStr:$secondsStr";
  }
}

String numToEngDouble(double num) {
  if (num >= 1000000) {
    return '${(num / 1000000).toStringAsFixed(1)} mil';
  } else if (num >= 1000) {
    return '${(num / 1000).toStringAsFixed(1)}k';
  } else {
    return num.toString();
  }
}

String dateTimeToWords(String dateTimeStr) {
  var dateTime = DateTime.parse(dateTimeStr);
  var formatter = DateFormat('MMMM d, y');
  return formatter.format(dateTime.toLocal());
}

String formatTimeAgo(String dateTimeStr) {
  var dateTime = DateTime.parse(dateTimeStr);
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes${minutes == 1 ? 'min' : 'minutes'}';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours${hours == 1 ? 'h' : 'h'}';
  } else if (difference.inDays < 30) {
    final days = difference.inDays;
    return '$days${days == 1 ? 'd' : 'd'}';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).round();
    int weeks = months * 4;
    return '$weeks${weeks == 1 ? 'w' : 'w'}';
  } else {
    final years = (difference.inDays / 365).round();
    return '$years${years == 1 ? 'y' : 'y'}';
  }
}

String formatTimeAgoFull(String dateTimeStr) {
  var dateTime = DateTime.parse(dateTimeStr);
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 30) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).round();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else {
    final years = (difference.inDays / 365).round();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
}

double valueFromPercentageInRange(
    {required final double min, max, percentage}) {
  return percentage * (max - min) + min;
}

double percentageFromValueInRange({required final double min, max, value}) {
  return (value - min) / (max - min);
}

List<TextSpan> highlightLinksHashtagsTimestamps(String text) {
  List<TextSpan> spans = [];

  RegExp linkRegExp = RegExp(r'https?://\S+');
  RegExp hashtagRegExp = RegExp(r'#\w+');
  RegExp timestampRegExp = RegExp(r'\d+:\d+(:\d+)?');

  List<RegExpMatch> links = linkRegExp.allMatches(text).toList();
  List<RegExpMatch> hashtags = hashtagRegExp.allMatches(text).toList();
  List<RegExpMatch> timestamps = timestampRegExp.allMatches(text).toList();

  int currentIndex = 0;

  void addNonMatchedText(int endIndex) {
    if (currentIndex < endIndex) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex, endIndex),
        ),
      );
    }
  }

  for (RegExpMatch link in links) {
    addNonMatchedText(link.start);
    spans.add(
      TextSpan(
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            var url = Uri.parse(link.group(0).toString());
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          },
        text: link.group(0),
        style: const TextStyle(color: Colors.blue),
      ),
    );
    currentIndex = link.end;
  }

  for (RegExpMatch hashtag in hashtags) {
    addNonMatchedText(hashtag.start);
    spans.add(
      TextSpan(
        text: hashtag.group(0),
        style: const TextStyle(color: Colors.yellowAccent),
      ),
    );
    currentIndex = hashtag.end;
  }

  for (RegExpMatch timestamp in timestamps) {
    addNonMatchedText(timestamp.start);
    spans.add(
      TextSpan(
        recognizer: TapGestureRecognizer()..onTap = () async {},
        text: timestamp.group(0),
        style: const TextStyle(color: Colors.blue),
      ),
    );
    currentIndex = timestamp.end;
  }

  addNonMatchedText(text.length);

  return spans;
}

Showcase makeShowCase(
    {BuildContext? context,
    GlobalKey? key,
    String? title,
    String? description,
    Widget? child}) {
  return Showcase(
      key: key!,
      targetShapeBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      blurValue: 1,
      title: title,
      description: description,
      titleTextStyle: defaultHeadingText(context!),
      descTextStyle: defaultLabelText(context, fontWeight: FontWeight.w600),
      tooltipBackgroundColor: Colors.transparent,
      titlePadding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      descriptionPadding:
          const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
      child: child!);
}

String generateRandomString(String input) {
  List<int> bytes = utf8.encode(input);
  int seed = bytes.fold(0, (p, c) => p + c);
  Random random = Random(seed);
  int index = random.nextInt(userBios.length);
  return userBios[index];
}

BetterPlayerController makeController(VideoPost video) {
  Map<String, String> newMap = {};
  List<int> resolutions = [144, 240, 360, 480, 720, 1080, 1440];
  if (video.isEncoded!) {
    var start = 0;
    if (video.maxTranscodedResolution == 0) {
      while (video.videoHeight! >= resolutions[start]) {
        newMap["${resolutions[start]}p"] =
            videoStreamUrl(video.id!, resolutions[start]);
        start += 1;
        if (start >= resolutions.length) {
          break;
        }
      }
    } else {
      while (video.maxTranscodedResolution! > resolutions[start]) {
        newMap["${resolutions[start]}p"] =
            videoStreamUrl(video.id!, resolutions[start]);
        start += 1;
        if (start >= resolutions.length) {
          break;
        }
      }
    }
  }

  var url = originalVideoUrl(video.id!);
  Color color = CupertinoColors.darkBackgroundGray;
  Color textColor = Colors.white;

  BetterPlayerConfiguration betterPlayerConfiguration =
      BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,
    autoDetectFullscreenAspectRatio: true,
    showPlaceholderUntilPlay: true,
    handleLifecycle: false,
    autoDispose: false,
    autoDetectFullscreenDeviceOrientation: true,
    aspectRatio: 16 / 9,
    allowedScreenSleep: false,
    fit: BoxFit.contain,
    controlsConfiguration: BetterPlayerControlsConfiguration(
        controlBarColor: Colors.black38,
        showControlsOnInitialize: false,
        overflowModalColor: color,
        overflowModalTextColor: textColor,
        overflowMenuIconsColor: textColor,
        qualitiesIcon: Iconsax.setting_2_outline,
        subtitlesIcon: Iconsax.subtitle_outline,
        audioTracksIcon: Iconsax.audio_square_outline,
        playbackSpeedIcon: Iconsax.speedometer_outline,
        playerTheme: BetterPlayerTheme.material,
        playIcon: Iconsax.play_outline,
        pauseIcon: Iconsax.pause_outline,
        textColor: CupertinoColors.white,
        iconsColor: CupertinoColors.systemYellow,
        muteIcon: Iconsax.volume_mute_outline,
        unMuteIcon: Iconsax.volume_cross_outline,
        progressBarPlayedColor: CupertinoColors.systemYellow,
        progressBarBufferedColor: Colors.grey.shade400),
  );
  var betterPlayerController =
      BetterPlayerController(betterPlayerConfiguration);
  bool sourceError = false;
  var betterPlayerDataSource = BetterPlayerDataSource(
    BetterPlayerDataSourceType.network,
    (video.isEncoded!)
        ? (newMap.containsKey("360p") ? newMap["360p"]! : newMap.values.first)
        : url,
    resolutions: (video.isEncoded!) ? newMap : null,
    videoFormat: (video.isEncoded!) ? BetterPlayerVideoFormat.hls : null,
    bufferingConfiguration: const BetterPlayerBufferingConfiguration(
      minBufferMs: 5000,
      maxBufferMs: 131072,
      bufferForPlaybackMs: 2500,
      bufferForPlaybackAfterRebufferMs: 5000,
    ),
    cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 10 * 1024 * 1024,
        maxCacheFileSize: 10 * 1024 * 1024,
        preCacheSize: 3 * 1024 * 1024),
  );

  betterPlayerController
      .setupDataSource(betterPlayerDataSource)
      .then((response) {})
      .catchError((error) {
    var original = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      resolutions: null,
      videoFormat: null,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 131072,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
      cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 10 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
          preCacheSize: 3 * 1024 * 1024),
    );
    betterPlayerController.setupDataSource(original);
  });
  if (sourceError) {}

  return betterPlayerController;
}

Color generateColorFromString(String input) {
  var hash = 0;
  for (var i = 0; i < input.length; i++) {
    hash = input.codeUnitAt(i) + ((hash << 5) - hash);
  }
  final finalHash = hash.abs() % (256 * 256 * 256);
  final red = ((finalHash & 0xFF0000) >> 16);
  final blue = ((finalHash & 0xFF00) >> 8);
  final green = ((finalHash & 0xFF));
  final color = Color.fromRGBO(red, green, blue, 1);
  return color;
}

Color generateTextColor(Color color) {
  if (color.computeLuminance() < 0.4) {
    return Colors.white;
  } else {
    return Colors.black;
  }
}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}

EventTransformer<Event> debounce<Event>({
  Duration duration = const Duration(milliseconds: 100),
}) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}
