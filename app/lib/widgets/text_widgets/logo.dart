import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyLogo extends StatefulWidget {
  final double height;
  final double width;
  const CompanyLogo({super.key, required this.height, required this.width});

  @override
  State<CompanyLogo> createState() => _CompanyLogoState();
}

class _CompanyLogoState extends State<CompanyLogo> {
  var hazelLogoDotColor = const Color(0xffABA2A2);

  Widget _buildLogo() {
    var hazelLogoColorLight;
    return RichText(
      text: TextSpan(
          text: 'Lime',
          style: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.titleLarge,
            letterSpacing: -0.4,
            fontWeight: FontWeight.bold,
            color: hazelLogoColorLight,
          ),
          children: [
            TextSpan(
              text: 'Light',
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.titleLarge,
                letterSpacing: -0.4,
                fontWeight: FontWeight.bold,
                color: hazelLogoColorLight,
              ),
            ),
            TextSpan(
                text: " Social.",
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: hazelLogoDotColor,
                )),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLogo();
  }
}
