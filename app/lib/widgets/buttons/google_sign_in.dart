import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class GoogleSignIn extends StatefulWidget {
  const GoogleSignIn({super.key});

  @override
  State<GoogleSignIn> createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
      margin: const EdgeInsets.only(top: 5, left: 5, bottom: 5),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Brand(Brands.google),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Continue via Google",
              style: defaultSmallLabel(context,
                  fontColor: Theme.of(context).colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
