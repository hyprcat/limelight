import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:flutter/material.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  RichText _buildLogo() {
    return RichText(
      text: TextSpan(text: 'Lime', style: defaultHeadingText(context, fontColor: Theme.of(context).colorScheme.primary), children: [
        TextSpan(
          text: '.',
          style: defaultHeadingText(context, fontColor: Colors.red),
        ),
        TextSpan(text: 'ai', style: defaultHeadingText(context, fontColor: Theme.of(context).colorScheme.primary)),
        TextSpan(text: ' Creator Studio', style: defaultSmallLabel(context, fontWeight: FontWeight.bold))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLogo();
  }
}
