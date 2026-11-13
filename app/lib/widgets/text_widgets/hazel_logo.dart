import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lime_time_app/defaults/constants.dart';

class HazelLogoSmall extends StatelessWidget {
  const HazelLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    const hazelLogoColorLight = Colors.white;
    const hazelLogoColor = Colors.black;
    var hazelLogoDotColor = const Color(0xffABA2A2);

    return RichText(
      text: TextSpan(
          text: "Hazel",
          style: GoogleFonts.paytoneOne(
            textStyle: Theme.of(context).textTheme.headlineLarge,
            fontSize: 40,
            letterSpacing: -0.4,
            fontWeight: FontWeight.bold,
            color:
                theme == ThemeMode.dark ? hazelLogoColorLight : hazelLogoColor,
          ),
          children: [
            TextSpan(
                text: ".",
                style: GoogleFonts.paytoneOne(
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                  letterSpacing: -5,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: hazelLogoDotColor,
                )),
          ]),
    );
  }
}
