import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';

class UnifiedAdd extends StatefulWidget {
  const UnifiedAdd({super.key});

  @override
  State<UnifiedAdd> createState() => _UnifiedAddState();
}

class _UnifiedAddState extends State<UnifiedAdd> {
  Widget buildIconButton(IconData icon, {bool disablePadding = true}) {
    return IconButton(
        padding: disablePadding
            ? const EdgeInsets.only(left: 10, right: 25)
            : const EdgeInsets.only(right: 25),
        onPressed: () {},
        icon: Icon(icon, size: 20, color: Theme.of(context).hintColor));
  }

  Widget editablePost() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserProfilePicture(
          radius: 16,
          userObj: authHandler.loggedInUser!,
          useCache: true,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            children: [
              TextField(
                maxLines: null,
                style: defaultSmallLabel(context,
                    fontColor:
                        theme == ThemeMode.dark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration.collapsed(
                  hintText: "What's Happening?",
                  hintStyle: defaultSmallLabel(context,
                      fontColor: Theme.of(context).disabledColor),
                ),
                onChanged: (text) {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildIconButton(Iconsax.gallery_add_outline,
                      disablePadding: false),
                  buildIconButton(Iconsax.video_add_outline),
                  buildIconButton(Iconsax.voice_square_outline),
                  buildIconButton(Iconsax.chart_square_outline),
                  buildIconButton(Iconsax.hashtag_up_outline),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Thread",
          style: defaultHeadingXText(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            editablePost(),
          ],
        ),
      ),
    );
  }
}
