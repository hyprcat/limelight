// ignore_for_file: no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/v1_200/renderers/short_video_view_renderer.dart';

import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/defaults/fonts.dart';

class ShortVideoCard extends StatefulWidget {
  final VideoPost video;
  final int indexInList;
  final List<VideoPost> actualList;

  const ShortVideoCard({
    super.key,
    required this.video,
    required this.actualList,
    required this.indexInList,
  });

  @override
  State<ShortVideoCard> createState() => _ShortVideoCardState();
}

class _ShortVideoCardState extends State<ShortVideoCard> {
  @override
  void initState() {
    VideoEngine().setImpression({
      'video_id': widget.video.id,
    });

    super.initState();
  }

  Color color = Colors.grey.shade700;
  Color textColor = generateTextColor(Colors.grey.shade700);

  Future<PaletteGenerator> isolate(int value) async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image(
        image: ResizeImage(
          CachedNetworkImageProvider(videoThumbnailUrl(widget.video.id!)),
          width: 10,
          height: 10,
        ),
      ).image,
    );
    return paletteGenerator;
  }

  Future<PaletteGenerator> _updatePaletteGenerator() async {
    final paletteGenerator = await compute(isolate, 1000000000);
    setState(() {
      color = paletteGenerator.dominantColor?.color ?? Colors.grey;
      textColor = generateTextColor(color);
    });
    return paletteGenerator;
  }

  @override
  Widget build(BuildContext context) {
    RichText _buildMetricRow() {
      return RichText(
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(text: "", children: [
          TextSpan(
            text: formatTimeAgo(widget.video.creationDate!),
            style: defaultEvenVerySmallLabelAlternate(context,
                fontColor: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500),
          ),
        ]),
      );
    }

    Widget body() {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [Colors.transparent, color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              blendMode: BlendMode.hardLight,
              child: CachedNetworkImage(
                cacheKey: widget.video.id! + DateTime.now().hour.toString(),
                imageUrl: videoThumbnailUrl(widget.video.id!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorWidget: (context, __, ___) {
                  return Container(
                    color: Theme.of(context).dividerColor,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: Text(
                        widget.video.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: defaultHeadingXText(context,
                            fontColor: color, fontsize: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: defaultSmallLabel(context,
                      fontColor: textColor, fontWeight: FontWeight.bold),
                ),
                _buildMetricRow()
              ],
            ),
          )
        ],
      );
    }

    return InkWell(
        onTap: () {
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

          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ShortVideoViewRenderer(
              index: widget.indexInList,
              followUp: widget.actualList,
            ),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: FutureBuilder<PaletteGenerator>(
          future: _updatePaletteGenerator(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return body();
              default:
                return body();
            }
          },
        ));
  }
}
