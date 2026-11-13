import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

TextStyle defaultNormalText(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.w700}) {
  fontColor ??= Theme.of(context).textTheme.bodyMedium!.color;
  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight!,
    shadows: [
      Shadow(
        color: Colors.blue.shade900.withOpacity(0.4),
        offset: const Offset(1, 1),
        blurRadius: 0,
      ),
    ],
    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
  );
}

TextStyle defaultHeadingText(BuildContext context,
    {Color? fontColor,
    FontWeight? fontWeight = FontWeight.bold,
    double? fontsize}) {
  fontColor ??= Theme.of(context).textTheme.titleLarge!.color;

  return TextStyle(
    color: fontColor,
    height: 1.2,
    fontWeight: fontWeight!,
    fontSize: fontsize ?? Theme.of(context).textTheme.headlineSmall!.fontSize,
  );
}

TextStyle defaultHeadingXText(BuildContext context,
    {Color? fontColor,
    FontWeight? fontWeight = FontWeight.w800,
    double? fontsize}) {
  fontColor ??= Theme.of(context).textTheme.titleLarge!.color;

  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight!,
    shadows: [
      Shadow(
        color: Colors.blue.shade900.withOpacity(0.4),
        offset: const Offset(1, 1),
        blurRadius: 0,
      ),
    ],
    fontSize: fontsize ?? Theme.of(context).textTheme.bodyLarge!.fontSize,
  );
}

TextStyle defaultHeadingTextGrotesk(BuildContext context,
    {Color? fontColor,
    FontWeight? fontWeight = FontWeight.w800,
    double? fontsize}) {
  fontColor ??= Theme.of(context).textTheme.titleLarge!.color;
  TextStyle? style = Theme.of(context).textTheme.headlineSmall;

  return GoogleFonts.roboto(
    letterSpacing: 0,
    fontWeight: fontWeight,
    textStyle: style,
    fontSize: fontsize ?? style!.fontSize!,
    color: fontColor!,
  );
}

TextStyle defaultLabelText(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight!,
    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
  );
}

TextStyle defaultLabelTextC(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight!,
    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
  );
}

TextStyle defaultLabelTextForPost(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  return TextStyle(
    overflow: TextOverflow.fade,
    color: fontColor,
    fontWeight: fontWeight!,
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
  );
}

TextStyle defaultLabelXText(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight!,
      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize);
}

TextStyle defaultLabelTextItalic(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  return GoogleFonts.raleway(
    textStyle: TextStyle(
      overflow: TextOverflow.fade,
      fontWeight: fontWeight,
      fontStyle: FontStyle.italic,
      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
    ),
    color: fontColor!,
  );
}

TextStyle defaultSmallLabel(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight!,
      fontSize: Theme.of(context).textTheme.labelLarge!.fontSize);
}

TextStyle defaultSmallXLabelCustom(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight!,
    fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
  );
}

TextStyle defaultVerySmallLabel(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight,
      fontSize: Theme.of(context).textTheme.labelMedium!.fontSize);
}

TextStyle defaultVerySmallLabelCustom(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
  );
}

TextStyle defaultVerySmallLabelAlternative(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;

  return TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
  );
}

TextStyle defaultEvenVerySmallLabel(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight,
      fontSize: Theme.of(context).textTheme.labelSmall!.fontSize);
}

TextStyle defaultEvenVerySmallLabelCustom(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight,
      fontSize: Theme.of(context).textTheme.labelSmall!.fontSize);
}

TextStyle defaultEvenVerySmallLabelAlternate(BuildContext context,
    {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return TextStyle(
      color: fontColor,
      fontWeight: fontWeight,
      fontSize: Theme.of(context).textTheme.labelSmall!.fontSize);
}
