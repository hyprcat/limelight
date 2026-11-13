import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/bloc/sign_in/google_sign_in_bloc.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GoogleSignInBloc googleSignInBloc = GoogleSignInBloc();

  @override
  void initState() {
    googleSignInBloc.add(LoadPage());
    super.initState();
  }

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordVerify = TextEditingController();

  var passwordList = [true, true, null];

  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength,
      {id = 2, bool obscureText = false}) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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

  void _registerCallBack() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_userName.text.isEmpty) {
      throwErrorSnackBar(context, "Your user name looks empty.");
      return;
    }

    if (_userName.text.length < 2) {
      throwErrorSnackBar(context, "Your password is too short.");
      return;
    }

    if (_userEmail.text.isEmpty) {
      throwErrorSnackBar(context, "Your email looks empty.");
      return;
    }

    if (_password.text.isEmpty) {
      throwErrorSnackBar(context, "Your password looks empty.");
      return;
    }

    if (!checkEmail(_userEmail.text)) {
      throwErrorSnackBar(
          context, "Your email format looks off. Check your email again.");
      return;
    }

    if (_passwordVerify.text.isEmpty) {
      throwErrorSnackBar(context, "Your password looks empty.");
      return;
    }

    if (_password.text.length < 8) {
      throwErrorSnackBar(context, "Your password is too short.");
      return;
    }

    if (_password.text != _passwordVerify.text) {
      throwErrorSnackBar(
          context, "Your password don't exactly match. Check again.");
      return;
    }
    googleSignInBloc
        .add(RegisterUser(_userName.text, _userEmail.text, _password.text));
  }

  Widget buildState(context, state) {
    if (state is GoogleSignInInitial) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's get you started.",
                  style: defaultHeadingText(
                    context,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Fill in this details and you'll be good to go.",
                  style: defaultLabelText(context,
                      fontWeight: FontWeight.normal,
                      fontColor: Theme.of(context).hintColor),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 3),
                  child: StepProgressIndicator(
                    totalSteps: 2,
                    currentStep: 1,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    unselectedColor: Theme.of(context).dividerColor,
                  ),
                ),
                _textField(
                    "User Name", _userName, TextInputType.emailAddress, 120),
                _textField(
                    "Email", _userEmail, TextInputType.emailAddress, 120),
                _textField(
                    "Password", _password, TextInputType.visiblePassword, 120,
                    id: 0, obscureText: true),
                _textField("Re-enter your password", _passwordVerify,
                    TextInputType.visiblePassword, 120,
                    id: 1, obscureText: true),
                const SizedBox(
                  height: 15,
                ),
                PrimaryFocusButton(
                    label: "Let's go", callback: _registerCallBack),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Your name and photo will be visible to all the users across the platform. By continuing, you acknowledge that you understand and agree to our Terms & Conditions and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: defaultVerySmallLabel(context,
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).disabledColor),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    fontColor:
                                        Theme.of(context).disabledColor))),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://forms.gle/S3V4hGuGYfkgnErh6');
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                            child: Text("Need Help?",
                                style: defaultVerySmallLabel(context,
                                    fontWeight: FontWeight.w600,
                                    fontColor:
                                        Theme.of(context).disabledColor))),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text("App Version: $VERSION",
                        style: defaultVerySmallLabel(context,
                            fontColor: Theme.of(context).disabledColor)),
                    Text(
                      "Hazel Communications Private Limited, 2024",
                      textAlign: TextAlign.center,
                      style: defaultVerySmallLabel(context,
                          fontColor: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    }
    if (state is LoadingStart) {
      return Center(
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
      );
    }
    if (state is GoogleSignInSuccess) {
      return Center(
        child: Column(
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
            const SizedBox(
              height: 5,
            ),
            Text(
              "Google Sign-up successful. Logging you in now.",
              style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }
    if (state is SignInSuccess) {
      return Center(
        child: Column(
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
            const SizedBox(
              height: 5,
            ),
            Text(
              "Any moment now..",
              style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }
    if (state is SignInError) {
      return Center(
        child: Text(
          "Error occurred.",
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Theme.of(context).canvasColor,
        toolbarHeight: 100,
      ),
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<GoogleSignInBloc, GoogleSignInState>(
        bloc: googleSignInBloc,
        listener: (context, state) {
          if (state is SignInSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/user_details', (route) => false);
          }
          if (state is MSignInError) {
            throwErrorSnackBar(context, state.error);
            googleSignInBloc.add(LoadPage());
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: buildState(context, state),
          );
        },
      ),
    );
  }
}
