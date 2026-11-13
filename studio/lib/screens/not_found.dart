import 'package:code_arrow_creator_studio/defaults/constants.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:code_arrow_creator_studio/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Error404 extends StatelessWidget {
  const Error404({super.key});

  @override
  Widget build(BuildContext context) {
    RichText buildRichText() {
      return RichText(
        text: TextSpan(text: "If you think this is a mistake, Contact us on our support", style: defaultLabelText(context), children: [
          TextSpan(
            text: ' @lime.ai on your preferred social media platform.',
            style: defaultLabelText(context),
          ),
        ]),
      );
    }

    AppBar buildAppbar() {
      return AppBar(
        title: const Logo(),
        automaticallyImplyLeading: false,
        elevation: 1,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
              onPressed: () {
                if (activeTheme == 'light') {
                  activeTheme = 'dark';
                  MyApp.of(context).changeTheme(ThemeMode.dark);
                } else {
                  activeTheme = 'light';
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
