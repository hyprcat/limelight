import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/user_engine.dart';
import 'package:code_arrow_creator_studio/screens/route_guard.dart';
import 'package:code_arrow_creator_studio/widgets/logo.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:code_arrow_creator_studio/widgets/throw_error_snackbar.dart';
import 'package:code_arrow_creator_studio/widgets/throw_happy_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CreateUserProfile extends StatefulWidget {
  const CreateUserProfile({super.key});

  @override
  State<CreateUserProfile> createState() => _CreateUserProfileState();
}

class _CreateUserProfileState extends State<CreateUserProfile> {
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
    setState(() {
      _isLoading = true;
    });
    userProfilePictureResult = await FilePicker.platform.pickFiles(type: FileType.image);
    if (userProfilePictureResult != null) {
      userProfilePicture = MultipartFile.fromBytes(userProfilePictureResult!.files.first.bytes!);
    } else {
      // User canceled the picker
    }
    setState(() {
      _isLoading = false;
    });
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
    return Icon(
      Icons.person,
      size: radius,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _textField(String txt, TextEditingController control, TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            keyboardType: type,
            style: defaultLabelText(context),
            controller: control,
            maxLines: null,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: txt, hintStyle: defaultLabelText(context, fontColor: Theme.of(context).hintColor)),
          ),
        ));
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

  void _loginCallback() async {
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
      throwErrorSnackBar(context, "Your Bio looks empty.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data = {'bio': _bio.text, 'age': _age.text, 'gender': _gender.text.toLowerCase(), 'media': userProfilePictureResult};
      var response = await UserEngine().updateUserProfile(data);
      setState(() {
        _isLoading = false;
        _flush();
      });
      if (response == "success") {
        throwHappySnackBar(context, "User Profile successfully updated.");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throwErrorSnackBar(context, response);
      }
    } catch (e) {
      throwErrorSnackBar(context, e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingScreen() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 100,
        width: 600,
        padding: const EdgeInsets.only(left: 30, right: 30),
        color: Theme.of(context).canvasColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    List<Widget> loginChildren = [
      const Logo(),
      SelectableText("Let's leave an everlasting impact on the world.", style: defaultSmallLabel(context)),
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: StepProgressIndicator(
          totalSteps: 2,
          currentStep: 2,
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).dividerColor,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      SelectableText('Add Profile Picture', style: defaultLabelText(context)),
      Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              _selectDPCallback();
            },
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).disabledColor,
              child: CircleAvatar(radius: radius - 1.5, backgroundColor: Theme.of(context).canvasColor, child: _buildChild()),
            ),
          )),
      SelectableText('Bio', style: defaultLabelText(context)),
      _textField("What should your bio say?", _bio, TextInputType.emailAddress, 250),
      SelectableText('Age', style: defaultLabelText(context)),
      _textField("How much old are you?", _age, TextInputType.number, 3),
      SelectableText('Gender', style: defaultLabelText(context)),
      _textField("What is your gender?", _gender, TextInputType.text, 120),
      PrimaryFocusButton(label: "Up, Up and Away!", callback: _loginCallback)
    ];

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 600,
        margin: const EdgeInsets.only(left: 30, right: 30),
        padding: const EdgeInsets.only(left: 30, right: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).canvasColor,
        ),
        child: Container(
            margin: const EdgeInsets.only(top: 30, bottom: 30),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: loginChildren)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteGuardPage(
        child: Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.1,
              0.5,
              0.9,
            ],
            colors: [
              Colors.greenAccent,
              Colors.red,
              Colors.black,
            ],
          ))),
          _buildBody(),
        ],
      ),
    ));
  }
}
