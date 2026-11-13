// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';

import 'package:lime_time_app/main.dart';

class CheckBoxWidget extends StatefulWidget {
  bool status;
  final Function callback;
  final String label;
  int index;
  CheckBoxWidget(
      {super.key,
      required this.status,
      required this.callback,
      required this.label,
      this.index = -1});

  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CheckboxListTile(
        title: Text(
          widget.label,
          style: defaultLabelText(context,
              fontColor: Theme.of(context).colorScheme.primary),
        ),
        value: widget.status,
        onChanged: (newValue) {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          analytics!.logEvent(
              name: "checkbox_button: ${widget.label}",
              parameters: <String, Object>{
                'user_id': authHandler.loggedInUser!.userId!.toString(),
              });
          if (widget.index != -1) {
            widget.callback(widget.index);
          } else {
            widget.callback(newValue);
          }
        },
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
