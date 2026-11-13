// ignore_for_file: unused_local_variable

import 'package:code_arrow_creator_studio/engines/media_urls.dart';
import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:code_arrow_creator_studio/blocs/home/upload_video/upload_video_bloc.dart';
import 'package:code_arrow_creator_studio/engines/video_engine.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:code_arrow_creator_studio/screens/home/content/edit_draft.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportVideoCard extends StatefulWidget {
  const ImportVideoCard({super.key});

  @override
  State<ImportVideoCard> createState() => _ImportVideoCardState();
}

class _ImportVideoCardState extends State<ImportVideoCard> with AutomaticKeepAliveClientMixin<ImportVideoCard> {
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

  double _videoUploadProgress = 0.0015;
  void _selectVideoCallback() async {
    setState(() {
      _isLoading = true;
    });

    videoResult = await FilePicker.platform.pickFiles(type: FileType.video, withReadStream: true);
    if (videoResult != null) {
      label = "${videoResult!.files.first.name} successfully selected.";
      final dio = Dio(BaseOptions(
        baseUrl: videoDraftUploadUrl,
        headers: {'Authorization': 'Bearer'},
      ));

      setState(() {
        _isLoading = false;
        _isUploading = true;
      });
      PlatformFile file = videoResult!.files.first;

      final uploader = ChunkedUploader(dio);
      final response = await uploader.upload(
        fileName: file.name,
        fileSize: file.size,
        fileDataStream: file.readStream!,
        maxChunkSize: 50000000,
        fileKey: 'video',
        path: '',
        onUploadProgress: (progress) {
          setState(() {
            _videoUploadProgress = progress;
          });
        },
      );
      if (response!.data == "File(s) uploaded!") {
        final videoPost = await VideoEngine().saveInitialDraft({'file_name': file.name, 'token': sessionData!['token']});

        uploadVideoBloc.add(UploadVideo(videoPost));
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: SelectableText(
            "Want to know your metrics and analytics?\nUpload a video to get started.",
            style: defaultLabelText(context),
          ),
        ),
        PrimaryFocusButton(label: 'Select a video', callback: _selectVideoCallback)
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(top: 5), child: Text("Loading video..", style: defaultLabelText(context))),
        ],
      ),
    );
  }

  Widget _buildUploadScreen() {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text("Uploading video - ${(_videoUploadProgress * 100).floor()}% complete", style: defaultLabelText(context))),
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
    return BlocConsumer<UploadVideoBloc, UploadVideoState>(
      bloc: uploadVideoBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SectionLoading) {
          return _buildLoadingScreen();
        }
        if (state is UploadVideoInitial) {
          return Container(alignment: Alignment.center, margin: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 50), child: _buildBody());
        }
        if (state is UploadMetaInformationState) {
          return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 50),
              child: EditVideoDraft(
                video: state.video,
              ));
        }

        return _buildLoadingScreen();
      },
    );
  }
}
