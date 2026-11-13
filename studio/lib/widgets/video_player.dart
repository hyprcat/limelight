// ignore_for_file: must_be_immutable

import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/widgets/full_screen_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LimetimeVideoPlayer extends StatefulWidget {
  final VideoPost video;
  VideoPlayerController? controller;
  LimetimeVideoPlayer({super.key, required this.video, this.controller});

  @override
  State<LimetimeVideoPlayer> createState() => _LimetimeVideoPlayerState();
}

class _LimetimeVideoPlayerState extends State<LimetimeVideoPlayer> {
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

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 10,
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                              backgroundColor: Theme.of(context).canvasColor,
                              bufferedColor: Theme.of(context).focusColor,
                              playedColor: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                });

                                _controller.value.position.inSeconds;
                              },
                              icon: CircleAvatar(
                                  backgroundColor: Theme.of(context).canvasColor,
                                  child: Icon(
                                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  ))),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
                                });

                                _controller.value.position.inSeconds;
                              },
                              icon: CircleAvatar(backgroundColor: Theme.of(context).canvasColor, child: const Icon(Icons.fast_forward))),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) => FullScreenVideoPlayer(video: widget.video),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              icon: CircleAvatar(backgroundColor: Theme.of(context).canvasColor, child: const Icon(Icons.fullscreen)))
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
