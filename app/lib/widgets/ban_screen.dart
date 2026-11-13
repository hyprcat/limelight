import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorBanned extends StatefulWidget {
  UserProfile? profile;
  ErrorBanned({super.key, this.profile});

  @override
  State<ErrorBanned> createState() => _ErrorBannedState();
}

class _ErrorBannedState extends State<ErrorBanned> {
  @override
  Widget build(BuildContext context) {
    RichText buildRichText() {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text:
                "If you think this is a mistake, Contact us on our support@hazel.gg to appeal for unbanning your account.",
            style: defaultLabelTextC(context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold),
            children: const []),
      );
    }

    AppBar buildAppbar() {
      return AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        scrolledUnderElevation: 1,
      );
    }

    String headerText() {
      if (widget.profile == null) {
        return "You have been banned from LimeLight.";
      }

      return "${widget.profile!.userName!} is banned from LimeLight";
    }

    Widget body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Iconsax.forbidden_outline,
            size: 100,
            color: Colors.redAccent,
          ),
          Text(
            headerText(),
            style: defaultHeadingText(context, fontsize: 25),
            textAlign: TextAlign.center,
          ),
          if (widget.profile == null) buildRichText(),
          const SizedBox(
            height: 20,
          ),
          PrimaryFocusButton(
              highLight: true,
              useRoundedCorner: true,
              label: widget.profile == null ? 'Reach our support' : 'Go back',
              callback: () async {
                if (widget.profile == null) {
                  final Uri url =
                      Uri.parse('https://forms.gle/S3V4hGuGYfkgnErh6');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                } else {
                  Navigator.of(context, rootNavigator: false).pop(context);
                }
              }),
          const Spacer(),
          if (widget.profile == null)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () async {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.selectionClick();
                          final Uri url = Uri.parse(privacyPolicyUrl);
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text("Privacy Policy",
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor: Theme.of(context).disabledColor))),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.selectionClick();
                          final Uri url =
                              Uri.parse('https://forms.gle/S3V4hGuGYfkgnErh6');
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text("Need Help?",
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.w600,
                                fontColor: Theme.of(context).disabledColor))),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                ),
                Text("App Version: $VERSION",
                    style: defaultVerySmallLabel(context,
                        fontColor: Theme.of(context).disabledColor)),
                Text(
                  "Hazel Communications Private Limited, 2024",
                  textAlign: TextAlign.center,
                  style: defaultVerySmallLabel(context,
                      fontColor: Theme.of(context).disabledColor),
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            )
        ],
      ),
    );

    return Scaffold(appBar: buildAppbar(), body: body);
  }
}
