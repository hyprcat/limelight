import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video/reusable_auto_play_list/controller.dart';

class ReusableVideoListWidget extends StatefulWidget {
  final VideoPost? videoListData;
  final ReusableVideoListController? videoListController;
  final Function? canBuildVideo;
  final Function(int index)? onFirstVisibleVideoChange;
  final int index;

  const ReusableVideoListWidget({
    super.key,
    this.videoListData,
    this.videoListController,
    this.canBuildVideo,
    this.onFirstVisibleVideoChange,
    required this.index,
  });

  @override
  _ReusableVideoListWidgetState createState() =>
      _ReusableVideoListWidgetState();
}

class _ReusableVideoListWidgetState extends State<ReusableVideoListWidget> {
  VideoPost? get videoListData => widget.videoListData;
  BetterPlayerController? controller;
  StreamController<BetterPlayerController?>
      betterPlayerControllerStreamController = StreamController.broadcast();
  bool _initialized = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    betterPlayerControllerStreamController.close();
    super.dispose();
  }

  void _setupController() {
    Map<String, String> newMap = {};
    List<int> resolutions = [144, 240, 360, 480, 720, 1080, 1440];
    var url = originalVideoUrl(widget.videoListData!.id!);
    List<int> heights = [256, 426, 640, 854, 1280, 1920, 2560];
    if (widget.videoListData!.isEncoded!) {
      var start = 0;
      if (widget.videoListData!.maxTranscodedResolution == 0) {
        while (widget.videoListData!.videoHeight! >= resolutions[start]) {
          newMap["${resolutions[start]}p"] =
              videoStreamUrl(widget.videoListData!.id!, resolutions[start]);
          start += 1;
          if (start >= resolutions.length) {
            break;
          }
        }
      } else {
        if (widget.videoListData!.videoHeight! >
            widget.videoListData!.videoWidth!) {
          while (widget.videoListData!.maxTranscodedResolution! >=
              resolutions[start]) {
            newMap["${resolutions[start]}p"] =
                videoStreamUrl(widget.videoListData!.id!, resolutions[start]);
            start += 1;
            if (start >= resolutions.length) {
              break;
            }
          }
        } else {
          while (widget.videoListData!.maxTranscodedResolution! >=
              heights[start]) {
            newMap["${resolutions[start]}p"] =
                videoStreamUrl(widget.videoListData!.id!, resolutions[start]);
            start += 1;
            if (start >= resolutions.length) {
              break;
            }
          }
        }
      }
    }
    if (newMap.isEmpty) {
      widget.videoListData!.isEncoded = false;
    }
    if (controller == null) {
      controller = widget.videoListController!.getBetterPlayerController();
      if (controller != null) {
        controller!.setupDataSource(BetterPlayerDataSource.network(
            (widget.videoListData!.isEncoded!)
                ? (newMap.containsKey("360p")
                    ? newMap["360p"]!
                    : newMap.values.first)
                : url,
            videoFormat: (widget.videoListData!.isEncoded!)
                ? BetterPlayerVideoFormat.hls
                : null,
            cacheConfiguration:
                const BetterPlayerCacheConfiguration(useCache: false)));
        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }
        controller!.addEventsListener(onPlayerEvent);
      }
    }
  }

  void _freeController() {
    if (!_initialized) {
      _initialized = true;
      return;
    }
    if (controller != null && _initialized) {
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

  void onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      videoListData!.lastPosition = event.parameters!["progress"] as Duration?;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (videoListData!.lastPosition != null) {
        controller!.seekTo(videoListData!.lastPosition!);
      }
      if (videoListData!.wasPlaying!) {
        controller!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisibilityDetector(
            key: Key(hashCode.toString() + DateTime.now().toString()),
            onVisibilityChanged: (info) {
              if (!widget.canBuildVideo!()) {
                _timer?.cancel();
                _timer = null;
                _timer = Timer(const Duration(milliseconds: 500), () {
                  if (info.visibleFraction >= 0.6) {
                    _setupController();
                  } else {
                    _freeController();
                  }
                });
                return;
              }
              if (info.visibleFraction >= 0.6) {
                _setupController();
              } else {
                _freeController();
              }
            },
            child: StreamBuilder<BetterPlayerController?>(
              stream: betterPlayerControllerStreamController.stream,
              builder: (context, snapshot) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: controller != null
                      ? BetterPlayer(
                          controller: controller!,
                        )
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    if (controller != null) {
      videoListData!.wasPlaying = controller!.isPlaying();
    }
    _initialized = true;
    super.deactivate();
  }
}
