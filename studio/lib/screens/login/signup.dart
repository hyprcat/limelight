import 'package:code_arrow_creator_studio/blocs/signup/signup_bloc.dart';
import 'package:code_arrow_creator_studio/defaults/constants.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/widgets/logo.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:code_arrow_creator_studio/widgets/throw_error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupBloc signupBloc = SignupBloc();

  bool _isRegisterClicked = false;

  var passwordList = [true, true, null];
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordVerify = TextEditingController();

  Widget _textField(String txt, TextEditingController control, TextInputType type, int maxLength, {id = 2, bool obscureText = false}) {
    return Container(
        margin: const EdgeInsets.only(top: 15, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            keyboardType: type,
            style: defaultLabelText(context),
            obscureText: passwordList[id] ?? false,
            controller: control,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: txt,
              hintStyle: defaultLabelText(context, fontColor: Theme.of(context).hintColor),
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

  void _loginCallback() {
    if (_userEmail.text.isEmpty) {
      throwErrorSnackBar(context, "Your email looks empty.");
      return;
    }

    if (_password.text.isEmpty) {
      throwErrorSnackBar(context, "Your password looks empty.");
      return;
    }

    if (!checkEmail(_userEmail.text)) {
      throwErrorSnackBar(context, "Your email format looks off. Check your email again.");
      return;
    }
    signupBloc.add(LoginEvent(_userEmail.text, _password.text));
  }

  void _registerCallBack() {
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
      throwErrorSnackBar(context, "Your email format looks off. Check your email again.");
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
      throwErrorSnackBar(context, "Your password don't exactly match. Check again.");
      return;
    }
    signupBloc.add(RegisterUser(_userName.text, _userEmail.text, _password.text));
  }

  void _textFieldFlush() {
    _userName.clear();
    _userEmail.clear();
    _password.clear();
    _passwordVerify.clear();
  }

  Widget _buildBody() {
    List<Widget> loginChildren = [
      const Logo(),
      SelectableText("Let's leave an everlasting impact on the world.", style: defaultSmallLabel(context)),
      _textField("Email", _userEmail, TextInputType.emailAddress, 120),
      _textField("Password", _password, TextInputType.visiblePassword, 120, id: 0, obscureText: true),
      const Align(alignment: Alignment.center, child: Text("Or")),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: PrimaryFocusButton(label: "Let's go!", callback: _loginCallback)),
          Container(
              margin: const EdgeInsets.only(left: 20),
              child: InkWell(
                  onTap: () {
                    _textFieldFlush();
                    setState(() {
                      _isRegisterClicked = true;
                    });
                  },
                  child: Text("New here?\nCreate an account.", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)))),
        ],
      )
    ];
    if (_isRegisterClicked) {
      loginChildren = [
        IconButton(
            onPressed: () {
              _textFieldFlush();
              setState(() {
                _isRegisterClicked = false;
              });
            },
            icon: const Icon(Icons.arrow_back)),
        const Logo(),
        SelectableText("Sign up here to unlock the world.", style: defaultSmallLabel(context)),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: StepProgressIndicator(
            totalSteps: 2,
            currentStep: 1,
            selectedColor: Theme.of(context).colorScheme.primary,
            unselectedColor: Theme.of(context).dividerColor,
          ),
        ),
        _textField("User Name", _userName, TextInputType.emailAddress, 120),
        _textField("Email", _userEmail, TextInputType.emailAddress, 120),
        _textField("Password", _password, TextInputType.visiblePassword, 120, id: 0, obscureText: true),
        _textField("Re-enter your password", _passwordVerify, TextInputType.visiblePassword, 120, id: 1, obscureText: true),
        PrimaryFocusButton(label: "Sign up", callback: _registerCallBack),
      ];
    }
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 600,
        margin: const EdgeInsets.only(left: 30, right: 30),
        padding: const EdgeInsets.only(left: 30, right: 30),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
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

  @override
  void initState() {
    signupBloc.add(SignupInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [
              0.1,
              0.5,
              0.9,
            ],
            colors: [
              Theme.of(context).colorScheme.primary,
              Colors.black,
              Colors.black,
            ],
          ))),
          BlocConsumer<SignupBloc, SignupState>(
            bloc: signupBloc,
            listener: (context, state) async {
              if (state is SignupError) {
                throwErrorSnackBar(context, state.error);
                signupBloc.add(SignupInitialEvent());
              }
              if (state is LoginSuccess) {
                Navigator.of(context).pushNamed('/home');
              }
              if (state is SignupSuccess) {
                throwErrorSnackBar(context, "Signup successful.");
                Navigator.of(context).pushNamed('/user_profile');
              }
            },
            builder: (context, state) {
              if (state is SignupLoading) {
                return _buildLoadingScreen();
              }
              if (state is LoginState) {
                return _buildBody();
              }
              return _buildLoadingScreen();
            },
          ),
        ],
      ),
    );
  }
}
