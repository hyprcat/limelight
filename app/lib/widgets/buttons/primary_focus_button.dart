// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/colors.dart';

import 'package:lime_time_app/defaults/fonts.dart';

class PrimaryFocusButton extends StatefulWidget {
  final String label;
  final Function callback;
  bool highLight;
  Widget? suffix;
  bool compact;
  bool useRoundedCorner;
  bool? showArrow;
  Color? alternateColor;
  PrimaryFocusButton(
      {super.key,
      required this.label,
      required this.callback,
      this.suffix,
      this.alternateColor,
      this.useRoundedCorner = false,
      this.highLight = false,
      this.compact = false,
      this.showArrow = true});

  @override
  State<PrimaryFocusButton> createState() => _PrimaryFocusButtonState();
}

class _PrimaryFocusButtonState extends State<PrimaryFocusButton> {
  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).cardColor;
    Color textColor =
        primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    if (widget.alternateColor != null) {
      primary = widget.alternateColor!;
      textColor = Theme.of(context).colorScheme.inverseSurface;
    }

    return InkWell(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        margin: EdgeInsets.only(
            top: 5, left: 5, bottom: widget.useRoundedCorner ? 0 : 5),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 2),
            color: widget.alternateColor ??
                (widget.highLight
                    ? Theme.of(context).colorScheme.inverseSurface
                    : Theme.of(context).cardColor),
            borderRadius:
                BorderRadius.circular(widget.useRoundedCorner ? 40 : 8)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.suffix ?? Container(),
              widget.suffix == null
                  ? const SizedBox()
                  : const SizedBox(
                      width: 15,
                    ),
              Text(
                widget.label,
                style: widget.compact
                    ? defaultVerySmallLabelCustom(context,
                        fontWeight: FontWeight.w500,
                        fontColor: widget.highLight
                            ? Theme.of(context).colorScheme.surface
                            : textColor)
                    : defaultSmallLabel(context,
                        fontWeight: FontWeight.w500,
                        fontColor: widget.highLight
                            ? Theme.of(context).colorScheme.surface
                            : textColor),
              ),
              !widget.highLight
                  ? widget.showArrow!
                      ? const SizedBox(
                          width: 10,
                        )
                      : Container()
                  : Container(),
              !widget.highLight
                  ? widget.showArrow!
                      ? Icon(
                          Icons.arrow_forward,
                          size: widget.compact ? 15 : 18,
                          color: textColor,
                        )
                      : Container()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
