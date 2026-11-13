import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/widgets/miniplayer.dart';
import 'package:code_arrow_creator_studio/widgets/user_profile_picture.dart';

import 'package:flutter/material.dart';

class VideoCard extends StatefulWidget {
  final VideoPost video;
  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: Column(
        children: [
          Container(
              width: 320,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  MiniPlayer(video: widget.video),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        UserProfilePicture(radius: 20, userObj: widget.video.videoCreator!),
                        Flexible(
                          child:
                              Container(margin: const EdgeInsets.only(left: 5), child: Text(widget.video.title!, style: defaultLabelText(context))),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
