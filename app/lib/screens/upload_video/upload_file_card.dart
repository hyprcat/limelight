// ignore_for_file: unused_local_variable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/content/upload_video/upload_video_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/upload_video/edit_video_screen.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ImportVideoCard extends StatefulWidget {
  const ImportVideoCard({super.key});

  @override
  State<ImportVideoCard> createState() => _ImportVideoCardState();
}

class _ImportVideoCardState extends State<ImportVideoCard>
    with AutomaticKeepAliveClientMixin<ImportVideoCard> {
  @override
  bool get wantKeepAlive => true;

  UploadVideoBloc uploadVideoBloc = UploadVideoBloc();

  FilePickerResult? videoResult;
  FilePickerResult? thumbnailResult;
  MultipartFile? video;
  MultipartFile? thumbnail;

  String label = "Upload a video";

  bool _isLoading = false;
  bool _isUploading = false;
  int activeSpeed = 25000000;

  double _videoUploadProgress = 0.0015;
  void _selectVideoCallback() async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    analytics!
        .logEvent(name: 'video_selection_click', parameters: <String, Object>{
      'user_id': authHandler.loggedInUser!.userId!.toString(),
    });
    setState(() {
      _isLoading = true;
    });

    videoResult = await FilePicker.platform
        .pickFiles(type: FileType.video, withReadStream: true);
    if (videoResult != null) {
      var videoName = videoResult!.files.first.path!.split('/').last;
      label = "$videoName successfully selected.";

      final dio = Dio(BaseOptions(
        baseUrl: videoDraftUploadUrl,
        headers: {'Authorization': sessionData!['token']},
      ));

      setState(() {
        _isLoading = false;
        _isUploading = true;
      });
      PlatformFile file = videoResult!.files.first;

      try {
        analytics!
            .logEvent(name: 'video_upload_begin', parameters: <String, Object>{
          'user_id': authHandler.loggedInUser!.userId!.toString(),
        });
        final uploader = ChunkedUploader(dio);
        final name = file.name.replaceAll(RegExp(r"\s+"), "");
        final response = await uploader.upload(
          fileName: name,
          fileSize: file.size,
          fileDataStream: file.readStream!,
          maxChunkSize: activeSpeed,
          fileKey: 'video',
          path: '',
          onUploadProgress: (progress) {
            setState(() {
              _videoUploadProgress = progress;
            });
          },
        );
        if (response!.data == "File(s) uploaded!") {
          final videoPost = await VideoEngine().saveInitialDraft(
              {'file_name': name, 'token': sessionData!['token']});

          analytics!
              .logEvent(name: 'video_upload_done', parameters: <String, Object>{
            'user_id': authHandler.loggedInUser!.userId!.toString(),
          });

          uploadVideoBloc.add(UploadVideo(videoPost));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
        throwErrorSnackBar(context, "Video uploading failed: ${e.toString()}");
        rethrow;
      }
    } else {
      // User canceled the picker
      uploadVideoBloc.add(LoadSection());
    }
    setState(() {
      _isLoading = false;
      _isUploading = false;
    });
  }

  Widget _selectVideoCard() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            child: IconButton(
                onPressed: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                icon: CircleAvatar(
                  backgroundColor: Theme.of(context).focusColor,
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                )),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: InkWell(
                  onTap: _selectVideoCallback,
                  child: Icon(
                    Iconsax.add_square_outline,
                    size: MediaQuery.of(context).size.width / 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                'Upload Priority',
                style: defaultLabelText(context, fontWeight: FontWeight.bold),
              ),
              Text(
                "Use 'lightning' mode when you have a Wifi with speeds "
                "greater than 8MBps or while using 5G.",
                style: defaultSmallXLabelCustom(context),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                child: ToggleSwitch(
                  customTextStyles: [
                    defaultLabelText(context, fontWeight: FontWeight.bold)
                  ],
                  minWidth: double.infinity,
                  initialLabelIndex: 1,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Theme.of(context).focusColor,
                  inactiveFgColor: Theme.of(context).hintColor,
                  totalSwitches: 2,
                  labels: const ['Stable', 'Lightening'],
                  icons: const [
                    Iconsax.strongbox_outline,
                    Iconsax.cloud_lightning_bold
                  ],
                  activeBgColors: const [
                    [Colors.blue],
                    [Colors.pink]
                  ],
                  onToggle: (index) {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    if (index == 0) {
                      activeSpeed = 2500000;
                    } else {
                      activeSpeed = 25000000;
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Text(
                "Videos take time to process for the best experience. During this, only "
                "you can see them, marked 'Processing.' Check the status in the description section.",
                style: defaultVerySmallLabel(context,
                    fontColor: Theme.of(context).disabledColor),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
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
        ),
        Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text("Loading video.",
                style: defaultLabelText(context, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildUploadScreen() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
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
          ),
          Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                  "Uploading video - ${(_videoUploadProgress * 100).floor()}% complete",
                  style:
                      defaultLabelText(context, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isUploading) {
      return _buildUploadScreen();
    }
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    return _selectVideoCard();
  }

  @override
  void initState() {
    uploadVideoBloc.add(LoadSection());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocConsumer<UploadVideoBloc, UploadVideoState>(
        bloc: uploadVideoBloc,
        listener: (context, state) {
          if (state is UploadMetaInformationState) {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: EditScreen(videoPost: state.video),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        },
        builder: (context, state) {
          if (state is SectionLoading) {
            return _buildLoadingScreen();
          }
          if (state is UploadVideoInitial) {
            return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: _buildBody());
          }

          return _buildLoadingScreen();
        },
      ),
    );
  }
}
