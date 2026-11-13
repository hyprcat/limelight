import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/authentication/forget_password/forget_password.dart';
import 'package:lime_time_app/screens/authentication/signup.dart';
import 'package:lime_time_app/screens/authentication/user_details.dart';
import 'package:lime_time_app/widgets/buttons/apple_sign_in_button.dart';
import 'package:lime_time_app/widgets/buttons/google_sign_in.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/bloc/sign_in/google_sign_in_bloc.dart';
import 'package:lime_time_app/screens/authentication/introduction.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GoogleSignInBloc googleSignInBloc = GoogleSignInBloc();

  RichText _buildNewHere() {
    return RichText(
      text: TextSpan(
          text: 'New here?\n',
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'Create a account instead.',
              style: defaultSmallLabel(context,
                  fontColor: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ]),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    googleSignInBloc.add(LoadPage());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _password = TextEditingController();

  var passwordList = [true, true, null];
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength,
      {id = 2, bool obscureText = false}) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(400),
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
                        setState(() {
                          passwordList[id] = !passwordList[id]!;
                        });
                      },
                      icon: const Icon(Icons.password),
                    )
                  : const Icon(
                      Icons.cancel,
                      color: Colors.transparent,
                    ),
            ),
          ),
        ));
  }

  void _loginCallback() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
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
    googleSignInBloc.add(LoginEvent(_userEmail.text, _password.text));
  }

  Widget buildLogo() {
    return RichText(
      text: TextSpan(
          text: 'Lime',
          style: defaultHeadingXText(context,
              fontsize: 35, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'light.',
              style: defaultHeadingXText(context,
                  fontsize: 35, fontWeight: FontWeight.bold),
            ),
          ]),
    );
  }

  bool showEmail = false;

  Widget content() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView(
        children: [
          const SizedBox(
            height: 100,
          ),
          Row(
            children: [
              Image.asset(
                'assets/logo_dark.png',
                height: 100,
                width: 100,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17.0, right: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Log in to LimeLight Social.",
                  style: defaultHeadingText(
                    context,
                    fontsize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: !showEmail
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            PrimaryFocusButton(
                              suffix: Icon(
                                Icons.email,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                size: 20,
                              ),
                              label: "Continue via "
                                  "Mail",
                              showArrow: false,
                              callback: () {
                                setState(() {
                                  showEmail = !showEmail;
                                });
                              },
                              alternateColor: Theme.of(context).cardColor,
                            ),
                          ],
                        )
                      : GestureDetector(
                          onPanUpdate: (details) {
                            if (details.delta.dy > 0) {
                              setState(() {
                                showEmail = !showEmail;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              _textField("Email", _userEmail,
                                  TextInputType.emailAddress, 120),
                              _textField("Password", _password,
                                  TextInputType.visiblePassword, 120,
                                  id: 0, obscureText: true),
                              const SizedBox(
                                height: 10,
                              ),
                              PrimaryFocusButton(
                                suffix: Icon(
                                  Icons.email,
                                  color: Theme.of(context).canvasColor,
                                  size: 20,
                                ),
                                label: "Sign in",
                                callback: _loginCallback,
                                showArrow: false,
                                highLight: true,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()));
                                        },
                                        child: _buildNewHere()),
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ForgetPassword()));
                                        },
                                        child: Text(
                                          'Forget password?',
                                          style: defaultSmallLabel(context,
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Divider(
                                color: Theme.of(context).dividerColor,
                                thickness: 2,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                ),
                InkWell(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.selectionClick();
                      googleSignInBloc.add(SignInStart());
                    },
                    child: const GoogleSignIn()),
                InkWell(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.selectionClick();
                      googleSignInBloc.add(LoadPageApple());
                    },
                    child: const AppleSignInButton()),
                const SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "By continuing, you agree to our privacy policy and terms & conditions.",
                        style: defaultVerySmallLabel(context,
                            fontWeight: FontWeight.w600,
                            fontColor: Theme.of(context).hintColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () async {
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
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
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
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
                        Row(
                          children: [
                            InkWell(
                                onTap: () async {
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
                                  final Uri url = Uri.parse(eula);
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                child: Text("EULA",
                                    style: defaultVerySmallLabel(context,
                                        fontWeight: FontWeight.w600,
                                        fontColor:
                                            Theme.of(context).disabledColor))),
                            const SizedBox(
                              width: 20,
                            ),
                            InkWell(
                                onTap: () async {
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
                                  final Uri url = Uri.parse(termsAndConditions);
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                child: Text("Terms and Conditions",
                                    style: defaultVerySmallLabel(context,
                                        fontWeight: FontWeight.w600,
                                        fontColor:
                                            Theme.of(context).disabledColor))),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: Theme.of(context).dividerColor,
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
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildState(context, state) {
    if (state is GoogleSignInInitial) {
      return Stack(
        children: [
          content(),
        ],
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
    if (state is AppleSignInSuccess) {
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
              "Apple Sign-up successful. Logging you in now.",
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
          "Error occured.",
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<GoogleSignInBloc, GoogleSignInState>(
        bloc: googleSignInBloc,
        listener: (context, state) {
          if (state is SignInError) {
            throwErrorSnackBar(context, "Sign-in error. Please try again.");
            googleSignInBloc.add(LoadPage());
          }
          if (state is SignInSuccess) {
            if ((sessionData!['token'] != null) &&
                authHandler.loggedInUser == null) {
              determinePosition();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserDetailsSection()));
            } else if (firstRun) {
              determinePosition();
              UserEngine().updateGeoDetails();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnBoardingPage()));
            } else {
              determinePosition();
              UserEngine().updateGeoDetails();

              if (authHandler.loggedInUser!.isBanned!) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/banned', (route) => false);
              }
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            }
          }

          if (state is MSignInError) {
            throwErrorSnackBar(
                context, "Invalid login credentials. Please try again.");
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
