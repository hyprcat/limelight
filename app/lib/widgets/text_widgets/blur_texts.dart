import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

Widget buildBlurHeadingButton(
    BuildContext context, String text, IconData iconData) {
  return SizedBox(
    height: 30,
    child: Row(
      children: [
        Icon(
          iconData,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text,
            style: defaultHeadingText(context, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget buildBlurTextButton(
    BuildContext context, String text, IconData iconData) {
  return InkWell(
    onTap: () {},
    child: SizedBox(
      height: 50,
      child: Row(
        children: [
          Icon(iconData),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(text,
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.normal))),
        ],
      ),
    ),
  );
}
