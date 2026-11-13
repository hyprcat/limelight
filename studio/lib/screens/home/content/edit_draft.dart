import 'package:code_arrow_creator_studio/blocs/content/edit_draft/edit_draft_bloc.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/screens/not_found.dart';
import 'package:code_arrow_creator_studio/screens/home/content/edit_draft/first_part.dart';
import 'package:code_arrow_creator_studio/screens/home/content/edit_draft/second_part.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class EditVideoDraft extends StatefulWidget {
  final VideoPost video;

  const EditVideoDraft({super.key, required this.video});

  @override
  State<EditVideoDraft> createState() => _EditVideoDraftState();
}

class _EditVideoDraftState extends State<EditVideoDraft> {
  EditDraftBloc editDraftBloc = EditDraftBloc();

  Widget _buildBody(List<Widget> children) {
    return DynMouseScroll(builder: (context, controller, physics) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 640,
        ),
        child: ListView(addAutomaticKeepAlives: true, controller: controller, physics: physics, shrinkWrap: true, children: children),
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
        language: data['language'],
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
