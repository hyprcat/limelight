// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/playlist.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:loading_indicator/loading_indicator.dart';

class EditPlaylist extends StatefulWidget {
  final bool editMode;
  final Function callback;
  PlayList? playlist;
  EditPlaylist(
      {required this.editMode,
      required this.callback,
      this.playlist,
      super.key});

  @override
  State<EditPlaylist> createState() => _EditPlaylistState();
}

class _EditPlaylistState extends State<EditPlaylist> {
  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        child: TextField(
          keyboardType: type,
          style: defaultSmallLabel(context),
          controller: control,
          maxLines: null,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: txt,
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).disabledColor),
          ),
        ));
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    if (widget.editMode && widget.playlist != null) {
      nameController.text = widget.playlist!.name.toString();
      descriptionController.text = widget.playlist!.description.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.editMode ? "Modify Playlist" : "Create Playlist",
          style: defaultNormalText(context, fontWeight: FontWeight.bold),
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
                    "Playlist Name",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  _textField("Songs, Watch Later, Knowledge etc..",
                      nameController, TextInputType.text, 60),
                  Text(
                    "Playlist Description",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  _textField("What's this playlist about?",
                      descriptionController, TextInputType.text, 120),
                  PrimaryFocusButton(
                      label: 'Okay',
                      callback: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        widget.callback(
                            nameController.text, descriptionController.text);
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
    );
  }
}
