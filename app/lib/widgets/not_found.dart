import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/widgets/text_widgets/logo.dart';

import 'package:lime_time_app/defaults/utils.dart';

class Error404 extends StatelessWidget {
  const Error404({super.key});

  @override
  Widget build(BuildContext context) {
    RichText buildRichText() {
      return RichText(
        text: TextSpan(
            text: "If you think this is a mistake, Contact us on our support",
            style: defaultLabelText(context),
            children: [
              TextSpan(
                text: ' @lime.ai on your preferred social media platform.',
                style: defaultLabelText(context),
              ),
            ]),
      );
    }

    AppBar buildAppbar() {
      return AppBar(
        title: const CompanyLogo(
          width: 70,
          height: 70,
        ),
        automaticallyImplyLeading: false,
        elevation: 1,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
              onPressed: () {
                if (theme == ThemeMode.light) {
                  MyApp.of(context).changeTheme(ThemeMode.dark);
                } else {
                  MyApp.of(context).changeTheme(ThemeMode.light);
                }
              },
              icon: buildThemeIcon())
        ],
      );
    }

    return Scaffold(
      appBar: buildAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Uh-oh, Something's broken here.",
                style: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
            buildRichText()
          ],
        ),
      ),
    );
  }
}
