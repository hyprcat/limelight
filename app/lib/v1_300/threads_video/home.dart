import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/screens/home/default/default_top_videos.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/notifications/notifications_home.dart';
import 'package:lime_time_app/screens/settings/main/settings.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';

class ThreadsVideoMixer extends StatefulWidget {
  const ThreadsVideoMixer({super.key});

  @override
  State<ThreadsVideoMixer> createState() => _ThreadsVideoMixerState();
}

class _ThreadsVideoMixerState extends State<ThreadsVideoMixer> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).canvasColor,
                  surfaceTintColor: Theme.of(context).canvasColor,
                  leading: UserProfilePicture(
                    radius: 16,
                    userObj: authHandler.loggedInUser!,
                    doNothing: true,
                    callback: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: UserChannel(
                            user: authHandler.loggedInUser, asList: false),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  snap: true,
                  floating: true,
                  actions: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const SettingsMain(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        icon: Icon(
                          Iconsax.language_square_outline,
                          size: 22,
                          color: theme == ThemeMode.light
                              ? Colors.black
                              : Colors.white,
                        )),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const NotificationsHome(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        icon: ValueListenableBuilder(
                            valueListenable: notificationCount,
                            builder: (context, value, _) {
                              return Badge(
                                backgroundColor: Colors.red,
                                label: Text(
                                  numToEng(value),
                                  style: defaultEvenVerySmallLabelCustom(
                                      context,
                                      fontColor: Colors.white),
                                ),
                                isLabelVisible: value != 0,
                                child: Icon(
                                  Iconsax.notification_bold,
                                  size: 22,
                                  color: theme == ThemeMode.light
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              );
                            })),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const SettingsMain(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        icon: Icon(
                          Iconsax.setting_2_bold,
                          size: 22,
                          color: theme == ThemeMode.light
                              ? Colors.black
                              : Colors.white,
                        )),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ];
            },
            body: const DefaultTopVideos(),
          ),
        ));
  }

  buildTabBarText(String s) {
    return Text(s);
  }
}
