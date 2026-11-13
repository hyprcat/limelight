import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/lounge_section/lounge_section_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:http_parser/http_parser.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoungePostThreadV2 extends StatefulWidget {
  final List<Post> baseComments;
  final bool hasRootComment;
  const LoungePostThreadV2(
      {super.key, required this.baseComments, required this.hasRootComment});

  @override
  State<LoungePostThreadV2> createState() => _LoungePostThreadV2State();
}

class _LoungePostThreadV2State extends State<LoungePostThreadV2> {
  late LoungeSectionBloc loungeSectionBloc;

  @override
  void initState() {
    PostRepo repo = PostRepo();
    repo.currentPost = widget.baseComments.last;
    loungeSectionBloc = LoungeSectionBloc(repo);
    loungeSectionBloc.add(LoadThreadedPosts(true));
    super.initState();
  }

  ScrollController controller = ScrollController();
  TextEditingController postTextController = TextEditingController();

  FilePickerResult? photoResult;
  MultipartFile? photo;

  void _selectPhotoCallback() async {
    photoResult = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (photoResult != null) {
      photo = MultipartFile.fromBytes(photoResult!.files.first.bytes!,
          contentType: MediaType('image', 'jpeg'),
          filename: photoResult!.files.first.name);
      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget searchUserField(Post? repo) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: false,
          maxLength: 400,
          controller: postTextController,
          style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
          maxLines: null,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText:
                repo != null ? "Let's do this.." : "Reply to this thread..",
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
            prefixIcon: InkWell(
              onTap: _selectPhotoCallback,
              child: const Icon(
                Icons.attach_file,
                size: 20,
              ),
            ),
            suffixIcon: InkWell(
              onTap: () async {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (postTextController.text.isEmpty) {
                  throwErrorSnackBar(context, "Post can't be empty.");
                } else {
                  var rootPost = widget.baseComments.last;
                  Map<String, dynamic> data = {
                    'token': sessionData!['token'],
                    'section_id': rootPost.associatedLoungeSection!.id,
                    'text': postTextController.text,
                  };
                  if (reply.value != null) {
                    data['parent_post_id'] = reply.value!.id;
                  } else {
                    data['parent_post_id'] = widget.baseComments.last.id;
                  }

                  if (photo != null) {
                    data['attachment'] = photo;
                  }

                  loungeSectionBloc.add(AddLoungePost(data));
                  postTextController.clear();
                  photo = null;
                }
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: _backgroundWrapper([
                  Text(
                    "Post",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Iconsax.send_1_bold,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    if (photo == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 250,
        child: Image.memory(
          photoResult!.files.first.bytes!,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Widget _bottomTextField() {
    return ValueListenableBuilder<Post?>(
        valueListenable: reply,
        builder: (context, Post? value, _) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    border: (photoResult != null)
                        ? Border.all(
                            color: Theme.of(context).dividerColor, width: 2)
                        : null,
                    borderRadius: (photoResult != null)
                        ? BorderRadius.circular(10)
                        : null),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      value != null
                          ? AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: GestureDetector(
                                onHorizontalDragDown: (_) {
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
                                  reply.value = null;
                                },
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minHeight: 10, maxHeight: 100),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Replying to @${value.createdBy!.member!.userName}..",
                                          style: defaultSmallLabel(context,
                                              fontWeight: FontWeight.bold,
                                              fontColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(value.text!,
                                            maxLines: 2,
                                            overflow: TextOverflow.fade,
                                            style: defaultLabelText(
                                              context,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      GestureDetector(
                          onHorizontalDragDown: (_) {
                            SystemSound.play(SystemSoundType.click);
                            HapticFeedback.selectionClick();
                            photo = null;
                            photoResult = null;
                            setState(() {});
                          },
                          child: _buildPhoto()),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 0,
                        color: Theme.of(context).dividerColor,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20, top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              UserProfilePicture(
                                  radius: 18,
                                  userObj: authHandler.loggedInUser!),
                              Expanded(child: searchUserField(value)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  void _delete(Post post) {
    loungeSectionBloc
        .add(RemoveLoungePost(post.id!, post.id! == post.rootPost));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
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
        title: Text(
          "Follow up",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedCoolRefresh(
        onRefresh: () async {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          PostRepo repo = PostRepo();
          repo.currentPost = widget.baseComments.last;
          loungeSectionBloc.repo = repo;
          loungeSectionBloc.add(LoadThreadedPosts(true));
        },
        child: Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: controller,
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    controller: controller,
                    itemCount: widget.baseComments.length,
                    itemBuilder: (context, index) {
                      return PostWidget(
                        post: widget.baseComments[index],
                        baseComments: widget.baseComments,
                        isThreadable: false,
                        showTail: false,
                        isFirst: false,
                        showTopPadding: true,
                        deleteCallbackPost: (Post post) {
                          loungeSectionBloc.add(RemoveLoungePost(
                              post.id!, post.id! == post.rootPost!));
                        },
                        showCommentedByText: false,
                      );
                    }),
                BlocConsumer<LoungeSectionBloc, LoungeSectionState>(
                  bloc: loungeSectionBloc,
                  listener: (context, state) {
                    if (state is PostAdded) {
                      throwHappySnackBar(context, state.message);
                      PostRepo repo = PostRepo();
                      repo.currentPost = widget.baseComments.last;
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadThreadedPosts(true));
                    }
                    if (state is PostDeletionSuccess) {
                      throwHappySnackBar(context, 'Post has been removed.');
                      PostRepo repo = PostRepo();
                      repo.currentPost = widget.baseComments.last;
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadThreadedPosts(true));
                    }
                    if (state is PostAddingError) {
                      throwErrorSnackBar(context, state.error);
                      PostRepo repo = PostRepo();
                      repo.currentPost = widget.baseComments.last;
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadThreadedPosts(true));
                    }
                  },
                  builder: (context, state) {
                    if (state is PostLoadSuccess) {
                      if (state.repo.posts.isEmpty) {
                        return SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "No follow ups found.",
                              style: defaultLabelText(context,
                                  fontWeight: FontWeight.w600,
                                  fontColor:
                                      Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                          controller: controller,
                          shrinkWrap: true,
                          itemCount: state.repo.posts.length,
                          itemBuilder: (context, index) {
                            Post post = state.repo.posts[index];

                            return PostWidget(
                              post: post,
                              baseComments: widget.baseComments,
                              deleteCallbackPost: _delete,
                              isThreadable: true,
                              showTail: false,
                              showTopPadding: index == 0,
                              isFirst: true,
                            );
                          });
                    }
                    if (state is PostLoadError) {
                      return Center(
                          child: Text(
                        "Error occurred",
                        style: defaultLabelText(context),
                      ));
                    }
                    if (state is PostsLoading) {
                      return Center(
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
                              pathBackgroundColor:
                                  Theme.of(context).canvasColor),
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return const FakePost();
                        });
                  },
                ),
                const SizedBox(
                  height: 150,
                )
              ],
            ),
            _bottomTextField()
          ],
        ),
      ),
    );
  }
}
