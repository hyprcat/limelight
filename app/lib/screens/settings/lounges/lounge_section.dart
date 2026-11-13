// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/lounge_section/lounge_section_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';

import 'package:lime_time_app/screens/settings/lounges/add_something.dart';
import 'package:lime_time_app/screens/settings/main/renderer/fake_profile_card.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:text_scroll/text_scroll.dart';

class LoungeSectionPage extends StatefulWidget {
  final UserProfile user;
  final LoungeSection section;
  const LoungeSectionPage(
      {super.key, required this.section, required this.user});

  @override
  State<LoungeSectionPage> createState() => _LoungeSectionPageState();
}

class _LoungeSectionPageState extends State<LoungeSectionPage> {
  TextEditingController postTextController = TextEditingController();

  FilePickerResult? photoResult;
  MultipartFile? photo;

  void _selectPhotoCallback() async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
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

  Widget _backgroundWrapperL(String label, bool isSelected) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: defaultSmallLabel(context,
                fontWeight: FontWeight.bold,
                fontColor: isSelected
                    ? Colors.black
                    : Theme.of(context).textTheme.labelSmall!.color)));
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: TextField(
            autofocus: false,
            maxLength: 400,
            controller: postTextController,
            style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
            maxLines: null,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: repo != null ? "Add a reply" : "Create a post.",
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
                    return;
                  }

                  var data = {
                    'token': sessionData!['token'],
                    'text': postTextController.text,
                    'is_advertisement': false,
                    'section_id': widget.section.id
                  };
                  if (photo != null) {
                    data['attachment'] = photo;
                  }

                  if (reply.value != null) {
                    data['parent_post_id'] = reply.value!.id;
                  }

                  loungeSectionBloc.add(AddLoungePost(data));
                  postTextController.clear();
                  photo = null;
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: _backgroundWrapper([
                    Text(
                      "Post",
                      style: defaultSmallLabel(context,
                          fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _bottomTextField() {
    Widget field = ValueListenableBuilder<Post?>(
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
    if (widget.section.onlyOwnerCanPost!) {
      if (widget.user.userId != authHandler.loggedInUser!.userId) {
        return Container();
      }
      return field;
    } else {
      return field;
    }
  }

  late LoungeSectionBloc loungeSectionBloc;

  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  @override
  void initState() {
    PostRepo repo = PostRepo();
    loungeSectionBloc = LoungeSectionBloc(repo);
    loungeSectionBloc
        .add(LoadSectionPosts(widget.section, "fetch_section_posts", null));

    paginationScrollController.init(loadAction: () async {
      int lastPage = loungeSectionBloc.repo.totalPage + 1;
      int currentPage = loungeSectionBloc.repo.currentPage;
      if (lastPage > currentPage) {
        loungeSectionBloc
            .add(LoadSectionPosts(widget.section, "fetch_section_posts", null));
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  void _delete(Post post) {
    loungeSectionBloc.add(RemoveLoungePost(post.id!, true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
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
        titleSpacing: 0,
        title: TextScroll(
          widget.section.sectionName!,
          velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
          mode: TextScrollMode.endless,
          intervalSpaces: 5,
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.user.userId == authHandler.loggedInUser!.userId!)
            InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: AddToLounge(
                      modifyMode: true,
                      categoryId: widget.section.relatedCategory,
                      sectionName: widget.section.sectionName!,
                      sectionDescription: widget.section.sectionDescription,
                      sectionId: widget.section.id,
                      minimumLevelRequired: widget.section.minimumLevelRequired,
                      onlyOwnerCanPost: widget.section.onlyOwnerCanPost,
                    ),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: _backgroundWrapperL("Edit", true)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: AnimatedCoolRefresh(
        onRefresh: () async {
          PostRepo repo = PostRepo();
          paginationScrollController.reset();
          loungeSectionBloc.repo = repo;
          loungeSectionBloc.add(
              LoadSectionPosts(widget.section, "fetch_section_posts", null));
        },
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              controller: paginationScrollController.scrollController,
              children: [
                BlocConsumer<LoungeSectionBloc, LoungeSectionState>(
                  bloc: loungeSectionBloc,
                  listener: (context, state) {
                    if (state is PostAdded) {
                      throwHappySnackBar(context, state.message);
                      PostRepo repo = PostRepo();
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadSectionPosts(
                          widget.section, "fetch_section_posts", null));
                    }
                    if (state is PostDeletionSuccess) {
                      throwHappySnackBar(context, 'Post has been removed.');
                      PostRepo repo = PostRepo();
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadSectionPosts(
                          widget.section, "fetch_section_posts", null));
                    }
                    if (state is PostAddingError) {
                      throwErrorSnackBar(context, state.error);
                      PostRepo repo = PostRepo();
                      loungeSectionBloc.repo = repo;
                      loungeSectionBloc.add(LoadSectionPosts(
                          widget.section, "fetch_section_posts", null));
                    }
                  },
                  builder: (context, state) {
                    if (state is PostLoadSuccess) {
                      return state.repo.buildPosts(context, _delete);
                    }
                    if (state is PostLoadError) {
                      return Center(
                          child: Text(
                        "Error occurred",
                        style: defaultLabelText(context),
                      ));
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
