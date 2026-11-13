import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';

class ReplyToComment extends StatefulWidget {
  final VideoPost video;
  final VideoComment replyingTo;
  const ReplyToComment(
      {super.key, required this.replyingTo, required this.video});

  @override
  State<ReplyToComment> createState() => _ReplyToCommentState();
}

class _ReplyToCommentState extends State<ReplyToComment> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    RichText buildAppBarText() {
      return RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Replying to',
            style: defaultLabelText(context, fontWeight: FontWeight.bold)),
        TextSpan(
            text: " @${widget.replyingTo.commentedBy!.userName}",
            style: defaultLabelText(context,
                fontWeight: FontWeight.bold,
                fontColor: Theme.of(context).colorScheme.primary)),
      ]));
    }

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
        title: buildAppBarText(),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 100),
        child: Column(
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              style: defaultSmallLabel(context),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your thoughts..',
                  hintStyle: defaultSmallLabel(context,
                      fontColor: Theme.of(context).hintColor)),
            ),
            const Spacer(),
            PrimaryFocusButton(
              callback: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                var data = {
                  'token': sessionData!['token'],
                  'video_id': widget.video.id,
                  'comment_string': textController.text
                };
                data['parent_comment'] = widget.replyingTo.id;
                videoCommentsBloc!.add(AddComment(data));
                Navigator.pop(context);
              },
              label: 'Reply this',
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
