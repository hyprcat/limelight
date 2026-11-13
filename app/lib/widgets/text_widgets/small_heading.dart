import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class SmallHeading extends StatefulWidget {
  final String txt;
  const SmallHeading({super.key, required this.txt});

  @override
  State<SmallHeading> createState() => _SmallHeadingState();
}

class _SmallHeadingState extends State<SmallHeading> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(widget.txt,
          style: defaultLabelText(context,
              fontWeight: FontWeight.bold,
              fontColor: Theme.of(context).colorScheme.primary)),
    );
  }
}
