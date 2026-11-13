import 'package:code_arrow_creator_studio/defaults/colors.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:flutter/material.dart';

class PrimaryFocusButton extends StatefulWidget {
  final String label;
  final Function callback;
  const PrimaryFocusButton({super.key, required this.label, required this.callback});

  @override
  State<PrimaryFocusButton> createState() => _PrimaryFocusButtonState();
}

class _PrimaryFocusButtonState extends State<PrimaryFocusButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 200,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        onTap: () {
          widget.callback();
        },
        onHover: (hovering) {
          if (hovering) {
            activeColor = hoverColor;
          } else {
            activeColor = buttonColor;
          }
          setState(() {});
        },
        child: Center(
          child: Text(
            widget.label,
            style: defaultLabelText(context, fontColor: Theme.of(context).canvasColor),
          ),
        ),
      ),
    );
  }
}
