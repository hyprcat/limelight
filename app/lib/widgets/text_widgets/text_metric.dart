// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class TextMetric extends StatelessWidget {
  final String value;
  final String label;
  final bool reverse;
  bool compact;
  Color? labelColor;
  Color? valueColor;
  bool? bold;
  TextMetric(
      {super.key,
      required this.label,
      required this.value,
      this.bold = true,
      this.compact = false,
      required this.reverse,
      this.labelColor,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    if (reverse) {
      return RichText(
          text: TextSpan(children: [
        TextSpan(
            text: value,
            style: compact
                ? defaultVerySmallLabelCustom(context,
                    fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                    fontColor: valueColor)
                : defaultSmallLabel(context,
                    fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                    fontColor: valueColor)),
        TextSpan(
            text: " $label",
            style: compact
                ? defaultVerySmallLabelCustom(
                    context,
                    fontColor: labelColor,
                    fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                  )
                : defaultSmallLabel(
                    context,
                    fontColor: labelColor,
                    fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                  )),
      ]));
    }
    return RichText(
        text: TextSpan(children: [
      TextSpan(
          text: label,
          style: compact
              ? defaultVerySmallLabelCustom(
                  context,
                  fontColor: labelColor,
                  fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                )
              : defaultSmallLabel(
                  context,
                  fontColor: labelColor,
                  fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                )),
      TextSpan(
          text: " $value",
          style: compact
              ? defaultVerySmallLabelCustom(context,
                  fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                  fontColor: valueColor)
              : defaultSmallLabel(context,
                  fontWeight: !bold! ? FontWeight.w600 : FontWeight.bold,
                  fontColor: valueColor)),
    ]));
  }
}
