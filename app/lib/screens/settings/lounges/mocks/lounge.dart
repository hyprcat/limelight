// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';

import 'package:lime_time_app/widgets/buttons/arrow_button.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/screens/settings/lounges/mocks/lounge_section.dart';

class Lounge_Mock extends StatefulWidget {
  const Lounge_Mock({super.key});

  @override
  State<Lounge_Mock> createState() => _Lounge_MockState();
}

class _Lounge_MockState extends State<Lounge_Mock> {
  bool isEditModeOn = false;

  Widget _buildIconButton(IconData icon, Function callback) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: isEditModeOn
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor.withOpacity(0.5),
        child: IconButton(
          icon: Icon(
            icon,
            color: isEditModeOn
                ? Colors.black
                : Theme.of(context).colorScheme.primary,
            size: 19,
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Theme.of(context).canvasColor,
        actions: [_buildIconButton(Icons.edit, () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserProfilePicture(
                    radius: 25, userObj: authHandler.loggedInUser!),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("${authHandler.loggedInUser!.userName!}'s Lounge",
                        style: defaultLabelText(context,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        TextMetric(
                          label: "Rank in Overall",
                          value: "#1",
                          reverse: false,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextMetric(
                          label: "Level",
                          value: "1",
                          reverse: true,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextMetric(
                          label: "Members",
                          value: "2",
                          reverse: false,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Common",
                style: defaultLabelText(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary)),
          ),
          ArrowButton(
            label: 'General Updates',
            description: "For your usual announcements",
            index: 0,
            callback: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const LoungeSection(
                  title: 'General Updates',
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          ),
          ArrowButton(
            label: 'Video Related Discussions',
            description: "You can suggest anything that you wanna watch here.",
            index: 0,
            callback: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const LoungeSection(
                  title: 'Video Related Discussions',
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text("Exclusive",
                style: defaultLabelText(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary)),
          ),
          Stack(
            children: [
              ArrowButton(
                label: 'Members-Only Chat',
                description: "For your usual discussions",
                index: 0,
                callback: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const LoungeSection(
                      title: 'Members-Only Chat',
                    ),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 50, top: 25),
                      alignment: Alignment.centerLeft,
                      child: const Icon(
                        Icons.lock,
                        size: 20,
                        color: Colors.yellow,
                      )),
                ],
              )
            ],
          ),
          ArrowButton(
            label: 'Merchandise',
            description: "Support us by checking out our gear",
            index: 0,
            callback: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const LoungeSection(
                  title: 'Merchandise',
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          ),
        ],
      ),
    );
  }
}
