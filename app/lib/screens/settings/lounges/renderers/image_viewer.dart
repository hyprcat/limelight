import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';

import 'package:lime_time_app/defaults/utils.dart';

class PostImageViewer extends StatefulWidget {
  final Post post;
  const PostImageViewer({super.key, required this.post});

  @override
  State<PostImageViewer> createState() => _PostImageViewerState();
}

class _PostImageViewerState extends State<PostImageViewer> {
  bool onHold = false;

  @override
  Widget build(BuildContext context) {
    Widget userRow() {
      return InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen:
                UserChannel(user: widget.post.createdBy!.member, asList: false),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(
                        text: widget.post.createdBy!.member!.userChannel!.name!,
                        style: defaultLabelText(context,
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text:
                                  " ${widget.post.createdBy!.member!.userName!} ",
                              style: defaultSmallLabel(context,
                                  fontColor:
                                      Theme.of(context).colorScheme.primary))
                        ]),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Level ${widget.post.createdBy!.level!}",
                            style: defaultSmallLabel(context,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(formatTimeAgo(widget.post.creationDate!),
                          style: defaultSmallLabel(context,
                              fontColor: Theme.of(context).hintColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget postText({bool? isBig = false}) {
      return ReadMoreText(
        widget.post.text!,
        trimMode: TrimMode.Line,
        trimLines: 4,
        colorClickableText: Colors.pink,
        trimCollapsedText: '\nShow more',
        trimExpandedText: '\nShow less',
        style: isBig!
            ? defaultNormalText(context,
                fontColor:
                    theme == ThemeMode.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500)
            : defaultLabelTextForPost(context,
                fontColor:
                    theme == ThemeMode.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500),
        moreStyle: defaultSmallLabel(context,
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary),
        lessStyle: defaultSmallLabel(context,
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary),
      );
    }

    Widget metricRow() {
      return Row(
        children: [
          TextMetric(
            label: 'Replies',
            value: numToEng(widget.post.replies!),
            reverse: true,
            labelColor: Theme.of(context).hintColor,
            valueColor: Theme.of(context).hintColor,
          ),
          const SizedBox(
            width: 10,
          ),
          TextMetric(
            label: 'Impressions',
            value: numToEng(widget.post.impressions!),
            reverse: true,
            labelColor: Theme.of(context).hintColor,
            valueColor: Theme.of(context).hintColor,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
        titleSpacing: 0,
        title: Text(
          "From ${widget.post.createdBy!.member!.userName}'s post",
          style: defaultLabelText(context,
              fontWeight: FontWeight.bold,
              fontColor: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: GestureDetector(
        onTapDown: (_) {
          setState(() {
            onHold = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            onHold = false;
          });
        },
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: loungePostMediaUrl(widget.post.id!),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            if (!onHold)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black12,
                      Colors.black,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserProfilePicture(
                              radius: 18,
                              asSquare: true,
                              userObj: widget.post.createdBy!.member!,
                              doNothing: true,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  userRow(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        postText(),
                        const SizedBox(
                          height: 10,
                        ),
                        metricRow()
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
