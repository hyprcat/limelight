// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'dart:html';

import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPost video;
  const FullScreenVideoPlayer({super.key, required this.video});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    document.documentElement!.requestFullscreen();
    super.initState();
    var url = videoStreamUrl(widget.video.id);
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    document.exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: LimetimeVideoPlayer(
          controller: _controller,
          video: widget.video,
        ));
  }
}
