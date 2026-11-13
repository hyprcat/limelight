// ignore_for_file: unused_field, unused_local_variable, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/global.dart';

import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/main.dart';

class ArrowButton extends StatefulWidget {
  final String label;
  final String description;
  final Function? callback;
  final int index;
  final bool isPlaylist;
  Icon? icon;
  ArrowButton(
      {super.key,
      required this.label,
      required this.description,
      required this.callback,
      required this.index,
      this.icon,
      this.isPlaylist = false});

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  final bool _isHovering = false;

  Color _buildArrowColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 10, bottom: 5, top: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        onTap: () {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          analytics!.logEvent(
              name: "arrow_button: ${widget.label}",
              parameters: <String, Object>{
                'user_id': authHandler.loggedInUser!.userId!.toString(),
              });
          widget.callback!();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.icon != null ? widget.icon! : Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: widget.isPlaylist
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        widget.label,
                        style: defaultLabelTextC(context,
                            fontWeight: FontWeight.w700),
                      )),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(widget.description,
                          style: defaultSmallXLabelCustom(context,
                              fontColor: Theme.of(context).hintColor,
                              fontWeight: (widget.isPlaylist)
                                  ? FontWeight.w500
                                  : FontWeight.w500),
                          maxLines: 2)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward,
                color: _buildArrowColor(context), size: 18)
          ],
        ),
      ),
    );
  }
}
