import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/colors.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/v1_200/cards/post_experiment.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class PostRendererExperimental extends StatefulWidget {
  final List<Post> data;
  final Function deleteCallback;
  final bool enablePadding;
  final bool forLoungeHome;
  final bool renderAsGrid;
  const PostRendererExperimental(
      {super.key,
      required this.data,
      required this.deleteCallback,
      this.enablePadding = true,
      this.forLoungeHome = false,
      this.renderAsGrid = false});

  @override
  State<PostRendererExperimental> createState() =>
      _PostRendererExperimentalState();
}

class _PostRendererExperimentalState extends State<PostRendererExperimental> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          return ListView.builder(
              controller: controller,
              physics: physics,
              padding: widget.enablePadding ? null : EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                Post post = widget.data[index];
                Color widgetColor =
                    colorsForPosts[Random().nextInt(colorsForPosts.length)];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: widgetColor,
                        border: Border.all(
                            color: Theme.of(context).dividerColor, width: 0.5),
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PostWidgetExperimental(
                        post: post,
                        textColor: generateTextColor(widgetColor),
                        baseComments: [post],
                        forLoungeHome: widget.forLoungeHome,
                        deleteCallbackPost: widget.deleteCallback,
                        isThreadable: true,
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
