// ignore_for_file: unused_field

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:lime_time_app/bloc/sign_in/google_sign_in_bloc.dart';

class UserDetailsSection extends StatefulWidget {
  const UserDetailsSection({super.key});

  @override
  State<UserDetailsSection> createState() => _UserDetailsSectionState();
}

class _UserDetailsSectionState extends State<UserDetailsSection> {
  GoogleSignInBloc googleSignInBloc = GoogleSignInBloc();

  @override
  void initState() {
    googleSignInBloc.add(LoadPage());
    super.initState();
  }

  final TextEditingController _bio = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _gender = TextEditingController();

  final TextEditingController _city = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _region = TextEditingController();

  double radius = 60;
  MultipartFile? userProfilePicture;
  FilePickerResult? userProfilePictureResult;

  bool _isLoading = false;

  void _selectDPCallback() async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    setState(() {
      _isLoading = true;
    });
    try {
      userProfilePictureResult = await FilePicker.platform
          .pickFiles(type: FileType.image, withData: true);
      if (userProfilePictureResult != null) {
        userProfilePicture = MultipartFile.fromBytes(
            userProfilePictureResult!.files.first.bytes!);
      } else {
        // User canceled the picker
      }
    } catch (e) {
      throwErrorSnackBar(context, "Error while picking image");
      userProfilePictureResult = null;
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  void _flush() {
    _gender.clear();
    _age.clear();
    _bio.clear();
    userProfilePicture = null;
    userProfilePictureResult = null;
  }

  Widget _buildChild() {
    if (userProfilePictureResult != null) {
      return SizedBox(
        height: radius * 1.95,
        width: radius * 1.95,
        child: ClipOval(
            child: Image.memory(
          userProfilePictureResult!.files.first.bytes!,
          fit: BoxFit.fill,
        )),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.person,
          size: radius,
          color: Theme.of(context).hintColor,
        ),
        Text('Upload your best image.',
            style: defaultLabelText(context,
                fontWeight: FontWeight.normal,
                fontColor: Theme.of(context).hintColor))
      ],
    );
  }

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
            style: defaultLabelText(context),
            obscureText: passwordList[id] ?? false,
            controller: control,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: txt,
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
                  : Icon(
                      Icons.cancel,
                      color: Theme.of(context).canvasColor,
                    ),
            ),
          ),
        ));
  }

  void _loginCallback() async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_bio.text.isEmpty) {
      throwErrorSnackBar(context, "Your Bio looks empty.");
      return;
    }
    if (_age.text.isEmpty) {
      throwErrorSnackBar(context, "Your Age looks empty.");
      return;
    }
    if (!_isNumeric(_age.text)) {
      throwErrorSnackBar(context, "Age does not look like a number..");
      return;
    }
    if (_gender.text.isEmpty) {
      throwErrorSnackBar(context, "Gender can't be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data = {
        'bio': _bio.text,
        'age': _age.text,
        'gender': _gender.text.toLowerCase(),
        'media': userProfilePictureResult
      };
      var response = await UserEngine().updateUserProfile(data);

      setState(() {
        _isLoading = false;
        _flush();
      });
      if (response == "success") {
        throwHappySnackBar(context, "User Profile successfully updated.");
        await UserEngine().login(cachedNewData);
        UserEngine().updateGeoDetails();
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throwErrorSnackBar(context, response);
      }
    } catch (e) {
      rethrow;
      throwErrorSnackBar(context, e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingScreen() {
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

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    List<Widget> loginChildren = [
      SelectableText(
        "Just one last thing..",
        style: defaultHeadingText(
          context,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "Add these details to get the best experience.",
        style: defaultLabelText(context,
            fontWeight: FontWeight.normal,
            fontColor: Theme.of(context).hintColor),
      ),
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: StepProgressIndicator(
          totalSteps: 2,
          currentStep: 2,
          selectedColor: Theme.of(context).colorScheme.secondary,
          unselectedColor: Theme.of(context).dividerColor,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Align(
          alignment: Alignment.center,
          child: InkWell(
              onTap: () {
                _selectDPCallback();
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Theme.of(context).dividerColor)),
                  child: Center(
                    child: _buildChild(),
                  ),
                ),
              ))),
      _textField("Bio", _bio, TextInputType.emailAddress, 250),
      _textField("How old are you?", _age, TextInputType.number, 3),
      _textField("Gender", _gender, TextInputType.text, 120),
      const SizedBox(
        height: 10,
      ),
      PrimaryFocusButton(label: "Done", callback: _loginCallback),
      const SizedBox(
        height: 40,
      ),
      Text(
        "By uploading, Your photo will be visible to all the users across the platform. By continuing, you acknowledge that you understand and agree to our Terms & Conditions and Privacy Policy.",
        textAlign: TextAlign.center,
        style: defaultVerySmallLabel(context,
            fontWeight: FontWeight.bold,
            fontColor: Theme.of(context).disabledColor),
      ),
      const SizedBox(
        height: 40,
      ),
    ];

    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(children: loginChildren));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
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
        body: _buildBody());
  }
}
