import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/upload_video/upload_file_card.dart';
import 'package:lime_time_app/widgets/buttons/check_box_title.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class SecondPart extends StatefulWidget {
  final VideoPost video;
  const SecondPart({super.key, required this.video});

  @override
  State<SecondPart> createState() => _SecondPartState();
}

class _SecondPartState extends State<SecondPart> {
  String date = '';
  List<String> types = [
    'public',
    'draft',
    'unlisted',
    'lounge-only',
    'scheduled'
  ];
  List<bool> options = [false, true, false, false, false];

  void _checkBoxCallback(index) {
    options = List.generate(5, (index) => false);
    options[index] = true;
    setState(() {});
  }

  @override
  void initState() {
    if (videoPlayerController.value != null) {
      videoPlayerController.value!.dispose(forceDispose: true);
      videoPlayerController.value = null;
    }
    invalidateAllControllers();
    playerWidget.value = null;
    super.initState();
  }

  void updateCallBack() async {
    if (!options.contains(true)) {
      options[1] = true;
    }
    Map<String, dynamic> typeMap = Map.fromIterables(types, options);
    typeMap['token'] = sessionData!['token'];
    typeMap['video_id'] = widget.video.id;
    typeMap['scheduled_date'] = date;

    if (typeMap['scheduled'] && date == '') {
      throwErrorSnackBar(
          context, "Choose a date for when you want your video to go public.");
      return;
    }
    var response = await VideoEngine().updateVideoStatus(typeMap);
    if (response == "success") {
      throwHappySnackBar(context, "Video successfully modified.");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ImportVideoCard()));
    } else {
      throwErrorSnackBar(context, response);
    }
  }

  Widget _buildBody() {
    List<Widget> children = [
      Text("Visibility", style: defaultHeadingText(context)),
      SelectableText("Choose when to publish and who can see your video",
          style: defaultSmallLabel(context)),
      CheckBoxWidget(
        status: options[0],
        callback: _checkBoxCallback,
        label: "Make my video visible to everyone",
        index: 0,
      ),
      CheckBoxWidget(
        status: options[1],
        callback: _checkBoxCallback,
        label: "Save my video as a draft. Only you can see it on your channel.",
        index: 1,
      ),
      PrimaryFocusButton(label: "Update", callback: updateCallBack),
      const SizedBox(
        height: 100,
      )
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.topCenter,
        child: DynMouseScroll(
            durationMS: 200,
            scrollSpeed: 4.4,
            animationCurve: Curves.easeInOut,
            builder: (context, controller, physics) {
              return ListView(
                shrinkWrap: true,
                controller: controller,
                physics: physics,
                addAutomaticKeepAlives: true,
                children: children,
              );
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
