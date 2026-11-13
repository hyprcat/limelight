import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/bloc/account_deletion/account_deletion_bloc.dart';
import 'package:lime_time_app/widgets/buttons/check_box_title.dart';

class DataAccess extends StatefulWidget {
  const DataAccess({super.key});

  @override
  State<DataAccess> createState() => _DataAccessState();
}

class _DataAccessState extends State<DataAccess> {
  AccountDeletionBloc bloc = AccountDeletionBloc();
  @override
  void initState() {
    bloc.add(LoadAccountDeletionEvent());
    super.initState();
  }

  Widget headingBuilder(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: defaultHeadingText(context),
      ),
    );
  }

  Widget warningText(String text) {
    return Text(text, style: defaultSmallLabel(context, fontColor: Colors.red));
  }

  Widget infoText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).hintColor)),
    );
  }

  bool agree_one = false;
  bool agree_two = false;
  final TextEditingController _description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            headingBuilder("Account Deletion"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please note that",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor),
              ),
            ),
            infoText(
                '-> All your posts, videos, comments, and images will be permanently deleted from our platform. This action is irreversible, and once completed, the content cannot be recovered. '),
            infoText(
                "-> Any likes, shares, comments, or other forms of engagement on your content will also be deleted. Your profile will be removed from search results and community interactions."),
            infoText(
                '-> Your followers and subscribers will no longer be able to view your content. Any ongoing interactions or communications will be interrupted.'),
            infoText(
                '-> If your account is linked to other services, including monetization or partnerships, those will be terminated as part of the deletion process.'),
            infoText(
                '-> Before proceeding, ensure you have backed up any content you wish to keep, as all your data will be permanently erased.'),
            infoText(
                '-> Your profile and all data associated will be deleted after 72 hours of placing the request.'),
            CheckBoxWidget(
                status: agree_one,
                callback: (value) {
                  setState(() {
                    agree_one = value;
                  });
                },
                label:
                    'I understand the risks and consequences related to my account deletion'),
            PrimaryFocusButton(
                label: 'Proceed',
                callback: () {
                  if (agree_one) {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black45,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (BuildContext buildContext,
                            Animation animation, Animation secondaryAnimation) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(
                                  left: 20, right: 20, top: 50, bottom: 50),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor)),
                              child: Material(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Are you sure that you want to delete everything?",
                                      style: defaultHeadingText(context)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SelectableText(
                                      "Once deleted, You can't recover anything back.",
                                      style: defaultSmallLabel(context)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: TextField(
                                      maxLines: null,
                                      controller: _description,
                                      style: defaultNormalText(context,
                                          fontWeight: FontWeight.w500),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Please tells us how we can improve our services.',
                                        hintStyle: defaultSmallLabel(context,
                                            fontColor:
                                                Theme.of(context).hintColor),
                                      ),
                                      onChanged: (text) {},
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  PrimaryFocusButton(
                                      alternateColor:
                                          Colors.red.shade800.withOpacity(0.6),
                                      label: "Yes, Proceed ahead.",
                                      callback: () async {
                                        if (_description.text == null ||
                                            _description.text == "") {
                                          throwErrorSnackBar(context,
                                              'Please provide feedback in order to proceed');
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                          return;
                                        }
                                        var response = await UserEngine()
                                            .addUserAccountRemoval(
                                                _description.text);
                                        if (response == "success") {
                                          throwErrorSnackBar(context,
                                              "Account deletion request successful. Sorry to see you go away. ");
                                        } else {
                                          throwErrorSnackBar(context,
                                              "Request failed. Please try again later.");
                                        }
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        return;
                                      }),
                                ],
                              )),
                            ),
                          );
                        });
                  } else {
                    throwErrorSnackBar(context,
                        'You cannot delete your account without declaring consent.');
                  }
                }),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "After submitting your request to delete your account, you have up to 72 hours to cancel it if you change your mind. To do so, please contact us at support@hazel.gg.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 150,
            ),
          ],
        ),
      );
    }

    RichText buildRichText() {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text:
                "If you think this is a mistake, Contact us on our support@hazel.gg to remove your request.",
            style: defaultLabelTextC(context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold),
            children: const []),
      );
    }

    Widget sorryToSeeYouGo = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Iconsax.emoji_sad_outline,
            size: 100,
            color: Colors.redAccent,
          ),
          Text(
            "Sorry to see you go.",
            style: defaultHeadingText(context, fontsize: 25),
            textAlign: TextAlign.center,
          ),
          buildRichText(),
          const SizedBox(
            height: 20,
          ),
          PrimaryFocusButton(
              highLight: true,
              useRoundedCorner: true,
              label: 'Reach our support',
              callback: () async {
                final Uri url =
                    Uri.parse('https://forms.gle/S3V4hGuGYfkgnErh6');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              }),
          const Spacer(),
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

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
          surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
          titleSpacing: 0,
          title: Text(
            "Manage your data",
            style: defaultLabelText(context, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        body: BlocConsumer<AccountDeletionBloc, AccountDeletionState>(
          bloc: bloc,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AccDeletionPageSuccess) {
              if (state.status) {
                return sorryToSeeYouGo;
              }
              return body();
            }
            return Container();
          },
        ));
  }
}
