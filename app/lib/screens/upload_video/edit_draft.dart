import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/content/edit_draft/edit_draft_bloc.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/upload_video/edit_draft/first_part.dart';
import 'package:lime_time_app/screens/upload_video/edit_draft/second_part.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:lime_time_app/widgets/not_found.dart';

class EditVideoDraft extends StatefulWidget {
  final VideoPost video;

  const EditVideoDraft({super.key, required this.video});

  @override
  State<EditVideoDraft> createState() => _EditVideoDraftState();
}

class _EditVideoDraftState extends State<EditVideoDraft> {
  EditDraftBloc editDraftBloc = EditDraftBloc();

  Widget _buildBody(List<Widget> children) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 640,
            ),
            child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                addAutomaticKeepAlives: true,
                controller: controller,
                physics: physics,
                shrinkWrap: true,
                children: children),
          );
        });
  }

  void partOneCallback(data) {
    editDraftBloc.add(SaveDraft_I(
        title: data['title'],
        description: data['description'],
        thumbnail: data['thumbnail'],
        isPaidPromotion: data['paid_promotion'],
        isAgeRestricted: data['age_restriction'],
        topic: data['topic'],
        data: data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditDraftBloc, EditDraftState>(
      bloc: editDraftBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SaveOneSuccess) {
          return SecondPart(
            video: state.video,
          );
        }
        if (state is ErrorEditDraft) {
          return const Error404();
        }
        return _buildBody([
          EditDraft_I(video: widget.video, callback: partOneCallback),
        ]);
      },
    );
  }
}
