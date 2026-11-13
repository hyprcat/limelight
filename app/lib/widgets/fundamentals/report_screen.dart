// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_comment.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/thumbnail_card.dart';
import 'package:lime_time_app/screens/video_player/widgets/video_comment.dart';
import 'package:lime_time_app/v1_200/cards/horizontal_profile_card.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';

class ReportScreen extends StatefulWidget {
  VideoPost? videoPost;
  VideoComment? comment;
  Post? post;
  UserProfile? userProfile;
  ReportScreen(
      {super.key, this.videoPost, this.comment, this.post, this.userProfile});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Widget _buildReportable() {
    if (widget.videoPost != null && widget.comment == null) {
      return ThumbnailCard(
          video: widget.videoPost!, canBuildVideo: checkCanBuildVideo);
    }

    if (widget.post != null) {
      return PostWidget(
          post: widget.post!,
          baseComments: const [],
          isThreadable: false,
          showTail: false,
          isFirst: true,
          forLoungeHome: true,
          deleteCallbackPost: () {});
    }
    if (widget.comment != null) {
      return VideoCommentWidget(
          videoPost: widget.videoPost!,
          comment: widget.comment!,
          showReplyButton: false,
          blocDeleteCallback: () {});
    }

    if (widget.userProfile != null) {
      return HorizontalUserProfileCard(user: widget.userProfile!);
    }
    return Container();
  }

  TextEditingController controller = TextEditingController();

  Widget _textField(String txt, TextEditingController control,
      TextInputType type, int maxLength) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: TextField(
          keyboardType: type,
          style: defaultLabelText(context),
          controller: control,
          decoration: InputDecoration(
            hintText: txt,
            hintStyle: defaultLabelText(context,
                fontColor: Theme.of(context).hintColor),
          ),
        ));
  }

  Widget infoText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).hintColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).canvasColor,
        backgroundColor: Theme.of(context).canvasColor,
        titleSpacing: 0,
        title: Text("Report Content", style: defaultNormalText(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildReportable(),
            if (widget.videoPost != null)
              Divider(
                color: Theme.of(context).dividerColor,
              ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tell us more about your experience.",
                      style: defaultHeadingText(context)),
                  _textField(
                      "Why do you think that this needs to be reported? ",
                      controller,
                      TextInputType.text,
                      256),
                  const SizedBox(
                    height: 10,
                  ),
                  PrimaryFocusButton(
                      label: 'Proceed',
                      callback: () async {
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.selectionClick();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (controller.text.isEmpty) {
                          throwErrorSnackBar(
                              context, "You need to specify your reason.");
                          return;
                        }
                        bool success = false;
                        var data = {
                          'reason': controller.text,
                          'token': sessionData!['token']
                        };

                        if (widget.videoPost != null &&
                            widget.comment == null) {
                          data['video_id'] = widget.videoPost!.id;
                          success = await VideoEngine().reportVideo(data);
                        } else if (widget.post != null) {
                          data['post_id'] = widget.post!.id;
                          success = await LoungeEngine().reportContent(data);
                        } else if (widget.comment != null) {
                          data['comment_id'] = widget.comment!.id;
                          success = await VideoEngine().reportComment(data);
                        } else if (widget.userProfile != null) {
                          data['user_id'] =
                              widget.userProfile!.userId.toString();
                          success = await UserEngine().reportUser(data);
                        }
                        if (success) {
                          throwHappySnackBar(context,
                              "We will review your report and take necessary action.");
                          Navigator.pop(context);
                        } else {
                          throwErrorSnackBar(context,
                              "Something has happened while connecting with server. Please try again");
                        }
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  infoText('PLEASE NOTE'),
                  infoText(
                      "-> Please be as descriptive as you can. It will help us your perspective and support you better."),
                  infoText(
                      "-> We will carefully review the content you reported for the selected reason (e.g., spam, harassment, or inappropriate material) within 72 hours."),
                  infoText(
                      "-> Once the review is complete, we will notify you of the outcome and any actions taken (like content removal or account suspension)."),
                  const SizedBox(
                    height: 150,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
