import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/engines/video_engine.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:code_arrow_creator_studio/screens/home/home.dart';
import 'package:code_arrow_creator_studio/widgets/check_box_title.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:code_arrow_creator_studio/widgets/throw_error_snackbar.dart';
import 'package:code_arrow_creator_studio/widgets/throw_happy_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class SecondPart extends StatefulWidget {
  final VideoPost video;
  const SecondPart({super.key, required this.video});

  @override
  State<SecondPart> createState() => _SecondPartState();
}

class _SecondPartState extends State<SecondPart> {
  String date = '';
  List<String> types = ['public', 'draft', 'unlisted', 'lounge-only', 'scheduled'];
  List<bool> options = List.generate(5, (index) => false);

  void _checkBoxCallback(index) {
    options = List.generate(5, (index) => false);
    options[index] = true;
    setState(() {});
  }

  void updateCallBack() async {
    Map<String, dynamic> typeMap = Map.fromIterables(types, options);
    typeMap['token'] = sessionData!['token'];
    typeMap['video_id'] = widget.video.id;
    typeMap['scheduled_date'] = date;

    if (typeMap['scheduled'] && date == '') {
      throwErrorSnackBar(context, "Choose a date for when you want your video to go public.");
    }
    var response = await VideoEngine().updateVideoStatus(typeMap);
    if (response == "success") {
      throwHappySnackBar(context, "Operation successful.");
    } else {
      throwErrorSnackBar(context, response);
    }
    var newStateList = List.generate(11, (index) => false);
    newStateList[0] = true;
    CreatorStudioHome.selectedThing = newStateList;
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget _buildBody() {
    List<Widget> children = [
      Text("Visibility", style: defaultHeadingText(context)),
      SelectableText("Choose when to publish and who can see your video", style: defaultSmallLabel(context)),
      CheckBoxWidget(
        status: options[0],
        callback: _checkBoxCallback,
        label: "Make my video visible to everyone",
        index: 0,
      ),
      CheckBoxWidget(
        status: options[1],
        callback: _checkBoxCallback,
        label: "Save my video as a draft. Only you can see it.",
        index: 1,
      ),
      CheckBoxWidget(
          status: options[2],
          callback: _checkBoxCallback,
          label: "Save my video as unlisted. You can have a sharable link that you can send it to others.",
          index: 2),
      CheckBoxWidget(
        status: options[3],
        callback: _checkBoxCallback,
        label: "Make this video exclusive to members of lounge.",
        index: 3,
      ),
      CheckBoxWidget(status: options[4], callback: _checkBoxCallback, label: "Schedule this video.", index: 4),
      SelectableText("In case if you are scheduling a video, then select the Time and Date from below.", style: defaultSmallLabel(context)),
      DateTimePicker(
        initialValue: '',
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        dateLabelText: 'Date',
        type: DateTimePickerType.dateTime,
        onChanged: (val) {
          date = val;
        },
        validator: (val) {
          date = val!;
          return null;
        },
        onSaved: (val) {
          date = val!;
        },
      ),
      PrimaryFocusButton(label: "Update", callback: updateCallBack),
      const SizedBox(
        height: 100,
      )
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        alignment: Alignment.topCenter,
        child: DynMouseScroll(builder: (context, controller, physics) {
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
