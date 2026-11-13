import 'package:flutter/material.dart';

import 'package:lime_time_app/defaults/fonts.dart';

void throwErrorSnackBar(BuildContext context, String label) {
  final snackBar = SnackBar(
    margin: const EdgeInsets.only(bottom: 100),
    elevation: 5,
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    content: Text(label,
        style: defaultLabelText(context,
            fontColor: Colors.white, fontWeight: FontWeight.bold)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
