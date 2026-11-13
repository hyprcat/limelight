import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/screens/home/home.dart';
import 'package:lime_time_app/widgets/buttons/check_box_title.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:lime_time_app/defaults/utils.dart';

class CompleteFeed extends StatefulWidget {
  final Map data;
  const CompleteFeed({super.key, required this.data});

  @override
  State<CompleteFeed> createState() => _CompleteFeedState();
}

class _CompleteFeedState extends State<CompleteFeed> {
  bool isFeedPublic = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary
                        ],
                        strokeWidth: 2,
                        backgroundColor: Theme.of(context).canvasColor,
                        pathBackgroundColor: Theme.of(context).canvasColor),
                  ),
                ),
                Text("Just a moment..",
                    style: defaultLabelText(context,
                        fontColor: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w500)),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ListView(
                children: [
                  Text("Review your feed.", style: defaultHeadingText(context)),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 3),
                    child: StepProgressIndicator(
                      totalSteps: 4,
                      currentStep: 4,
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      unselectedColor: Theme.of(context).dividerColor,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Title",
                            style: defaultLabelText(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.data['feed_name'],
                          style: defaultNormalText(context,
                              fontWeight: FontWeight.w600),
                        ),
                        Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                        Text("Description",
                            style: defaultLabelText(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.data['description'],
                          style: defaultNormalText(context,
                              fontWeight: FontWeight.w600),
                        ),
                        Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                        Text("Selected Creators",
                            style: defaultLabelText(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 5,
                        ),
                        if (widget.data['user_obj'].isNotEmpty)
                          Wrap(children: [
                            for (UserProfile i in widget.data['user_obj'])
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: Builder(builder: (context) {
                                    Color random = randomOpaqueColor();
                                    Color textColor =
                                        random.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white;
                                    return Chip(
                                        backgroundColor: random,
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            UserProfilePicture(
                                                radius: 13, userObj: i),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              i.userChannel!.name!,
                                              style: defaultLabelText(context,
                                                  fontWeight: FontWeight.w600,
                                                  fontColor: textColor),
                                            ),
                                          ],
                                        ));
                                  }),
                                ),
                              )
                          ]),
                        Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                        Text("Selected Topics",
                            style: defaultLabelText(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 5,
                        ),
                        if (widget.data['topics'].isNotEmpty)
                          Wrap(children: [
                            for (String i in widget.data['topics'])
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: Builder(builder: (context) {
                                    Color random = randomOpaqueColor();
                                    Color textColor =
                                        random.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white;
                                    return Chip(
                                        backgroundColor: random,
                                        label: Text(
                                          i,
                                          style: defaultLabelText(context,
                                              fontWeight: FontWeight.w600,
                                              fontColor: textColor),
                                        ));
                                  }),
                                ),
                              )
                          ]),
                        Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Feed visibility status",
                            style: defaultLabelText(context,
                                fontColor: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500)),
                        CheckBoxWidget(
                          label: "Make feed public",
                          callback: (value) {
                            setState(() {
                              isFeedPublic = value!;
                            });
                          },
                          status: isFeedPublic,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  PrimaryFocusButton(
                      label: 'Create Feed',
                      callback: () async {
                        setState(() {
                          isLoading = true;
                        });

                        Map data = widget.data;
                        data['token'] = sessionData!['token'];
                        data['user_obj'] = [];
                        data['is_public'] = isFeedPublic;
                        if (data['user_obj'].isEmpty &&
                            data['topics'].isEmpty) {
                          throwErrorSnackBar(context,
                              "You need to have either some topics or creators in your feed");
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }

                        bool status =
                            await VideoEngine().createCustomFeed(data);
                        if (status) {
                          throwHappySnackBar(context, "Custom feed created.");
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const Home()),
                                  (route) => false);
                          PersistentNavBarNavigator.pushNewScreen(context,
                              screen: const Home(), withNavBar: true);
                        } else {
                          throwErrorSnackBar(
                              context, 'Error occured while creating feed.');
                        }
                        setState(() {
                          isLoading = false;
                        });
                      })
                ],
              ),
            ),
    );
  }
}
