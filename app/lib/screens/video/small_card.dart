// ignore_for_file: no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video_player/expanded_video.dart';
import 'package:palette_generator/palette_generator.dart';

class SmallCard extends StatefulWidget {
  final VideoPost video;
  bool? inLine;
  final Function? canBuildVideo;
  bool? shouldSetImpression;
  SmallCard(
      {super.key,
      required this.video,
      required this.canBuildVideo,
      this.shouldSetImpression = false,
      this.inLine = false});

  @override
  State<SmallCard> createState() => _SmallCardState();
}

class _SmallCardState extends State<SmallCard> {
  @override
  void initState() {
    if (widget.shouldSetImpression!) {
      VideoEngine().setImpression({
        'video_id': widget.video.id,
      });
    }
    super.initState();
  }

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

  RichText _buildUserRow() {
    return RichText(
      softWrap: true,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(text: "", children: [
        TextSpan(
            text: widget.video.videoCreator!.userChannel!.name!,
            style: defaultSmallXLabelCustom(
              context,
              fontColor: (widget.inLine!)
                  ? textColor.withOpacity(0.7)
                  : Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            )),
        TextSpan(
          text:
              ' • ${!widget.video.isActive! ? 'DRAFT' : "${numToEng(widget.video.videoXp!)} Points"}',
          style: defaultSmallXLabelCustom(context,
              fontColor: (widget.inLine!)
                  ? textColor.withOpacity(0.7)
                  : Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: ' • ${formatTimeAgo(widget.video.creationDate!)}',
          style: defaultSmallXLabelCustom(context,
              fontColor: (widget.inLine!)
                  ? textColor.withOpacity(0.7)
                  : Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.inLine!)
          SizedBox(
            height: 80,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image:
                            NetworkImage(videoThumbnailUrl(widget.video.id!)),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2.0,
                        sigmaY: 2.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                        ),
                        width: double.infinity,
                        child: Image.network(
                          videoThumbnailUrl(widget.video.id!),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, __, ___) {
                            return Container(
                              color: Theme.of(context).dividerColor,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Center(
                                child: Text(
                                  widget.video.title!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: defaultHeadingXText(context,
                                      fontColor: Theme.of(context)
                                          .hintColor
                                          .withOpacity(0.2),
                                      fontsize: 50),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )),
              ),
            ),
          ),
        if (!widget.inLine!)
          const SizedBox(
            width: 10,
          ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.video.title!,
                    style: defaultLabelTextForPost(
                      context,
                      fontWeight: FontWeight.w700,
                      fontColor: (widget.inLine!) ? textColor : null,
                    )),
                const SizedBox(
                  height: 5,
                ),
                _buildUserRow()
              ],
            ),
          ),
        ),
      ],
    );

    Widget body() {
      return InkWell(
        onTap: () {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          analytics!
              .logEvent(name: 'video_clicked', parameters: <String, Object>{
            'video_id': widget.video.id.toString(),
            'clicked_by': authHandler.loggedInUser!.userId!.toString()
          });

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

          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ExpandedVideo(
                    video: widget.video,
                    canBuildVideo: checkCanBuildVideo,
                    forMiniPlayer: false,
                    key: ValueKey<int>(Random().nextInt(10000)),
                  )));
        },
        child: Container(
            decoration: BoxDecoration(
              color: (widget.inLine!) ? color : null,
              borderRadius: (widget.inLine!) ? BorderRadius.circular(5) : null,
            ),
            margin: (!widget.inLine!)
                ? const EdgeInsets.only(left: 10, right: 10, bottom: 10)
                : null,
            padding: (widget.inLine!) ? const EdgeInsets.all(10) : null,
            child: child),
      );
    }

    return FutureBuilder<PaletteGenerator>(
      future: _updatePaletteGenerator(widget.video),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return body();
          default:
            return body();
        }
      },
    );
  }
}
