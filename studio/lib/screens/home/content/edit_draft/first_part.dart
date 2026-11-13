// ignore_for_file: camel_case_types, unused_field

import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'package:code_arrow_creator_studio/defaults/constants.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/widgets/check_box_title.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:code_arrow_creator_studio/widgets/throw_error_snackbar.dart';
import 'package:code_arrow_creator_studio/widgets/video_player.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:language_picker/language_picker_dropdown.dart';
import 'package:language_picker/languages.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class EditDraft_I extends StatefulWidget {
  final VideoPost video;
  final Function? callback;
  const EditDraft_I({super.key, required this.video, required this.callback});

  @override
  State<EditDraft_I> createState() => _EditDraft_IState();
}

class _EditDraft_IState extends State<EditDraft_I> {
  bool _isLoading = false;
  final bool _isUploading = false;
  bool _isPaidPromotion = false;
  bool _isAgeRestricted = false;
  bool _thumbnailChanged = false;
  String _selectedTopic = "Entertainment";
  Language selectedLanguage = Languages.english;

  FilePickerResult? thumbnailResult;
  MultipartFile? thumbnail;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  void _loadVideoData() {
    _title.text = widget.video.title ?? "";
    _description.text = widget.video.videoDescription ?? "";
    _isAgeRestricted = widget.video.isAgeRestricted ?? false;
    _isPaidPromotion = widget.video.isAdvertisement ?? false;
    setState(() {});
  }

  void _selectThumbnailCallback() async {
    setState(() {
      _isLoading = true;
    });
    thumbnailResult = await FilePicker.platform.pickFiles(type: FileType.image);
    if (thumbnailResult != null) {
      thumbnail = MultipartFile.fromBytes(thumbnailResult!.files.first.bytes!,
          contentType: MediaType('image', 'jpeg'), filename: thumbnailResult!.files.first.name);
    } else {
      // User canceled the picker
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _proceedData() async {
    if (_title.text.isEmpty) {
      Navigator.pop(context);
      throwErrorSnackBar(context, "Title seems empty.");
      return;
    }

    if (_description.text.isEmpty) {
      Navigator.pop(context);
      throwErrorSnackBar(context, "Description seems empty.");
      return;
    }

    if (widget.video.thumbnail == null && thumbnail == null) {
      Navigator.pop(context);
      throwErrorSnackBar(context, "Thumbnail seems empty");
      return;
    }

    var data = {
      'video_id': widget.video.id,
      'title': _title.text,
      'description': _description.text,
      'thumbnail': thumbnail,
      'paid_promotion': _isPaidPromotion,
      'age_restriction': _isAgeRestricted,
      'language': selectedLanguage.name,
      'topic': _selectedTopic,
    };
    widget.callback!(data);
  }

  Widget _buildThumbnail() {
    if ((widget.video.thumbnail!.isNotEmpty) && !_thumbnailChanged) {
      String url = videoThumbnailUrl(widget.video.id);
      setState(() {
        _thumbnailChanged = true;
      });
      return Column(
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
          ),
          Container(margin: const EdgeInsets.only(top: 5), child: PrimaryFocusButton(label: "Change Thumbnail", callback: _selectThumbnailCallback))
        ],
      );
    }
    if (thumbnail == null) {
      return InkWell(
        onTap: () {
          _selectThumbnailCallback();
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: Theme.of(context).dialogBackgroundColor, border: Border.all(color: Theme.of(context).dividerColor)),
          child: Center(
            child: SelectableText(
              'Select Thumbnail',
              style: defaultLabelText(context),
            ),
          ),
        ),
      );
    }
    return Image.memory(
      thumbnailResult!.files.first.bytes!,
      fit: BoxFit.fitWidth,
    );
  }

  void _ageRestrictedCallback(newValue) {
    setState(() {
      _isAgeRestricted = newValue!;
    });
  }

  void _paidPromotionCallback(newValue) {
    setState(() {
      _isPaidPromotion = newValue!;
    });
  }

  Widget _postVideoSelection() {
    List<Widget> children = [
      Text("Add information for your video", style: defaultHeadingText(context)),
      SelectableText("Complete these details and you'll be good to go.", style: defaultSmallLabel(context)),
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: StepProgressIndicator(
          totalSteps: 4,
          currentStep: 1,
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).dividerColor,
        ),
      ),
      Container(
          height: 360,
          margin: const EdgeInsets.only(bottom: 20),
          decoration:
              BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(5), color: Colors.black),
          child: LimetimeVideoPlayer(video: widget.video)),
      Container(margin: const EdgeInsets.only(top: 10), child: Text("Selected file:", style: defaultLabelText(context))),
      SelectableText(
        widget.video.videoFileOriginalName!,
        style: defaultNormalText(context, fontColor: Theme.of(context).colorScheme.primary),
      ),
      const Divider(),
      SelectableText('Title', style: defaultLabelText(context)),
      SelectableText("Most important part of a video, along with thumbnail.", style: defaultSmallLabel(context)),
      Container(
        margin: const EdgeInsets.only(top: 0, bottom: 20),
        child: TextField(
          controller: _title,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (text) {},
        ),
      ),
      SelectableText('Description', style: defaultLabelText(context)),
      SelectableText("For your audience to get a detailed summary of what's happened in the video.", style: defaultSmallLabel(context)),
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: TextField(
          maxLines: 4,
          controller: _description,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {},
        ),
      ),
      SelectableText('Thumbnail', style: defaultLabelText(context)),
      SelectableText("First thing your audience will notice.", style: defaultSmallLabel(context)),
      Container(margin: const EdgeInsets.only(top: 5, bottom: 20), child: _buildThumbnail()),
      SelectableText('Paid promotion', style: defaultLabelText(context)),
      SelectableText("If you accepted anything of value from a third party to make your video, you must let us know.",
          style: defaultSmallLabel(context)),
      CheckBoxWidget(
          status: _isPaidPromotion,
          callback: _paidPromotionCallback,
          label: "My video contains paid promotion like a product placement, sponsorship or endorsement"),
      SelectableText('Age restricted content', style: defaultLabelText(context)),
      SelectableText(
          "If you think that your video is not suitable for kids, check this box. This won't affect your monetization or visibility but ensures that children won't receive your video.",
          style: defaultSmallLabel(context)),
      CheckBoxWidget(status: _isAgeRestricted, callback: _ageRestrictedCallback, label: "Make my video visible only for 18 and above."),
      SelectableText('Language', style: defaultLabelText(context)),
      SelectableText("Corresponding to the audio or the majority of audio in this video.", style: defaultSmallLabel(context)),
      Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(4)),
        child: LanguagePickerDropdown(
            initialValue: Languages.english,
            onValuePicked: (Language language) {
              selectedLanguage = language;
            }),
      ),
      SelectableText('Topic Category', style: defaultLabelText(context)),
      SelectableText("Category that fits best for your video. This will ensure that video reaches right audience.",
          style: defaultSmallLabel(context)),
      Container(
        height: 60,
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            autofocus: false,
            underline: null,
            value: _selectedTopic,
            padding: EdgeInsets.zero,
            style: defaultLabelText(context),
            items: topicCategories.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                ),
              );
            }).toList(),
            onChanged: (val) {
              _selectedTopic = val!;
              setState(() {});
            },
          ),
        ),
      ),
      PrimaryFocusButton(label: 'Next', callback: _proceedData),
      const SizedBox(
        height: 100,
      )
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        alignment: Alignment.center,
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
  void initState() {
    super.initState();
    _loadVideoData();
  }

  @override
  Widget build(BuildContext context) {
    return _postVideoSelection();
  }
}
