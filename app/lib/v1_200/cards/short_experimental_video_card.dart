// ignore_for_file: must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/video/reusable_auto_play_list/controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BetterPlayerWidgetExperimental extends StatefulWidget {
  final VideoPost video;
  final ReusableVideoListController? videoListController;
  final Function? canBuildVideo;
  final List<VideoPost> repoData;
  final int index;

  const BetterPlayerWidgetExperimental({
    super.key,
    required this.video,
    required this.index,
    required this.repoData,
    this.videoListController,
    this.canBuildVideo,
  });

  @override
  State<BetterPlayerWidgetExperimental> createState() =>
      _BetterPlayerWidgetExperimentalState();
}

class _BetterPlayerWidgetExperimentalState
    extends State<BetterPlayerWidgetExperimental>
    with AutomaticKeepAliveClientMixin {
  BetterPlayerController? controller;
  BetterPlayerDataSource? _betterPlayerDataSource;
  StreamController<BetterPlayerController?>
      betterPlayerControllerStreamController = StreamController.broadcast();
  bool _initialized = false;
  Timer? _timer;

  @override
  bool get wantKeepAlive => false;

  @override
  void dispose() {
    controller?.dispose(forceDispose: true);
    super.dispose();
  }

  void _setupController() {
    if (controller == null) {
      prevIVideoIndex = currentVideoIndex;
      currentVideoIndex = widget.index;

      controller = widget.videoListController!.getBetterPlayerController();
      if (controller != null) {
        _betterPlayerDataSource = _getBetterPlayerDataSource(widget.video);
        _initializeController(controller, _betterPlayerDataSource!,
            useStream: true);
        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }
        _addEventListeners(controller);
      }
    }
  }

  BetterPlayerDataSource _getBetterPlayerDataSource(VideoPost video) {
    String url = originalVideoUrl(video.id!);
    Map<String, String> resolutionsMap = _getResolutionsMap(video);

    if (Platform.isIOS) {
      return BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        originalVideoUrl(widget.video.id!),
      );
    }
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Platform.isIOS ? url : _getVideoSource(video, resolutionsMap),
      resolutions: Platform.isIOS ? null : resolutionsMap,
      cacheConfiguration:
          BetterPlayerCacheConfiguration(useCache: true, key: video.id),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 13172,
        bufferForPlaybackMs: 1500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
    );
  }

  Map<String, String> _getResolutionsMap(VideoPost video) {
    List<int> resolutions = [144, 240, 360, 480, 720, 1080, 1440];
    Map<String, String> newMap = {};

    if (video.isEncoded!) {
      int start = 0;
      while (_shouldAddResolution(start, resolutions)) {
        newMap["${resolutions[start]}p"] =
            videoStreamUrl(video.id!, resolutions[start]);
        start++;
        if (start >= resolutions.length) {
          break;
        }
      }
    }

    return newMap;
  }

  bool _shouldAddResolution(int start, List<int> resolutions) {
    return widget.video.maxTranscodedResolution == 0
        ? widget.video.videoHeight! >= resolutions[start]
        : widget.video.maxTranscodedResolution! > resolutions[start];
  }

  String _getVideoSource(VideoPost video, Map<String, String> resolutionsMap) {
    String originalUrl = originalVideoUrl(video.id!);
    if (resolutionsMap.isEmpty) {
      return originalUrl;
    }
    return widget.video.isEncoded!
        ? (resolutionsMap.containsKey("480p")
            ? resolutionsMap["480p"]!
            : resolutionsMap.values.first)
        : originalUrl;
  }

  void _initializeController(BetterPlayerController? localController,
      BetterPlayerDataSource dataSource,
      {bool useStream = true}) {
    localController!.setupDataSource(dataSource).then((response) {
      if (useStream) {
        betterPlayerControllerStreamController.add(localController);
      }
    }).catchError((error) {
      localController.setupDataSource(BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        originalVideoUrl(widget.video.id!),
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: true),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 1600,
          maxBufferMs: 13172,
          bufferForPlaybackMs: 1500,
          bufferForPlaybackAfterRebufferMs: 2500,
        ),
      ));
    });
  }

  void invokePreviousVideoCleanUp() {
    if (widget.videoListController!.usedBetterPlayerControllerRegistry.length ==
        widget.videoListController!.betterPlayerControllerRegistry.length) {
      BetterPlayerController x =
          widget.videoListController!.usedBetterPlayerControllerRegistry.first;
      BetterPlayerController y =
          widget.videoListController!.usedBetterPlayerControllerRegistry.last;

      if (currentVideoIndex > prevIVideoIndex) {
        widget.videoListController!.freeBetterPlayerController(x);
      } else {
        widget.videoListController!.freeBetterPlayerController(y);
      }
    }
  }

  void invokePreloadNextVideo(BetterPlayerController freeController) {
    int nextVideoIndex = widget.index + 1;

    if (nextVideoIndex < widget.repoData.length) {
      VideoPost nextVideo = widget.repoData[nextVideoIndex];

      BetterPlayerDataSource nextDataSource =
          _getBetterPlayerDataSource(nextVideo);

      _initializeController(freeController, nextDataSource, useStream: false);
      _addEventListeners(freeController);
      widget.videoListController!.putBackController(freeController);
      widget.videoListController!.preloadedVideoControllers[nextVideo.id!] =
          freeController;
    } else {}
  }

  void invokePreLoad() {
    BetterPlayerController? freeController =
        widget.videoListController!.getBetterPlayerController();

    if (freeController == null) {
      invokePreviousVideoCleanUp();
      freeController = widget.videoListController!.getBetterPlayerController();
    }

    if (freeController != null) {
      invokePreloadNextVideo(freeController);
    }
  }

  void _freeController() {
    if (controller != null) {
      controller!.removeEventsListener(onPlayerEvent);
      widget.videoListController!.freeBetterPlayerController(controller);
      controller!.pause();
      controller = null;
      if (!betterPlayerControllerStreamController.isClosed) {
        betterPlayerControllerStreamController.add(null);
      }
      _initialized = false;
    }
  }

  void _addEventListeners(BetterPlayerController? localController) {
    localController!.addEventsListener(onPlayerEvent);
    localController.setControlsEnabled(false);
  }

  void onPlayerEvent(BetterPlayerEvent event) async {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _handleInitializedEvent();
        break;
      case BetterPlayerEventType.progress:
        _handleProgressEvent(event);
        break;
      case BetterPlayerEventType.finished:
        _handleFinishedEvent();
        break;
      default:
        break;
    }
  }

  void _handleInitializedEvent() {
    if (widget.video.lastPosition != null) {
      controller!.seekTo(widget.video.lastPosition!);
    }
    if (widget.video.wasPlaying!) {
      controller!.play();
    }
    analytics!.logEvent(name: 'video_playback_started', parameters: {
      'video_id': widget.video.id.toString(),
      'viewed_by': authHandler.loggedInUser!.userId!.toString()
    });
  }

  void _handleProgressEvent(BetterPlayerEvent event) {
    var progress = event.parameters!["progress"] as Duration?;
    if (progress != null) {
      VideoEngine().setView({
        'video_id': widget.video.id,
        'view_time_seconds': progress.inSeconds,
      });
      analytics!.logEvent(name: 'view_set', parameters: {
        'video_id': widget.video.id.toString(),
        'viewed_by': authHandler.loggedInUser!.userId!.toString()
      });
      WakelockPlus.enable();
    }
  }

  void _handleFinishedEvent() {
    analytics!.logEvent(name: 'video_playback_finished', parameters: {
      'video_id': widget.video.id.toString(),
      'viewed_by': authHandler.loggedInUser!.userId!.toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: Key(
          hashCode.toString() + DateTime.now().toString() + widget.video.id!),
      onVisibilityChanged: (info) {
        if (!widget.canBuildVideo!()) {
          _timer?.cancel();
          _timer = null;
          _timer = Timer(const Duration(milliseconds: 500), () {
            if (info.visibleFraction >= 0.01) {
              _setupController();
            } else {
              _freeController();
            }
          });
          return;
        }
        if (info.visibleFraction >= 0.01) {
          _setupController();
        } else {
          _freeController();
        }
      },
      child: GestureDetector(
        onTap: () {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          if (controller!.isPlaying()!) {
            controller!.pause();
          } else {
            controller!.play();
          }
        },
        child: _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    return StreamBuilder<BetterPlayerController?>(
        stream: betterPlayerControllerStreamController.stream,
        builder: (context, snapshot) {
          return Container(
              child: controller != null
                  ? VisibilityDetector(
                      key: Key("$hashCode${DateTime.now()}"),
                      onVisibilityChanged: (info) {
                        if (controller != null) {
                          if (info.visibleFraction >= 0.6) {
                            controller!.play();
                          } else {
                            controller!.pause();
                          }
                        }
                      },
                      child: BetterPlayer(controller: controller!),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ));
        });
  }
}
