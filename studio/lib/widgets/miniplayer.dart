import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MiniPlayer extends StatefulWidget {
  final VideoPost video;
  const MiniPlayer({super.key, required this.video});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    var url = videoStreamUrl(widget.video.id);
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? InkWell(
            onTap: () {},
            onHover: (value) {
              if (value) {
                _controller.play();
                _isPlaying = true;
              } else {
                _controller.pause();
                _isPlaying = false;
              }
              setState(() {});
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _isPlaying || (widget.video.thumbnail == null || widget.video.thumbnail!.isEmpty)
                      ? VideoPlayer(
                          _controller,
                        )
                      : Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                          child: Image.network(
                            videoThumbnailUrl(widget.video.id),
                            fit: BoxFit.cover,
                          ))),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
