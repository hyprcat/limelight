// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/contests/september_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/authentication/forget_password/verify_otp.dart';
import 'package:lime_time_app/screens/authentication/introduction.dart';
import 'package:lime_time_app/screens/authentication/signin.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/main/data_access.dart';
import 'package:lime_time_app/screens/settings/playlist/playlist.dart';
import 'package:lime_time_app/screens/settings/subscriptions/blocked_users.dart';
import 'package:lime_time_app/screens/settings/subscriptions/subscriptions.dart';
import 'package:lime_time_app/screens/settings/watch_history/watch_history.dart';

import 'package:lime_time_app/widgets/buttons/arrow_button.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/contests/september_contest.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  SeptemberBloc septemberBloc = SeptemberBloc();

  @override
  void initState() {
    septemberBloc.add(LoadContestData());
    super.initState();
  }

  int tapCount = 0;
  @override
  Widget build(BuildContext context) {
    Widget _buildChipSectionButton(String label) {
      return Chip(
          visualDensity: VisualDensity.compact,
          label: Text(
            label,
            style: defaultVerySmallLabel(context),
          ));
    }

    Widget _buildSectionToggleRow() {
      return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            _buildChipSectionButton('Home'),
            const SizedBox(
              width: 4,
            ),
            _buildChipSectionButton('Videos'),
            const SizedBox(
              width: 4,
            ),
            _buildChipSectionButton('Lounge'),
            const SizedBox(
              width: 4,
            ),
            _buildChipSectionButton('Stats')
          ],
        ),
      );
    }

    Widget _buildIconButton(IconData icon, Function callback) {
      return Container(
        margin: const EdgeInsets.only(right: 5),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).cardColor,
          child: IconButton(
            icon: Icon(
              icon,
              size: 19,
            ),
            onPressed: () {
              callback();
            },
          ),
        ),
      );
    }

    Widget _labelledHorizontalVideoSectionBuilder(String label) {
      return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: defaultLabelText(context, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "There's nothing here, Yet.",
                  style: defaultVerySmallLabel(context,
                      fontColor: Theme.of(context).hintColor),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "More",
                style: defaultVerySmallLabel(context,
                    fontColor: Theme.of(context).colorScheme.primary),
              ),
            )
          ],
        ),
      );
    }

    void _loadChannelCallback() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: UserChannel(user: authHandler.loggedInUser, asList: false),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadHistoryCallback() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const WatchHistory(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadLoungeCallback() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: Lounge(user: authHandler.loggedInUser!),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadPlaylists() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const Playlists(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadSubscriptions() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const AllSubscriptions(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadBlocked() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const BlockedUsersList(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadContest() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const SeptemberContest(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    void _loadDataAccess() {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const DataAccess(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        title: Text(
          "Settings",
          style: defaultHeadingXText(context),
        ),
        titleSpacing: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: AnimatedCoolRefresh(
        onRefresh: () async {
          var temp = await authHandler.refreshUser();
          if (temp != null) {
            setState(() {
              authHandler.loggedInUser = temp;
            });
            setState(() {});
          } else {}
        },
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      ArrowButton(
                        label: 'Playlists',
                        description: 'Curated by you or us.',
                        callback: _loadPlaylists,
                        index: 0,
                        icon: const Icon(
                          Iconsax.slider_vertical_outline,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                        label: 'History',
                        description: 'Everything you have watched.',
                        callback: _loadHistoryCallback,
                        index: 0,
                        icon: const Icon(Iconsax.back_square_outline, size: 30),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                        label: 'Subscriptions',
                        description: 'Creators you have been subscribed to',
                        callback: _loadSubscriptions,
                        index: 0,
                        icon:
                            const Icon(Iconsax.user_octagon_outline, size: 30),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                        label: 'Blocked Accounts',
                        description: "People you don't want to see",
                        callback: _loadBlocked,
                        index: 0,
                        icon: const Icon(Iconsax.forbidden_outline, size: 30),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Privacy Policy',
                          description: 'Understand how we use your data.',
                          callback: () async {
                            final Uri _url = Uri.parse(privacyPolicyUrl);
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          icon: const Icon(Iconsax.security_outline, size: 30),
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Terms and Conditions',
                          description: 'For using our platform.',
                          callback: () async {
                            final Uri _url = Uri.parse(termsAndConditions);
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          icon:
                              const Icon(Iconsax.information_outline, size: 30),
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'End-User License Agreement',
                          description: "About LimeLight Social and Hazel.",
                          callback: () async {
                            final Uri _url = Uri.parse(eula);
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          icon: const Icon(Iconsax.document_cloud_outline,
                              size: 30),
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Feedback and Support',
                          description:
                              "Let us know about any issues that you're facing.",
                          icon:
                              const Icon(Iconsax.info_circle_outline, size: 30),
                          callback: () async {
                            final Uri _url = Uri.parse(
                                'https://forms.gle/S3V4hGuGYfkgnErh6');
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Restart Onboarding',
                          description: 'To understand us better.',
                          callback: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const OnBoardingPage(),
                              withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          icon: const Icon(Iconsax.activity_outline, size: 30),
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Change password',
                          description: "Courtesy by @deepakshah",
                          icon: const Icon(Iconsax.password_check_outline,
                              size: 30),
                          callback: () async {
                            Map data = {
                              'email': authHandler.loggedInUser!.userEmail
                            };
                            String response =
                                await UserEngine().sendMailOTP(data);

                            if (response == "Mail sent with OTP.") {
                              throwHappySnackBar(context, response);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VerifyOTPWidget(
                                            email: authHandler
                                                .loggedInUser!.userEmail!,
                                            alternate: true,
                                          )));
                            } else {
                              throwErrorSnackBar(context, response);
                            }
                          },
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Manage your data with us',
                          description:
                              "If you want to take out or delete your account",
                          callback: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const DataAccess(),
                              withNavBar:
                                  true, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          icon: const Icon(Iconsax.security_user_outline,
                              size: 30),
                          index: 0),
                      const SizedBox(
                        height: 15,
                      ),
                      ArrowButton(
                          label: 'Logout',
                          description: 'See you soon.',
                          icon: const Icon(Iconsax.logout_1_outline, size: 30),
                          callback: () async {
                            var logoutStatus = await UserEngine().logout();
                            if (logoutStatus) {
                              sessionData = null;
                              storage.delete(key: 'auth_token');
                              storage.delete(key: 'token');
                              var userProfileBox =
                                  await Hive.openBox('user_profile');
                              userProfileBox.delete('user_data');
                              PersistentNavBarNavigator.pushNewScreen(context,
                                  screen: const SignIn(), withNavBar: false);
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => const SignIn()),
                                      (route) => false);
                            }
                          },
                          index: 0),
                      const SizedBox(
                        height: 30,
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                      text: 'Lime',
                                      style: TextStyle(
                                          fontFamily: 'Gil',
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800),
                                      children: [
                                        TextSpan(
                                          text: 'Light.',
                                          style: TextStyle(
                                              fontFamily: 'Gil',
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ]),
                                ),
                                Text(
                                  'SOCIAL',
                                  style: defaultVerySmallLabel(context,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      InkWell(
                          onTap: () {
                            if (tapCount < 7) {
                              tapCount++;
                              if (tapCount < 7) {
                                final snackBar = SnackBar(
                                  duration: const Duration(milliseconds: 50),
                                  content: Text(
                                      'You are ${(7 - tapCount).toString()} taps away from being a developer.'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                MyApp.of(context).toggleDeveloperSettings();
                                const snackBar = SnackBar(
                                  content: Text('Developer settings toggled!'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          child: Text("App Version: $VERSION",
                              style: defaultVerySmallLabelCustom(context,
                                  fontColor: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w600))),
                      Text(
                        "Hazel Communications Private Limited, 2024",
                        textAlign: TextAlign.start,
                        style: defaultVerySmallLabelCustom(context,
                            fontWeight: FontWeight.w600,
                            fontColor: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 150,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
