// ignore_for_file: unused_field

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/home/custom_feeds/select_creators.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CustomFeedBasicInfo extends StatefulWidget {
  const CustomFeedBasicInfo({super.key});

  @override
  State<CustomFeedBasicInfo> createState() => _CustomFeedBasicInfoState();
}

class _CustomFeedBasicInfoState extends State<CustomFeedBasicInfo> {
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: TextField(
            keyboardType: type,
            style: defaultSmallLabel(context),
            controller: control,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: txt,
              hintStyle: defaultSmallLabel(context,
                  fontColor: Theme.of(context).hintColor),
            ),
          ),
        ));
  }

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            Text("Lets get the basics first.",
                style: defaultHeadingText(context)),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 3),
              child: StepProgressIndicator(
                totalSteps: 4,
                currentStep: 1,
                selectedColor: Theme.of(context).colorScheme.secondary,
                unselectedColor: Theme.of(context).dividerColor,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "What do you want to call your feed?",
              style: defaultLabelText(context),
            ),
            _textField(
                "My technology news etc.", _userName, TextInputType.text, 64),
            const SizedBox(
              height: 10,
            ),
            Text("What's this feed about?", style: defaultLabelText(context)),
            _textField(
                "All my favourite tech creators and topics that interest me etc..",
                _userEmail,
                TextInputType.text,
                250),
            const SizedBox(
              height: 20,
            ),
            PrimaryFocusButton(
                label: "Next",
                callback: () {
                  if (_userName.text.isEmpty) {
                    throwErrorSnackBar(context, "You need to name your feed");
                    return;
                  }

                  if (_userEmail.text.isEmpty) {
                    throwErrorSnackBar(
                        context, "You need to add description to your feed");
                    return;
                  }

                  Map basicInfo = {
                    'feed_name': _userName.text,
                    'description': _userEmail.text
                  };

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: SelectCreatorsCustomFeed(
                      basicInfo: basicInfo,
                    ),
                    withNavBar: true, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                })
          ],
        ),
      ),
    );
  }
}
