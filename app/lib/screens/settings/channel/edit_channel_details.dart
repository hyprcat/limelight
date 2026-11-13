// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/users/user_channel.dart';

import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';

class EditChannelDetails extends StatefulWidget {
  final UserChannel channel;
  final Function refreshCallback;
  const EditChannelDetails(
      {super.key, required this.refreshCallback, required this.channel});

  @override
  State<EditChannelDetails> createState() => _EditChannelDetailsState();
}

class _EditChannelDetailsState extends State<EditChannelDetails> {
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        child: TextField(
          keyboardType: type,
          style: defaultSmallLabel(context),
          controller: control,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: txt,
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).disabledColor),
          ),
        ));
  }

  TextEditingController channelNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    channelNameController.text = widget.channel.name!;
    descriptionController.text = widget.channel.channelDescription!.isEmpty
        ? "A Standard LimeLight Profile."
        : widget.channel.channelDescription!;
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Theme.of(context).canvasColor,
        title: Text(
          "Edit Channel Details",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary
                    ],
                    strokeWidth: 2,
                    backgroundColor: Theme.of(context).canvasColor,
                    pathBackgroundColor: Theme.of(context).canvasColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ListView(
                children: [
                  Text(
                    "Channel Name",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  _textField("Try something catchy..", channelNameController,
                      TextInputType.text, 120),
                  Text(
                    "Description",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  _textField("Tell about yourself.", descriptionController,
                      TextInputType.text, 300),
                  PrimaryFocusButton(
                      label: 'Update Info',
                      callback: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }

                        if (channelNameController.text.isEmpty) {
                          throwErrorSnackBar(
                              context, "Channel name can't be empty.");
                          return;
                        }

                        if (descriptionController.text.isEmpty) {
                          throwErrorSnackBar(
                              context, "Description can't be empty.");
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        var data = {
                          'token': sessionData!['token'],
                          'channel_name': channelNameController.text,
                          'description': descriptionController.text
                        };

                        bool status =
                            await UserEngine().updateChannelDetails(data);
                        if (status) {
                          throwHappySnackBar(context, "Successfully updated.");
                          widget.refreshCallback();
                          Navigator.pop(context);
                        } else {
                          throwErrorSnackBar(
                              context, "Couldn't update. Please try again.");
                        }
                        setState(() {
                          isLoading = false;
                        });
                      })
                ],
              ),
            ),
    );
  }
}
