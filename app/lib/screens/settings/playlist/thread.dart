import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';

import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';

import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';

class Thread extends StatefulWidget {
  const Thread({super.key});

  @override
  State<Thread> createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget searchUserField(VideoCommentRepo? repo) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: false,
          maxLength: 400,
          controller: commentController,
          style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
          maxLines: null,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: repo != null ? "Add a reply" : "Create a post.",
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
            prefixIcon: const Icon(Icons.attach_file),
            suffixIcon: InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(5),
                child: _backgroundWrapper([
                  Text(
                    "Post",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Iconsax.send_1_bold,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomTextField() {
    return ValueListenableBuilder<VideoCommentRepo?>(
        valueListenable: buildReplies,
        builder: (context, VideoCommentRepo? value, _) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).canvasColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            UserProfilePicture(
                                radius: 25, userObj: authHandler.loggedInUser!),
                            Expanded(child: searchUserField(value)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Text(
          "Thread",
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfilePicture(
                        radius: 20, userObj: authHandler.loggedInUser!),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(authHandler.loggedInUser!.userName!,
                                style: defaultVerySmallLabel(context,
                                    fontWeight: FontWeight.bold,
                                    fontColor: Theme.of(context).hintColor)),
                            const SizedBox(
                              width: 10,
                            ),
                            TextMetric(
                              value: numToEng(authHandler
                                  .loggedInUser!.userChannel!.level!),
                              label: 'Level',
                              compact: true,
                              reverse: true,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "This is how a lounge post looks like.",
                          style: defaultSmallLabel(context),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            IconLabelButton(
                              icon: Iconsax.heart_outline,
                              label: "0",
                              isBig: true,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.heart_slash_outline,
                                label: "0",
                                isBig: true),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.message_outline,
                                label: "2",
                                isBig: true),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.only(left: 60, right: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfilePicture(
                        radius: 20, userObj: authHandler.loggedInUser!),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(authHandler.loggedInUser!.userName!,
                                style: defaultVerySmallLabel(context,
                                    fontWeight: FontWeight.bold,
                                    fontColor: Theme.of(context).hintColor)),
                            const SizedBox(
                              width: 10,
                            ),
                            TextMetric(
                              value: numToEng(authHandler
                                  .loggedInUser!.userChannel!.level!),
                              label: 'Level',
                              compact: true,
                              reverse: true,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Example of a thread.",
                          style: defaultSmallLabel(context),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      "https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-1080x675.jpg")),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            IconLabelButton(
                              icon: Iconsax.heart_outline,
                              label: "0",
                              isBig: true,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.heart_slash_outline,
                                label: "0",
                                isBig: true),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.message_outline,
                                label: "0",
                                isBig: true),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(left: 60, right: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfilePicture(
                        radius: 20, userObj: authHandler.loggedInUser!),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Post Malone on budget",
                                style: defaultVerySmallLabel(context,
                                    fontWeight: FontWeight.bold,
                                    fontColor: Theme.of(context).hintColor)),
                            const SizedBox(
                              width: 10,
                            ),
                            TextMetric(
                              value: numToEng(authHandler
                                  .loggedInUser!.userChannel!.level!),
                              label: 'Level',
                              compact: true,
                              reverse: true,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Other users can also add a post within a thread.",
                          style: defaultSmallLabel(context),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            IconLabelButton(
                              icon: Iconsax.heart_outline,
                              label: "0",
                              isBig: true,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.heart_slash_outline,
                                label: "0",
                                isBig: true),
                            SizedBox(
                              width: 10,
                            ),
                            IconLabelButton(
                                icon: Iconsax.message_outline,
                                label: "0",
                                isBig: true),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ],
          ),
          _bottomTextField()
        ],
      ),
    );
  }
}
