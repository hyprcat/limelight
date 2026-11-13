import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/videos/playlist.dart';
import 'package:lime_time_app/screens/settings/playlist/playlist_details.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class PlaylistCard extends StatelessWidget {
  final PlayList playList;
  const PlaylistCard({super.key, required this.playList});

  @override
  Widget build(BuildContext context) {
    RichText buildUserRow() {
      return RichText(
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(text: "", children: [
          TextSpan(
              text: "@${playList.createdBy!.userName!}",
              style: defaultSmallXLabelCustom(
                context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.w500,
              )),
          TextSpan(
            text: ' • ${formatTimeAgo(playList.creationDate!)}',
            style: defaultSmallXLabelCustom(context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.w500),
          ),
        ]),
      );
    }

    Widget thumbnail() {
      return SizedBox(
        height: 100,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: NetworkImage(
                            videoThumbnailUrl(playList.firstVideoId!)),
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
                          videoThumbnailUrl(playList.firstVideoId!),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, __, ___) {
                            return Container(
                              decoration: BoxDecoration(
                                  gradient: getGradient(playList.name!)),
                            );
                          },
                        ),
                      ),
                    )),
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.all(5),
                  width: 1200,
                  decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.9)),
                  child: Text(
                    numToEng(playList.videos!) +
                        (playList.videos! > 1 ? " videos" : " video"),
                    style: defaultSmallXLabelCustom(context),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: PlaylistDetails(
            playlist: playList,
            index: 0,
          ),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            thumbnail(),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playList.name!,
                    maxLines: 2,
                    style:
                        defaultLabelText(context, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    playList.description!,
                    maxLines: 2,
                    style: defaultSmallXLabelCustom(
                      context,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildUserRow()
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
