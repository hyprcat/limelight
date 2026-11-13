// ignore_for_file: use_build_context_synchronously

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';

class FullBannerView extends StatefulWidget {
  final UserProfile userObj;
  const FullBannerView({super.key, required this.userObj});

  @override
  State<FullBannerView> createState() => _FullBannerViewState();
}

class _FullBannerViewState extends State<FullBannerView> {
  MultipartFile? file;
  File? displayFile;

  Widget _buildChild() {
    if (displayFile != null) {
      return Image.file(
        File(displayFile!.path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    if (widget.userObj.profileBanner != null) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: AspectRatio(
            aspectRatio: 32 / 9,
            child: Image.network(
              userBannerUrl(widget.userObj.userName),
              errorBuilder: (BuildContext context, _, __) {
                return AspectRatio(
                  aspectRatio: 32 / 9,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    )),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: RichText(
                          text: TextSpan(
                              text: "LimeLight.",
                              style: defaultHeadingText(context,
                                  fontColor: Theme.of(context)
                                      .cardColor
                                      .withAlpha(200),
                                  fontsize: 40),
                              children: const []),
                        )),
                  ),
                );
              },
              fit: BoxFit.cover,
            )),
      );
    }
    return AspectRatio(
      aspectRatio: 21 / 9,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        )),
        child: Align(
            alignment: Alignment.bottomRight,
            child: RichText(
              text: TextSpan(
                  text: "LimeLight.",
                  style: TextStyle(
                      fontFamily: 'LL_BAGUIO',
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize!,
                      color: Theme.of(context).canvasColor.withAlpha(200)),
                  children: const []),
            )),
      ),
    );
  }

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${widget.userObj.userName}",
          style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Center(child: _buildChild()),
          if (authHandler.loggedInUser!.userId! == widget.userObj.userId!)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 60,
                  margin: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.image, withData: true);

                            if (result != null) {
                              displayFile = File(result.files.single.path!);
                              file = await MultipartFile.fromFile(
                                  displayFile!.path);
                              setState(() {});
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: _backgroundWrapper([
                            Icon(
                              Icons.photo,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Select a new picture",
                              style: defaultSmallLabel(context,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ]),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () async {
                            bool status =
                                await UserEngine().deleteProfileBanner();
                            if (status) {
                              throwHappySnackBar(
                                  context, "Successfully removed.");
                              Navigator.pop(context);
                            } else {
                              throwErrorSnackBar(context,
                                  "Couldn't remove. Please try again.");
                            }
                          },
                          child: _backgroundWrapper([
                            Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Remove",
                              style: defaultSmallLabel(context,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ]),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        displayFile != null
                            ? InkWell(
                                onTap: () async {
                                  bool status = await UserEngine()
                                      .uploadUserProfileBanner(file);
                                  if (status) {
                                    throwHappySnackBar(
                                        context, "Successfully updated.");
                                    Navigator.pop(context);
                                  } else {
                                    throwErrorSnackBar(context,
                                        "Couldn't save. Please try again.");
                                  }
                                },
                                child: _backgroundWrapper([
                                  Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Save",
                                    style: defaultSmallLabel(context,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                ]),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: Platform.isIOS ? 80 : 50,
                )
              ],
            )
        ],
      ),
    );
  }
}
