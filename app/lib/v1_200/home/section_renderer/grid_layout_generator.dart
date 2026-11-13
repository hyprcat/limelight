import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/repos/home/home_category_repo.dart';
import 'package:lime_time_app/v1_200/cards/full_size_banner_card.dart';
import 'package:lime_time_app/v1_200/cards/half_size_banner.dart';

class SectionGenerator extends StatefulWidget {
  final HomeCategoryRepo section;
  const SectionGenerator({super.key, required this.section});

  @override
  State<SectionGenerator> createState() => _SectionGeneratorState();
}

class _SectionGeneratorState extends State<SectionGenerator>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    if (widget.section.type == 'full_size_banner') {
      return FullSizeBannerCard(banner: widget.section.banner);
    }

    if (widget.section.type == 'half_size_banner') {
      return HalfSizeBanner(
        banner: widget.section.smallBanner,
      );
    }

    if (widget.section.userData!.profiles.isEmpty &&
        widget.section.videoData!.videos.isEmpty &&
        widget.section.postRepo.posts.isEmpty &&
        widget.section.commentRepo.data.isEmpty) {
      return Container();
    }

    double buildHeight() {
      if (widget.section.label == "stars") {
        return MediaQuery.of(context).size.width / 2.3;
      }
      if (widget.section.type == "videos_short") {
        return 300;
      }

      if (widget.section.type == "user_type_2") {
        return 300;
      }
      if (widget.section.type == 'videos' &&
          widget.section.videoData!.videos.length < 4) {
        return 240;
      }
      return 500;
    }

    if (widget.section.type == 'lounge_threads' ||
        widget.section.type == 'lounge_threads_full') {
      return Container();
    }

    if (widget.section.type == 'video_threads') {
      return Container();
    }

    if (widget.section.type == "videos_short" ||
        (widget.section.type == 'lounge_threads' ||
            widget.section.type == 'lounge_threads_full' ||
            widget.section.type == 'videos')) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.section.title!,
            style: defaultHeadingText(context,
                fontWeight: FontWeight.bold, fontsize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: buildHeight(),
            child: Builder(builder: (context) {
              if (widget.section.type == 'users') {
                return widget.section.userData!.renderProfiles(context,
                    renderAsGrid: true, alternateGrid: false);
              } else if (widget.section.type == "videos_short") {
                return Container();
              } else if (widget.section.type == 'videos') {
                return widget.section.videoData!.renderVideos(context,
                    renderAsGrid: true, shouldSetImpression: true);
              }

              if (widget.section.type == 'user_type_2') {
                return widget.section.userData!.renderProfiles(context,
                    forLounge: true, renderAsGrid: true, alternateGrid: true);
              }

              if (widget.section.type == 'lounge_threads' ||
                  widget.section.type == 'lounge_threads_full') {
                return widget.section.postRepo.buildPosts(
                  context,
                  () {},
                );
              }

              return Container();
            }),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
