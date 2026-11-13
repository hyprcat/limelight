// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/authentication/forget_password/reset_password.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class VerifyOTPWidget extends StatefulWidget {
  final String email;
  bool? alternate;
  VerifyOTPWidget({super.key, required this.email, required this.alternate});

  @override
  State<VerifyOTPWidget> createState() => _VerifyOTPWidgetState();
}

class _VerifyOTPWidgetState extends State<VerifyOTPWidget> {
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
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            Text(
              "Verify your email",
              style: defaultHeadingText(context,
                  fontWeight: FontWeight.bold,
                  fontColor: Theme.of(context).colorScheme.primary),
            ),
            Text(
              "Check your inbox for a mail from no-reply@hazel.gg",
              style: defaultLabelText(context,
                  fontWeight: FontWeight.normal,
                  fontColor: Theme.of(context).hintColor),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 3),
              child: StepProgressIndicator(
                totalSteps: widget.alternate! ? 2 : 3,
                currentStep: widget.alternate! ? 1 : 2,
                selectedColor: Theme.of(context).colorScheme.secondary,
                unselectedColor: Theme.of(context).dividerColor,
              ),
            ),
            _textField("6 Digit Verification Code.", mailController,
                TextInputType.number, 6),
            const SizedBox(
              height: 15,
            ),
            PrimaryFocusButton(
                label: "Verify code", callback: _registerCallBack),
          ],
        ),
      ),
    );
  }

  _registerCallBack() async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (mailController.text.isEmpty) {
      throwErrorSnackBar(context, "OTP cannot be empty");
      return;
    }

    Map data = {'otp': mailController.text, 'email': widget.email};
    String response = await UserEngine().verifyOTP(data);

    if (response == "OTP verification successful") {
      throwHappySnackBar(context, response);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPassword(
                    email: widget.email,
                    alternate: widget.alternate,
                  )));
    } else {
      throwErrorSnackBar(context, response);
    }
  }
}
