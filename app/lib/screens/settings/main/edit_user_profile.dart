// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';

class EditUserProfile extends StatefulWidget {
  final Function refreshCallback;
  const EditUserProfile({super.key, required this.refreshCallback});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        child: TextField(
          keyboardType: type,
          style: defaultSmallLabel(context),
          controller: control,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: txt,
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).disabledColor),
          ),
        ));
  }

  TextEditingController channelNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Text(
          "Modify your bio",
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
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
            )
          : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ListView(
                children: [
                  _textField(
                      "Bio", descriptionController, TextInputType.text, 300),
                  PrimaryFocusButton(
                      label: 'Update Info',
                      callback: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (descriptionController.text.isEmpty) {
                          throwErrorSnackBar(context, "Bio can't be empty.");
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        var data = {
                          'token': sessionData!['token'],
                          'bio': descriptionController.text
                        };

                        bool status =
                            await UserEngine().updateProfileDetails(data);
                        if (status) {
                          throwHappySnackBar(context, "Successfully updated.");
                          widget.refreshCallback();
                          Navigator.pop(context);
                        } else {
                          throwErrorSnackBar(
                              context, "Couldn't update. Please try again.");
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
