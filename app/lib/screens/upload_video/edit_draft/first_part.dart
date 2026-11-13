// ignore_for_file: camel_case_types, unused_field
import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/widgets/buttons/check_box_title.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/video_players/better_player_widget.dart';

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
  bool _isMusicVideo = false;
  String _selectedTopic = "Entertainment";

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
    thumbnailResult = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (thumbnailResult != null) {
      thumbnail = MultipartFile.fromBytes(thumbnailResult!.files.first.bytes!,
          contentType: MediaType('image', 'jpeg'),
          filename: thumbnailResult!.files.first.name);
    } else {
      // User canceled the picker
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _proceedData() async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (_title.text.isEmpty) {
      throwErrorSnackBar(context, "Title seems empty.");
      return;
    }

    if (_description.text.isEmpty) {
      throwErrorSnackBar(context, "Description seems empty.");
      return;
    }

    if (widget.video.thumbnail == null && thumbnail == null) {
      throwErrorSnackBar(context, "Thumbnail seems empty");
      return;
    }

    if (_isMusicVideo) {
      _selectedTopic = 'Music';
    }

    var data = {
      'video_id': widget.video.id,
      'title': _title.text,
      'description': _description.text,
      'thumbnail': thumbnail,
      'paid_promotion': _isPaidPromotion,
      'age_restriction': _isAgeRestricted,
      'topic': _selectedTopic,
    };

    widget.callback!(data);
  }

  Widget _buildThumbnail() {
    if ((widget.video.thumbnail!.isNotEmpty) && !_thumbnailChanged) {
      String url = videoThumbnailUrl(widget.video.id!);
      setState(() {
        _thumbnailChanged = true;
      });
      return Column(
        children: [
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
          ),
          Container(
              margin: const EdgeInsets.only(top: 15),
              child: PrimaryFocusButton(
                  label: "Change Thumbnail",
                  callback: _selectThumbnailCallback))
        ],
      );
    }
    if (thumbnail == null) {
      return InkWell(
        onTap: () {
          _selectThumbnailCallback();
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: Center(
            child: Icon(
              Iconsax.gallery_add_outline,
              size: 100,
              color: Theme.of(context).disabledColor,
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

  void _isMusicVideoCallback(newValue) {
    setState(() {
      _isMusicVideo = newValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _postVideoSelection() {
    List<Widget> children = [
      Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add information for your video",
                style: defaultHeadingText(context)),
            Text(
              "Fill this up for us.",
              style: defaultLabelText(context,
                  fontWeight: FontWeight.normal,
                  fontColor: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: StepProgressIndicator(
          totalSteps: 2,
          currentStep: 1,
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).dividerColor,
        ),
      ),
      Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ValueListenableBuilder(
              valueListenable: videoPlayerController,
              builder: (BuildContext context, BetterPlayerController? value,
                  Widget? child) {
                return SafeArea(
                  child: BetterPlayerWidget(
                    video: widget.video,
                    betterPlayerController: value,
                    key: widget.key,
                  ),
                );
              })),
      Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text("Master File",
                    style: defaultLabelText(context,
                        fontWeight: FontWeight.bold))),
            Text(
              widget.video.videoFileOriginalName!,
              style: defaultLabelText(context,
                  fontColor: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 40,
            ),
            Text('Video Title',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text("Make it catchy for your audience.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: TextField(
                controller: _title,
                style: defaultNormalText(context, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '',
                  hintStyle: defaultNormalText(context,
                      fontColor: Theme.of(context).disabledColor),
                ),
                onChanged: (text) {},
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('Description',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text("What's this video about?",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: TextField(
                maxLines: null,
                controller: _description,
                style: defaultNormalText(context, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Something about the video..',
                  hintStyle: defaultNormalText(context,
                      fontColor: Theme.of(context).disabledColor),
                ),
                onChanged: (text) {},
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('Thumbnail',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text("First thing your audience will notice.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            Container(
                margin: const EdgeInsets.only(top: 5, bottom: 20),
                child: _buildThumbnail()),
            const SizedBox(
              height: 20,
            ),
            Text('Paid promotion',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text(
                "If you accepted anything of value from a third party to make your video, you must let us know.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            CheckBoxWidget(
                status: _isPaidPromotion,
                callback: _paidPromotionCallback,
                label:
                    "My video contains paid promotion like a product placement, sponsorship or endorsement"),
            const SizedBox(
              height: 20,
            ),
            Text('Age restricted content',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text(
                "If you think that your video is not suitable for kids, check this box. This won't affect your monetization or visibility but ensures that children won't receive your video.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            CheckBoxWidget(
                status: _isAgeRestricted,
                callback: _ageRestrictedCallback,
                label: "Add an NSFW tag to the video."),
            const SizedBox(
              height: 20,
            ),
            Text('Category of video',
                style: defaultLabelText(context, fontWeight: FontWeight.bold)),
            Text(
                "If this video is related to anything of music, then check this box out.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            CheckBoxWidget(
                status: _isMusicVideo,
                callback: _isMusicVideoCallback,
                label: "This is a music video."),
            const SizedBox(
              height: 20,
            ),
            PrimaryFocusButton(label: 'Next', callback: _proceedData),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Your video is under processing and will be analysed by our AI for various parameters. You can see the status of your video from your channel.",
              textAlign: TextAlign.center,
              style: defaultVerySmallLabel(context,
                  fontWeight: FontWeight.bold,
                  fontColor: Theme.of(context).disabledColor),
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      )
    ];

    return DynMouseScroll(
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
        });
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
