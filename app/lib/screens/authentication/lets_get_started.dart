import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/authentication/signin.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';

class LetsGetStarted extends StatefulWidget {
  const LetsGetStarted({super.key});

  @override
  State<LetsGetStarted> createState() => _LetsGetStartedState();
}

class _LetsGetStartedState extends State<LetsGetStarted> {
  @override
  Widget build(BuildContext context) {
    RichText buildLogo() {
      return RichText(
        text: TextSpan(
            text: 'Lime',
            style: defaultHeadingText(context,
                fontColor: Theme.of(context).colorScheme.primary, fontsize: 40),
            children: [
              TextSpan(
                text: 'Light.',
                style: defaultHeadingText(context,
                    fontColor: Theme.of(context).colorScheme.inverseSurface,
                    fontsize: 40),
              ),
            ]),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildLogo(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Still thinking about the tag-line.",
                    style:
                        defaultLabelText(context, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: PrimaryFocusButton(
                  label: "Let's get started.",
                  callback: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignIn()));
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          )
        ],
      ),
    );
  }
}
