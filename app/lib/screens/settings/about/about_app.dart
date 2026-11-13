import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/widgets/text_widgets/logo.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            const CompanyLogo(
              width: 70,
              height: 70,
            ),
            const SizedBox(
              height: 5,
            ),
            Text("App Version: $VERSION",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600)),
            Text(
              "Hazel Communications Private Limited, 2024",
              textAlign: TextAlign.start,
              style: defaultLabelText(context,
                  fontWeight: FontWeight.w600,
                  fontColor: Theme.of(context).hintColor),
            ),
            Divider(color: Theme.of(context).dividerColor),
          ],
        ),
      ),
    );
  }
}
