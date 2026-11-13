import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

TextStyle defaultNormalText(BuildContext context, {Color? fontColor, FontWeight? fontWeight = FontWeight.bold}) {
  fontColor ??= Theme.of(context).textTheme.bodyMedium!.color;
  return GoogleFonts.poppins(
    fontWeight: fontWeight,
    textStyle: Theme.of(context).textTheme.bodyMedium,
    color: fontColor!,
  );
}

TextStyle defaultHeadingText(BuildContext context, {Color? fontColor, FontWeight? fontWeight = FontWeight.bold, double? fontsize}) {
  fontColor ??= Theme.of(context).textTheme.titleLarge!.color;

  TextStyle? style = Theme.of(context).textTheme.titleLarge;
  return GoogleFonts.poppins(
    letterSpacing: 0,
    fontWeight: fontWeight,
    textStyle: style,
    fontSize: fontsize ?? style!.fontSize!,
    color: fontColor!,
  );
}

TextStyle defaultLabelText(BuildContext context, {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return GoogleFonts.poppins(
    textStyle: TextStyle(
      overflow: TextOverflow.fade,
      fontWeight: fontWeight,
      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
    ),
    color: fontColor!,
  );
}

TextStyle defaultDarkLabelText(BuildContext context, {Color? fontColor}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return GoogleFonts.poppins(
    fontWeight: FontWeight.normal,
    textStyle: Theme.of(context).textTheme.labelLarge,
    color: fontColor ?? Theme.of(context).primaryColorDark,
  );
}

TextStyle defaultSmallLabel(BuildContext context, {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return GoogleFonts.raleway(
    fontWeight: fontWeight,
    textStyle: Theme.of(context).textTheme.labelMedium,
    color: fontColor ?? Theme.of(context).primaryColorDark,
  );
}

TextStyle defaultVerySmallLabel(BuildContext context, {Color? fontColor, FontWeight? fontWeight = FontWeight.normal}) {
  fontColor ??= Theme.of(context).textTheme.labelLarge!.color;
  return GoogleFonts.raleway(
    fontWeight: fontWeight,
    textStyle: Theme.of(context).textTheme.labelSmall,
    color: fontColor ?? Theme.of(context).primaryColorDark,
  );
}
