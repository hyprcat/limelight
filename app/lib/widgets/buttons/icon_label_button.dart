import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class IconLabelButton extends StatefulWidget {
  final IconData icon;

  final String label;
  final bool isBig;
  final Color? iconColor;
  final bool vertical;
  const IconLabelButton(
      {super.key,
      required this.icon,
      required this.label,
      this.iconColor,
      this.isBig = true,
      this.vertical = false});

  @override
  State<IconLabelButton> createState() => _IconLabelButtonState();
}

class _IconLabelButtonState extends State<IconLabelButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 5,
          ),
          Icon(
            widget.icon,
            size: widget.isBig ? 24 : 19,
            color: widget.iconColor ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              widget.label,
              maxLines: 2,
              style: widget.isBig
                  ? defaultNormalText(context,
                      fontWeight: FontWeight.w500,
                      fontColor: widget.iconColor ??
                          Theme.of(context).colorScheme.primary)
                  : defaultSmallXLabelCustom(
                      context,
                      fontWeight: FontWeight.w500,
                      fontColor: widget.iconColor ??
                          Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 5,
        ),
        Icon(
          widget.icon,
          size: widget.isBig ? 25 : 19,
          color: widget.iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          widget.label,
          maxLines: 2,
          style: widget.isBig
              ? defaultLabelText(context,
                  fontWeight: FontWeight.w500,
                  fontColor:
                      widget.iconColor ?? Theme.of(context).colorScheme.primary)
              : defaultSmallXLabelCustom(
                  context,
                  fontWeight: FontWeight.w500,
                  fontColor:
                      widget.iconColor ?? Theme.of(context).colorScheme.primary,
                ),
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }
}
