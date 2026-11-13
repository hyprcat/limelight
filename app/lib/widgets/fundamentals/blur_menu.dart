import 'dart:ui';

import 'package:flutter/material.dart';

void showBlurMenu(List<Widget> children, BuildContext context,
    {bool? half = false, bool? evenDarker = false}) {
  showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: evenDarker! ? Colors.black87 : Colors.black45,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (ctx, anim1, anim2) => GestureDetector(
      onTap: () {
        BuildContext dialogContext = ctx;
        Navigator.pop(dialogContext);
      },
      child: SingleChildScrollView(
        reverse: true,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      half!
                          ? Expanded(flex: 2, child: Container())
                          : Container(),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            for (Widget i in children) i,
                            const SizedBox(
                              height: 150,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
      filter:
          ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
      child: FadeTransition(
        opacity: anim1,
        child: child,
      ),
    ),
    context: context,
  );
}
