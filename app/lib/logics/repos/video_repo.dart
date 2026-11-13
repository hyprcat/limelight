import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video/renderers/small_card_renderer.dart';
import 'package:lime_time_app/screens/video/renderers/thumbnails_renderer.dart';
import 'package:lime_time_app/v1_200/renderers/horizontal_layout.dart';

class VideoRepo {
  int currentPage = 1;
  int lastPage = 1;
  List<VideoPost> videos = [];

  Future<void> removeDuplicates() async {
    final seen = <String>{}; // Set to store seen videoIds
    videos.retainWhere((video) => seen.add(video.id!));
  }

  Widget noVideosFound(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          "Wow, such empty.",
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget renderVideos(BuildContext context,
      {bool? isTabularView,
      ScrollController? controller,
      ScrollPhysics? physics,
      Function? canBuildVideo,
      bool? shouldSetImpression,
      bool? enablePadding = true,
      bool? renderAsGrid = false,
      bool? verticalGrid = false}) {
    removeDuplicates();
    if (videos.isEmpty) {
      return noVideosFound(context);
    }

    return ThumbnailsRenderer(
      data: videos,
      canBuildVideo: canBuildVideo,
      renderAsGrid: renderAsGrid!,
      shouldSetImpression: shouldSetImpression!,
      controller: controller,
      enablePadding: enablePadding!,
      physics: physics,
      verticalGrid: verticalGrid!,
    );
  }

  Widget renderShortVideos(
    BuildContext context, {
    bool? isTabularView,
    ScrollController? controller,
    ScrollPhysics? physics,
    Function? canBuildVideo,
    bool? shouldSetImpression,
    bool? enablePadding = true,
    bool? renderAsGrid = false,
  }) {
    removeDuplicates();
    if (videos.isEmpty) {
      return noVideosFound(context);
    }

    return ShortVideoRenderer(
      data: videos,
      canBuildVideo: canBuildVideo,
      renderAsGrid: renderAsGrid!,
      shouldSetImpression: shouldSetImpression!,
      controller: controller,
      enablePadding: enablePadding!,
      physics: physics,
    );
  }

  Widget buildThumbnailOnlyList(BuildContext context, Function? canBuildVideo,
      {ScrollController? controller,
      ScrollPhysics? physics,
      bool shouldSetImpression = false,
      bool enablePadding = false,
      bool replaceScreen = false,
      bool? renderAsGrid = false,
      bool forMiniPlayer = false}) {
    removeDuplicates();

    if (videos.isEmpty) {
      return noVideosFound(context);
    }

    return ThumbnailsRenderer(
      data: videos,
      canBuildVideo: canBuildVideo,
      shouldSetImpression: shouldSetImpression,
      controller: controller,
      enablePadding: enablePadding,
      replaceScreen: replaceScreen,
      forMiniPlayer: forMiniPlayer,
      renderAsGrid: renderAsGrid!,
      physics: physics,
    );
  }

  Widget buildSmallCard(BuildContext context, Function? canBuildVideo,
      {ScrollController? controller,
      ScrollPhysics? physics,
      bool shouldSetImpression = false}) {
    if (videos.isEmpty) {
      return noVideosFound(context);
    }
    removeDuplicates();
    return SmallCardRenderer(
      data: videos,
      canBuildVideo: canBuildVideo,
      shouldSetImpression: shouldSetImpression,
    );
  }

  List<VideoPost> sortByHeightGreaterThanWidth() {
    return videos
        .where((post) => (post.videoHeight ?? 0) > (post.videoWidth ?? 0))
        .toList();
  }

  List<VideoPost> sortByVideoXp() {
    videos.sort((a, b) => (b.videoXp ?? 0).compareTo(a.videoXp ?? 0));
    return videos;
  }

  List<VideoPost> sortByViews() {
    videos.sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));
    return videos;
  }

  List<VideoPost> sortByImpressions() {
    videos.sort((a, b) => (b.impressions ?? 0).compareTo(a.impressions ?? 0));
    return videos;
  }

  List<VideoPost> sortByDate() {
    videos.sort((a, b) {
      DateTime? dateA =
          a.creationDate != null ? DateTime.tryParse(a.creationDate!) : null;
      DateTime? dateB =
          b.creationDate != null ? DateTime.tryParse(b.creationDate!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });
    return videos;
  }
}
