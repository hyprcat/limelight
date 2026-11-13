// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/authentication/signin.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  bool? alternate;
  ResetPassword({super.key, required this.email, this.alternate});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  List<bool?> passwordList = [null, null, null];

  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength,
      {id = 2, bool obscureText = false}) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: TextField(
            keyboardType: type,
            style: defaultSmallLabel(context),
            obscureText: passwordList[id] ?? false,
            controller: control,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: txt,
              contentPadding: const EdgeInsets.only(top: 15),
              hintStyle: defaultSmallLabel(context,
                  fontColor: Theme.of(context).hintColor),
              suffixIcon: obscureText
                  ? IconButton(
                      onPressed: () {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        setState(() {
                          passwordList[id] = !passwordList[id]!;
                        });
                      },
                      icon: const Icon(Icons.password),
                    )
                  : Icon(
                      Icons.cancel,
                      color: Theme.of(context).canvasColor,
                    ),
            ),
          ),
        ));
  }

  TextEditingController mailController = TextEditingController();
  TextEditingController mailController2 = TextEditingController();
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
        toolbarHeight: 100,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              children: [
                Text(
                  "Reset your password",
                  style: defaultHeadingText(context,
                      fontWeight: FontWeight.bold,
                      fontColor: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  "Set a strong password",
                  style: defaultLabelText(context,
                      fontWeight: FontWeight.normal,
                      fontColor: Theme.of(context).hintColor),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 3),
                  child: StepProgressIndicator(
                    totalSteps: widget.alternate! ? 2 : 3,
                    currentStep: widget.alternate! ? 2 : 3,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    unselectedColor: Theme.of(context).dividerColor,
                  ),
                ),
                _textField("Password.", mailController,
                    TextInputType.emailAddress, 120,
                    obscureText: true, id: 1),
                _textField("Re-enter your password.", mailController2,
                    TextInputType.emailAddress, 120,
                    obscureText: true, id: 1),
                const SizedBox(
                  height: 15,
                ),
                PrimaryFocusButton(
                    label: "Save Password", callback: _registerCallBack),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _registerCallBack() async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (mailController.text.isEmpty) {
      throwErrorSnackBar(context, "Password fields cannot be empty");
      return;
    }
    if (mailController2.text.isEmpty) {
      throwErrorSnackBar(context, "Password fields cannot be empty");
      return;
    }

    Map data = {'email': widget.email, 'password': mailController.text};
    String response = await UserEngine().resetPassword(data);

    if (response ==
        "Password reset successful. You can login with your new password now.") {
      throwHappySnackBar(context, response);
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignIn()),
          (route) => false);
    } else {
      throwErrorSnackBar(context, response);
    }
  }
}
