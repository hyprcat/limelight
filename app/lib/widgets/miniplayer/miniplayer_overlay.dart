// ignore_for_file: must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:lime_time_app/widgets/miniplayer/miniplayer.dart';
import 'package:lime_time_app/widgets/video_players/better_player_widget.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:text_scroll/text_scroll.dart';

class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> {
  Color color = Colors.grey.shade700;
  Color textColor = generateTextColor(Colors.grey.shade700);

  Future<PaletteGenerator> _updatePaletteGenerator(VideoPost video) async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image(
        image: ResizeImage(
          CachedNetworkImageProvider(videoThumbnailUrl(video.id!)),
          width: 10,
          height: 10,
        ),
      ).image,
    );
    setState(() {
      color = paletteGenerator.dominantColor?.color ?? Colors.grey;
      textColor = generateTextColor(color);
    });
    return paletteGenerator;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildMiniPlayerContent(
      BuildContext context, VideoPost video, double percentage) {
    Widget expandedBody = ValueListenableBuilder<BetterPlayerController?>(
      valueListenable: videoPlayerController,
      builder: (context, value, child) {
        if (value == null) return Container();
        return BetterPlayerWidget(
          video: video,
          betterPlayerController: value,
          showControls: false,
          updateWhileProgress: true,
        );
      },
    );

    if (percentage > 0.4) {
      return Material(
        child: ExpandedVideo(
          video: video,
          forMiniPlayer: true,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: expandedBody,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextScroll(video.title!, textColor, true),
                      buildTextScroll(video.videoCreator!.userChannel!.name!,
                          textColor, false),
                    ],
                  ),
                ),
              ),
              buildControlButtons(context),
            ],
          ),
        ),
      );
    }
  }

  Widget buildTextScroll(String text, Color textColor, bool isTitle) {
    return TextScroll(
      text,
      style: isTitle
          ? defaultLabelTextC(context,
              fontColor: textColor, fontWeight: FontWeight.bold)
          : defaultSmallXLabelCustom(context,
              fontColor: textColor.withOpacity(0.6),
              fontWeight: FontWeight.w500),
      velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
      mode: TextScrollMode.endless,
      intervalSpaces: 5,
    );
  }

  Widget buildControlButtons(BuildContext context) {
    return ValueListenableBuilder<BetterPlayerController?>(
      valueListenable: videoPlayerController,
      builder: (context, value, child) {
        if (value == null) return Container();
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(),
              child: IconButton(
                onPressed: () {
                  if (value.isPlaying()!) {
                    value.pause();
                  } else {
                    value.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  value.isPlaying()! ? BoxIcons.bx_pause : BoxIcons.bx_play,
                  size: 46,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: IconButton(
                onPressed: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.selectionClick();

                  listController.freeAllControllers();
                  videoListener.value = null;

                  if (videoPlayerController.value != null) {
                    videoPlayerController.value!.dispose(forceDispose: true);
                    videoPlayerController.value = null;
                  }
                  invalidateAllControllers();
                  if (playerWidget.value != null) {
                    playerWidget.value = null;
                  }
                  miniplayerController.animateToHeight(
                      state: PanelState.DISMISS);
                },
                icon: Icon(
                  Icons.close,
                  size: 36,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<VideoPost?>(
          valueListenable: videoListener,
          builder: (context, video, _) {
            if (video == null) return Container();

            return ValueListenableBuilder<bool?>(
              valueListenable: isExpanded,
              builder: (context, showNavigationBar, child) {
                Widget miniPlayer = Container(
                  margin: EdgeInsets.only(
                    bottom:
                        !showNavigationBar! ? 0 : (Platform.isIOS ? 90 : 55),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    child: Miniplayer(
                      minHeight: 70,
                      duration: const Duration(milliseconds: 200),
                      onDismissed: () {
                        setState(() {
                          videoListener.value = null;
                          videoPlayerController.value
                              ?.dispose(forceDispose: true);
                          videoPlayerController.value = null;
                          invalidateAllControllers();
                          playerWidget.value = null;
                        });
                      },
                      controller: miniplayerController,
                      maxHeight: MediaQuery.of(context).size.height,
                      builder: (height, percentage) {
                        return buildMiniPlayerContent(
                            context, video, percentage);
                      },
                    ),
                  ),
                );
                return FutureBuilder<PaletteGenerator>(
                  future: _updatePaletteGenerator(video),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return miniPlayer;
                      default:
                        return miniPlayer;
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class VideoScrubber extends StatefulWidget {
  VideoScrubber(
      {required this.playerValue,
      required this.controller,
      required this.callback,
      super.key});
  final VideoPlayerValue playerValue;
  final BetterPlayerController controller;
  Function? callback;

  @override
  VideoScrubberState createState() => VideoScrubberState();
}

class VideoScrubberState extends State<VideoScrubber> {
  double _value = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    int position = oldWidget.playerValue.position.inSeconds;
    int duration = oldWidget.playerValue.duration?.inSeconds ?? 0;
    setState(() {
      _value = position / duration;
    });
    widget.callback!();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          thumbShape: CustomThumbShape(), // Custom thumb shape
          overlayShape: SliderComponentShape.noOverlay),
      child: Slider(
        value: _value,
        inactiveColor: Colors.grey,
        min: 0.0,
        max: 1.0,
        onChanged: (newValue) {
          setState(() {
            _value = newValue;
          });
          final newProgress = Duration(
              milliseconds: (_value *
                      widget.controller.videoPlayerController!.value.duration!
                          .inMilliseconds)
                  .toInt());
          widget.controller.seekTo(newProgress);
        },
      ),
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius = 6.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
  }
}
