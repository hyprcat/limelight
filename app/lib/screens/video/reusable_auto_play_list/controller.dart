import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReusableVideoListController {
  final List<BetterPlayerController> betterPlayerControllerRegistry = [];
  final List<BetterPlayerController> usedBetterPlayerControllerRegistry = [];
  final Map<String, BetterPlayerController> preloadedVideoControllers = {};

  ReusableVideoListController() {
    for (int index = 0; index < 3; index++) {
      betterPlayerControllerRegistry.add(
        BetterPlayerController(
          const BetterPlayerConfiguration(
              handleLifecycle: false,
              autoDispose: false,
              fit: BoxFit.contain,
              aspectRatio: 9 / 18,
              autoPlay: false,
              looping: true),
        ),
      );
    }
  }

  BetterPlayerController? getBetterPlayerController() {
    final freeController = betterPlayerControllerRegistry.firstWhereOrNull(
        (controller) =>
            !usedBetterPlayerControllerRegistry.contains(controller));

    if (freeController != null) {
      usedBetterPlayerControllerRegistry.add(freeController);
    }

    return freeController;
  }

  void freeBetterPlayerController(
      BetterPlayerController? betterPlayerController) {
    usedBetterPlayerControllerRegistry.remove(betterPlayerController);
    String? keyToRemove = preloadedVideoControllers.entries
        .firstWhereOrNull((entry) => entry.value == betterPlayerController)
        ?.key;

    if (keyToRemove != null) {
      preloadedVideoControllers.remove(keyToRemove);
    }
  }

  void putBackController(BetterPlayerController betterPlayerController) {
    final index = betterPlayerControllerRegistry.indexWhere((controller) =>
        usedBetterPlayerControllerRegistry.contains(controller));

    if (index != null) {
      betterPlayerControllerRegistry[index] = betterPlayerController;
      usedBetterPlayerControllerRegistry.remove(betterPlayerController);
    }
  }

  void dispose() {
    for (var controller in betterPlayerControllerRegistry) {
      controller.dispose();
    }
  }
}
