import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/v1_200/renderers/horizontal_layout.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class PostRenderer extends StatefulWidget {
  final List<Post> data;
  final Function deleteCallback;
  final bool enablePadding;
  final bool forLoungeHome;
  final bool renderAsGrid;
  const PostRenderer(
      {super.key,
      required this.data,
      required this.deleteCallback,
      this.enablePadding = true,
      this.forLoungeHome = false,
      this.renderAsGrid = false});

  @override
  State<PostRenderer> createState() => _PostRendererState();
}

class _PostRendererState extends State<PostRenderer> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          if (widget.renderAsGrid) {
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: widget.enablePadding ? null : EdgeInsets.zero,
              controller: controller,
              physics: physics,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              shrinkWrap: true,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                Post post = widget.data[index];
                return Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).dividerColor, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: PostWidget(
                    post: post,
                    deleteCallbackPost: widget.deleteCallback,
                    baseComments: const [],
                    isThreadable: true,
                    withoutDp: true,
                    showTail: false,
                    isFirst: true,
                    forLoungeHome: true,
                  ),
                );
              },
            );
            return ScrollConfiguration(
                behavior: AppScrollBehavior(),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  itemCount: widget.data.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 3.0,
                      crossAxisCount: 1,
                      childAspectRatio: 2.5),
                  itemBuilder: (context, index) {
                    Post post = widget.data[index];
                    return Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: PostWidget(
                        post: post,
                        deleteCallbackPost: widget.deleteCallback,
                        baseComments: const [],
                        isThreadable: true,
                        withoutDp: true,
                        showTail: false,
                        isFirst: true,
                        forLoungeHome: true,
                      ),
                    );
                  },
                ));

            return LayoutBuilder(
              builder: (context, constraints) {
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  scrollDirection: Axis.horizontal,
                  padding: widget.enablePadding ? null : EdgeInsets.zero,
                  controller: controller,
                  physics: physics,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  shrinkWrap: true,
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    Post post = widget.data[index];
                    return Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: PostWidget(
                        post: post,
                        deleteCallbackPost: widget.deleteCallback,
                        baseComments: const [],
                        isThreadable: true,
                        withoutDp: true,
                        showTail: false,
                        isFirst: true,
                        forLoungeHome: true,
                      ),
                    );
                  },
                );
              },
            );
          }

          return ListView.builder(
              controller: controller,
              physics: physics,
              padding: widget.enablePadding ? null : EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                Post post = widget.data[index];
                return PostWidget(
                  post: post,
                  baseComments: [post],
                  forLoungeHome: widget.forLoungeHome,
                  deleteCallbackPost: widget.deleteCallback,
                  isThreadable: true,
                  showTail: false,
                  isFirst: true,
                );
              });
        });
  }
}
