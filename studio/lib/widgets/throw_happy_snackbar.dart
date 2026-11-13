import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:flutter/material.dart';

void throwHappySnackBar(BuildContext context, String label) {
  final snackBar = SnackBar(
    width: 600,
    elevation: 5,
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    content: Text(label, style: defaultLabelText(context, fontColor: Colors.white)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
