import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/home/custom_feeds/basic_info.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CustomFeedCreatorHome extends StatefulWidget {
  const CustomFeedCreatorHome({super.key});

  @override
  State<CustomFeedCreatorHome> createState() => _CustomFeedCreatorHomeState();
}

class _CustomFeedCreatorHomeState extends State<CustomFeedCreatorHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("See what you like to see on your home page.",
              style: defaultHeadingText(context)),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Create a custom feed with topics and creators you like. You can add feeds created by other users from custom feeds section of your user profile.",
            style: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
          ),
          const SizedBox(
            height: 20,
          ),
          PrimaryFocusButton(
              label: 'Make custom feed',
              callback: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const CustomFeedBasicInfo(),
                  withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              })
        ],
      ),
    );
  }
}
