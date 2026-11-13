// ignore_for_file: must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BetterPlayerWidget extends StatefulWidget {
  final VideoPost video;
  final bool? showControls;
  final bool? updateWhileProgress;
  BetterPlayerController? betterPlayerController;
  BetterPlayerController? get playerController => betterPlayerController;
  BetterPlayerWidget(
      {super.key,
      required this.video,
      this.betterPlayerController,
      this.showControls = true,
      this.updateWhileProgress = false});

  @override
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BetterPlayerController? get betterPlayerController =>
      widget.betterPlayerController;

  BetterPlayerDataSource? _betterPlayerDataSource;

  void onPlayerEvent(BetterPlayerEvent event) async {
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      var ratio =
          betterPlayerController!.videoPlayerController!.value.aspectRatio;
      analytics!.logEvent(name: 'video_playback_started', parameters: {
        'video_id': widget.video.id.toString(),
        'viewed_by': authHandler.loggedInUser!.userId!.toString()
      });
      if (ratio > 0) {
        betterPlayerController!.setOverriddenAspectRatio(
            betterPlayerController!.videoPlayerController!.value.aspectRatio);
      }
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      if (widget.updateWhileProgress!) {
        videoPlayerController.value = widget.betterPlayerController;
      }

      var progress = event.parameters!["progress"] as Duration?;
      progress!.inSeconds;
      var data = {
        'video_id': widget.video.id,
        'view_time_seconds': progress.inSeconds,
      };
      VideoEngine().setView(data);
      analytics!.logEvent(name: 'view_set', parameters: {
        'video_id': widget.video.id.toString(),
        'viewed_by': authHandler.loggedInUser!.userId!.toString()
      });
      WakelockPlus.enable();
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (widget.video.lastPosition != null) {
        betterPlayerController!.seekTo(widget.video.lastPosition!);
      }
      if (widget.video.wasPlaying!) {
        betterPlayerController!.play();
      }
    }

    if (event.betterPlayerEventType != BetterPlayerEventType.progress) {
      WakelockPlus.disable();
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen ||
        event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
      videoPlayerController.value = widget.betterPlayerController;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      analytics!.logEvent(name: 'video_playback_finished', parameters: {
        'video_id': widget.video.id.toString(),
        'viewed_by': authHandler.loggedInUser!.userId!.toString()
      });
    }
  }

  @override
  void initState() {
    Map<String, String> newMap = {};
    List<int> resolutions = [144, 240, 360, 480, 720, 1080, 1440];
    if (widget.video.isEncoded!) {
      var start = 0;
      if (widget.video.maxTranscodedResolution == 0) {
        while (widget.video.videoHeight! >= resolutions[start]) {
          newMap["${resolutions[start]}p"] =
              videoStreamUrl(widget.video.id!, resolutions[start]);
          start += 1;
          if (start >= resolutions.length) {
            break;
          }
        }
      } else {
        while (widget.video.maxTranscodedResolution! > resolutions[start]) {
          newMap["${resolutions[start]}p"] =
              videoStreamUrl(widget.video.id!, resolutions[start]);
          start += 1;
          if (start >= resolutions.length) {
            break;
          }
        }
      }
    }

    var url = originalVideoUrl(widget.video.id!);
    Color color = CupertinoColors.darkBackgroundGray;
    Color textColor = Colors.white;

    if (widget.betterPlayerController == null) {
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
            playerTheme: BetterPlayerTheme.cupertino,
            textColor: CupertinoColors.white,
            muteIcon: Iconsax.volume_mute_outline,
            unMuteIcon: Iconsax.volume_cross_outline,
            progressBarPlayedColor: CupertinoColors.systemYellow,
            progressBarBufferedColor: Colors.grey.shade400),
      );
      widget.betterPlayerController =
          BetterPlayerController(betterPlayerConfiguration);
      bool sourceError = false;

      if (Platform.isIOS) {
        _betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
        );
      } else {
        _betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          (widget.video.isEncoded!)
              ? (newMap.containsKey("360p")
                  ? newMap["360p"]!
                  : newMap.values.first)
              : url,
          resolutions: (widget.video.isEncoded!) ? newMap : null,
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 5000,
            maxBufferMs: 131072,
            bufferForPlaybackMs: 2500,
            bufferForPlaybackAfterRebufferMs: 5000,
          ),
        );
      }

      betterPlayerController!
          .setupDataSource(_betterPlayerDataSource!)
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
        betterPlayerController!.setupDataSource(original);
      });
      if (sourceError) {}
    }
    betterPlayerController!.addEventsListener(onPlayerEvent);
    betterPlayerController!.setControlsEnabled(widget.showControls!);
    globalRepo.add(betterPlayerController);
    videoPlayerController.value = betterPlayerController;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BetterPlayer(controller: betterPlayerController!);
  }
}
