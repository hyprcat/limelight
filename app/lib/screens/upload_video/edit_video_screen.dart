// ignore_for_file: unused_local_variable

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';

import 'package:lime_time_app/bloc/content/upload_video/upload_video_bloc.dart';

import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

import 'package:lime_time_app/screens/upload_video/edit_draft.dart';
import 'package:loading_indicator/loading_indicator.dart';

class EditScreen extends StatefulWidget {
  final VideoPost videoPost;
  const EditScreen({super.key, required this.videoPost});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with AutomaticKeepAliveClientMixin<EditScreen> {
  @override
  bool get wantKeepAlive => true;

  UploadVideoBloc uploadVideoBloc = UploadVideoBloc();

  @override
  void initState() {
    uploadVideoBloc.add(UploadVideo(widget.videoPost));
    super.initState();
  }

  Widget _buildLoadingScreen() {
    return SizedBox(
      height: 100,
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
              child: Text("Loading video..", style: defaultLabelText(context))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).canvasColor, // Ensure
            statusBarIconBrightness: Brightness.light, // Adjust to fit
            // your theme
          ),
          backgroundColor: Theme.of(context).canvasColor,
          surfaceTintColor: Theme.of(context).canvasColor),
      body: BlocConsumer<UploadVideoBloc, UploadVideoState>(
        bloc: uploadVideoBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SectionLoading) {
            return _buildLoadingScreen();
          }
          if (state is UploadMetaInformationState) {
            return Container(
                alignment: Alignment.center,
                child: EditVideoDraft(
                  video: state.video,
                ));
          }

          return _buildLoadingScreen();
        },
      ),
    );
  }
}
