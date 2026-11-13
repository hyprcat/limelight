// ignore_for_file: depend_on_referenced_packages

import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class RenderController {
  int maxControllers = 3;
  final List<BetterPlayerController> _betterPlayerControllerRegistry = [];
  List<BetterPlayerController> _usedBetterPlayerControllerRegistry = [];

  void makeControllers() {
    for (int index = 0; index < maxControllers; index++) {
      var controller = BetterPlayerController(
        BetterPlayerConfiguration(
          handleLifecycle: false,
          autoDispose: false,
          autoPlay: true,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
          controlsConfiguration: BetterPlayerControlsConfiguration(
              enableFullscreen: false,
              enableAudioTracks: false,
              enableOverflowMenu: false,
              enableProgressText: false,
              enableQualities: false,
              enableSubtitles: false,
              enablePlaybackSpeed: false,
              enablePlayPause: false,
              enableMute: false,
              enableSkips: false,
              enablePip: false,
              enableRetry: false,
              enableProgressBar: true,
              enableProgressBarDrag: true,
              showControls: false,
              playerTheme: BetterPlayerTheme.material,
              playIcon: Iconsax.play_outline,
              pauseIcon: Iconsax.pause_outline,
              textColor: CupertinoColors.white,
              iconsColor: CupertinoColors.systemYellow,
              muteIcon: Iconsax.volume_mute_outline,
              unMuteIcon: Iconsax.volume_cross_outline,
              progressBarPlayedColor: CupertinoColors.systemYellow,
              progressBarBufferedColor: Colors.grey.shade400),
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          showPlaceholderUntilPlay: true,
          placeholderOnTop: true,
        ),
      );
      _betterPlayerControllerRegistry.add(controller);
    }
  }

  RenderController() {
    makeControllers();
  }

  BetterPlayerController? getBetterPlayerController() {
    final freeController = _betterPlayerControllerRegistry.firstWhereOrNull(
        (controller) =>
            !_usedBetterPlayerControllerRegistry.contains(controller));

    if (freeController != null) {
      _usedBetterPlayerControllerRegistry.add(freeController);
    }

    return freeController;
  }

  void freeBetterPlayerController(
      BetterPlayerController? betterPlayerController) {
    _usedBetterPlayerControllerRegistry.remove(betterPlayerController);
  }

  void dispose() {
    for (var controller in _betterPlayerControllerRegistry) {
      controller.dispose();
    }
  }

  void freeAllControllers() {
    _usedBetterPlayerControllerRegistry = [];
  }
}
