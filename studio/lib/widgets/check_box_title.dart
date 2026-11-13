// ignore_for_file: must_be_immutable

import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:flutter/material.dart';

class CheckBoxWidget extends StatefulWidget {
  bool status;
  final Function callback;
  final String label;
  int index;
  CheckBoxWidget({super.key, required this.status, required this.callback, required this.label, this.index = -1});

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
          style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary),
        ),
        value: widget.status,
        onChanged: (newValue) {
          if (widget.index != -1) {
            widget.callback(widget.index);
          } else {
            widget.callback(newValue);
          }
        },
        controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
