import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/authentication/forget_password/verify_otp.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/defaults/constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
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
                  "Let's verify your email first with a verification code.",
                  style: defaultLabelText(context,
                      fontWeight: FontWeight.normal,
                      fontColor: Theme.of(context).hintColor),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 3),
                  child: StepProgressIndicator(
                    totalSteps: 3,
                    currentStep: 1,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    unselectedColor: Theme.of(context).dividerColor,
                  ),
                ),
                _textField("Your registered mail address.", mailController,
                    TextInputType.emailAddress, 120),
                const SizedBox(
                  height: 15,
                ),
                PrimaryFocusButton(
                    label: "Send Verification Code",
                    callback: _registerCallBack),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                        onTap: () async {
                          final Uri url = Uri.parse(privacyPolicyUrl);
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text("Privacy Policy",
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor: Theme.of(context).disabledColor))),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          final Uri url =
                              Uri.parse(' https://forms.gle/S3V4hGuGYfkgnErh6');
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text("Need Help?",
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor: Theme.of(context).disabledColor))),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Hazel Communications Private Limited, 2024",
                  textAlign: TextAlign.center,
                  style: defaultVerySmallLabel(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).disabledColor),
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          )
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
      throwErrorSnackBar(context, "Mail cannot be empty");
      return;
    }

    Map data = {'email': mailController.text};
    String response = await UserEngine().sendMailOTP(data);

    if (response == "Mail sent with OTP.") {
      throwHappySnackBar(context, response);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyOTPWidget(
                    email: mailController.text,
                    alternate: false,
                  )));
    } else {
      throwErrorSnackBar(context, response);
    }
  }
}
