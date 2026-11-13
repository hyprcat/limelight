// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/user_videos/user_videos_bloc.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/bloc/videos/playlist/playlist_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/logics/repos/playlist_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:lime_time_app/screens/settings/widgets/channel_metrics.dart';
import 'package:lime_time_app/screens/video/fake_video.dart';

import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/thumbnail_card.dart';
import 'package:lime_time_app/v1_200/cards/playlist_card.dart';
import 'package:lime_time_app/v1_200/cards/video_comment_thread_widget.dart';
import 'package:lime_time_app/widgets/ban_screen.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/report_screen.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:lime_time_app/widgets/text_widgets/small_heading.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class UserChannel extends StatefulWidget {
  final UserProfile? user;
  final bool asList;
  final Function? canBuildVideo;
  const UserChannel(
      {super.key,
      required this.user,
      required this.asList,
      this.canBuildVideo});

  @override
  State<UserChannel> createState() => _UserChannelState();
}

class _UserChannelState extends State<UserChannel>
    with SingleTickerProviderStateMixin {
  UserVideosBloc userVideosBloc = UserVideosBloc();
  PaginationScrollController paginationScrollController =
      PaginationScrollController();

  late TabController tabController;
  int selectedIndex = 0;

  final bodyGlobalKey = GlobalKey();
  final List<Widget> myTabs = [
    const Tab(height: 30, text: 'Videos'),
    const Tab(height: 30, text: 'Threads'),
    const Tab(height: 30, text: 'Playlists'),
    const Tab(height: 30, text: 'About'),
  ];
  late TabController _tabController;
  bool fixedScroll = false;

  @override
  void dispose() {
    _tabController.dispose();
    paginationScrollController.scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      paginationScrollController.scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    paginationScrollController.scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      fixedScroll = _tabController.index == 2;
    });
  }

  PlaylistBloc localPlaylistBloc = PlaylistBloc();
  late VideoCommentsBloc commentBloc;

  setupUserVideos() {
    userVideosBloc.add(LoadUserVideos(widget.user!, false));
    localPlaylistBloc.add(
        FetchPlaylists(userId: widget.user!.userId!.toString(), pageNumber: 1));
    paginationScrollController.init(loadAction: () async {
      int lastPage = userVideosBloc.videoRepo!.lastPage + 1;
      int currentPage = userVideosBloc.videoRepo!.currentPage;
      if (lastPage > currentPage) {
        userVideosBloc.add(LoadUserVideos(widget.user!, false));
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    paginationScrollController.scrollController.addListener(_scrollListener);
  }

  setupTabController() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_smoothScrollToTop);
  }

  setupThreads() {
    commentBloc = VideoCommentsBloc(VideoCommentRepo(VideoPost()));
    commentBloc.add(LoadThreadsUser(widget.user!.userId!.toString()));
  }

  @override
  void initState() {
    setupTabController();
    setupUserVideos();
    setupThreads();
    super.initState();
  }

  bool isEditModeOn = false;
  void refreshCallback() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    userVideosBloc.add(LoadUserVideos(widget.user!, true));
  }

  Widget noVideosFound(BuildContext context) {
    return Center(
      child: Text(
        "Wow, such empty.",
        style: defaultSmallLabel(context,
            fontColor: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user!.isBanned!) {
      return ErrorBanned(
        profile: widget.user,
      );
    }

    Widget aboutSection(state) {
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SmallHeading(txt: 'Bio'),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                widget.user!.userChannel!.channelDescription == ""
                    ? generateRandomString(widget.user!.userName!)
                    : widget.user!.userChannel!.channelDescription ??
                        generateRandomString(widget.user!.userName!),
                style: defaultSmallXLabelCustom(context),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            const SmallHeading(txt: 'Channel Stats'),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.calendar_2_outline,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "On LimeLight since ${dateTimeToWords(state.user.creationDate!)}",
                    style: defaultSmallXLabelCustom(context),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.video_play_outline,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${state.user.userChannel!.videosCount!} videos uploaded",
                    style: defaultSmallXLabelCustom(context),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.video_play_outline,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${state.user.userChannel!.subscriberCount!} Subscribers",
                    style: defaultSmallXLabelCustom(context),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.ranking_outline,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${state.user.userChannel!.level!} Level in overall platform",
                    style: defaultSmallXLabelCustom(context),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.huobi_token_ht_outline,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${state.user.userChannel!.xP!} XP gained",
                    style: defaultSmallXLabelCustom(context),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.direct_inbox_outline,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        "${state.user.userEmail}",
                        style: defaultSmallXLabelCustom(context),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      );
    }

    Widget _backgroundWrapper2(String label, bool isSelected, IconData icon) {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 5),
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.inverseSurface
                  : (theme == ThemeMode.light
                      ? Theme.of(context).focusColor
                      : Theme.of(context).focusColor),
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 1),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Text(label,
                  style: defaultVerySmallLabelCustom(context,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontColor: isSelected
                          ? (theme == ThemeMode.light
                              ? Theme.of(context).canvasColor
                              : Theme.of(context).primaryColor)
                          : null)),
            ],
          ));
    }

    Widget threads = BlocConsumer<VideoCommentsBloc, VideoCommentsState>(
      bloc: commentBloc,
      listener: (context, state) {
        if (state is CommentAddedSuccessfully) {
          throwHappySnackBar(context, 'Comment added.');
          commentBloc.add(LoadThreadedComments(true));
        }
        if (state is CommentRemovedSuccessfully) {
          throwHappySnackBar(context, 'Comment removed.');
          commentBloc.add(LoadThreadedComments(true));
        }
      },
      builder: (context, state) {
        if (state is CommentLoadError || state is CommentActionError) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(
              child: Text(
                "Error occured.",
                style: defaultSmallLabel(context, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state is LoadingComments) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
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
              ));
        }

        if (state is SuccessfulThreadsFetch) {
          if (state.repo.data.isEmpty) {
            return SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: noVideosFound(context));
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: state.repo.data.length,
              itemBuilder: (context, index) {
                return VideoCommentThreadWidget(repo: state.repo.data[index]);
              });
        }
        return noVideosFound(context);
      },
    );

    List<Widget> _buildSectionToggleRow() {
      return [
        InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.selectionClick();
              setState(() {
                _tabController.index = 0;
              });
            },
            child: _backgroundWrapper2(
                'Videos', _tabController.index == 0, Iconsax.ranking_bold)),
        InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.selectionClick();
              setState(() {
                _tabController.index = 1;
              });
            },
            child: _backgroundWrapper2(
                'Threads', _tabController.index == 1, Iconsax.ranking_bold)),
        InkWell(
            onTap: () {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.selectionClick();
              setState(() {
                _tabController.index = 2;
              });
            },
            child: _backgroundWrapper2(
                'Playlists', _tabController.index == 2, Iconsax.star_1_bold)),
        Row(
          children: [
            InkWell(
                onTap: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.selectionClick();
                  setState(() {
                    _tabController.index = 3;
                  });
                },
                child: _backgroundWrapper2(
                    'About', _tabController.index == 3, Iconsax.star_1_bold)),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    isDismissible: true,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    builder: (BuildContext context) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Text("Sort by", style: defaultHeadingText(context)),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      userVideosBloc.videoRepo
                                          ?.sortByHeightGreaterThanWidth();
                                      setState(() {});
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Iconsax.video_vertical_outline),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Shorts only",
                                          style: defaultHeadingText(context,
                                              fontsize: 20,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      userVideosBloc.videoRepo?.sortByVideoXp();
                                      setState(() {});
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Iconsax.huobi_token_ht_outline),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Points Gained",
                                          style: defaultHeadingText(context,
                                              fontsize: 20,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      userVideosBloc.videoRepo?.sortByViews();
                                      setState(() {});
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Iconsax.eye_outline),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Views",
                                          style: defaultHeadingText(context,
                                              fontsize: 20,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      userVideosBloc.videoRepo
                                          ?.sortByImpressions();
                                      setState(() {});
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Iconsax.activity_outline),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Impressions",
                                          style: defaultHeadingText(context,
                                              fontsize: 20,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      userVideosBloc.videoRepo?.sortByDate();
                                      setState(() {});
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Iconsax.calendar_1_outline),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Creation Date",
                                          style: defaultHeadingText(context,
                                              fontsize: 20,
                                              fontWeight: FontWeight.w500,
                                              fontColor:
                                                  Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Iconsax.setting_4_outline,
                  color: Theme.of(context).colorScheme.inverseSurface,
                )),
          ],
        ),
      ];
    }

    Widget playlists = BlocConsumer<PlaylistBloc, PlaylistState>(
      bloc: localPlaylistBloc,
      listener: (context, state) {
        if (state is PlaylistCreated) {
          throwHappySnackBar(context, "Playlist created.");
        }
        if (state is PlaylistModified) {
          throwHappySnackBar(context, "Playlist modified.");
        }
      },
      builder: (context, state) {
        if (state is PlaylistsError) {
          return Center(
              child: Text(
            "Error occurred",
            style: defaultLabelText(context),
          ));
        }

        if (state is LoadingPlaylists) {
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
                  pathBackgroundColor: Theme.of(context).canvasColor),
            ),
          );
        }

        if (state is PlaylistLoaded) {
          return state.repo.playlists.isEmpty
              ? Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: Text(
                      'No playlists created yet',
                      style: defaultSmallXLabelCustom(
                        context,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.repo.playlists.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PlaylistCard(playList: state.repo.playlists[index]);
                  });
        }
        return Container();
      },
    );
    RichText buildRichText(text) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: text,
            style: defaultLabelTextC(context,
                fontColor: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold),
            children: const []),
      );
    }

    Widget blocBody = BlocConsumer<UserVideosBloc, UserVideosState>(
      bloc: userVideosBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is UserBlockedLoggedInUser) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Icon(
                    Iconsax.forbidden_outline,
                    size: 100,
                    color: Colors.redAccent,
                  ),
                  Text(
                    '${widget.user!.userName!} has blocked you. ',
                    style: defaultHeadingText(context, fontsize: 25),
                    textAlign: TextAlign.center,
                  ),
                  buildRichText(
                      'You cannot view and interact with their profile till they unblock you.'),
                  const SizedBox(
                    height: 20,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        }
        if (state is UserHasBeenBlocked) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Icon(
                    Iconsax.forbidden_outline,
                    size: 100,
                    color: Colors.redAccent,
                  ),
                  Text(
                    'You have blocked this user. ',
                    style: defaultHeadingText(context, fontsize: 25),
                    textAlign: TextAlign.center,
                  ),
                  buildRichText(
                      'To view and interact with ${widget.user!.userName!} and their content, you will need to unblock them. '),
                  const SizedBox(
                    height: 20,
                  ),
                  PrimaryFocusButton(
                      highLight: true,
                      useRoundedCorner: true,
                      label: 'Unblock',
                      callback: () async {
                        var response = await UserEngine()
                            .unblockUser(widget.user!.userId!.toString());
                        if (response == 'success') {
                          userVideosBloc.videoRepo = VideoRepo();
                          userVideosBloc
                              .add(LoadUserVideos(widget.user!, true));
                          throwHappySnackBar(context,
                              'You have unblocked ${widget.user!.userName!}');
                        } else {
                          throwErrorSnackBar(context,
                              'Something went wrong. Please try again.');
                        }
                      }),
                  const Spacer(),
                ],
              ),
            ),
          );
        }
        if (state is LoadingUserVideos) {
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
                  pathBackgroundColor: Theme.of(context).canvasColor),
            ),
          );
        }
        if (state is UserVideosError) {
          return Center(
            child: Text("Error Occurred. Retry again.",
                style: defaultSmallLabel(context)),
          );
        }
        if (state is UserVideosLoadingSuccess) {
          if (authHandler.loggedInUser!.userId! == state.user.userId!) {
            authHandler.loggedInUser = state.user;
            UserEngine().fetchUserInfo(true);
          }
          return NestedScrollView(
            physics: const BouncingScrollPhysics(),
            controller: paginationScrollController.scrollController,
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      ChannelMetrics(
                        obj: widget.user,
                        compact: false,
                        showChannelMetrics: true,
                        refreshCallback: () {},
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: TabBar(
                      controller: _tabController,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.zero,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      tabs: _buildSectionToggleRow(),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                (state.videos.videos.isEmpty)
                    ? SizedBox(
                        height: 300,
                        child: Center(
                          child: Text(
                            "Wow, such empty.",
                            style: defaultSmallLabel(context,
                                fontColor:
                                    Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : AnimatedCoolRefresh(
                        onRefresh: () async {
                          userVideosBloc.videoRepo = VideoRepo();
                          userVideosBloc.add(LoadUserVideos(state.user, true));
                        },
                        child: ListView.builder(
                            padding: null,
                            physics: const ClampingScrollPhysics(),
                            itemCount: state.videos.videos.length,
                            itemBuilder: (context, index) {
                              return ThumbnailCard(
                                shouldSetImpression:
                                    (authHandler.loggedInUser!.userId! ==
                                        widget.user!.userId!),
                                video: state.videos.videos[index],
                                canBuildVideo: checkCanBuildVideo,
                                replaceScreen: false,
                                forMiniPlayer: false,
                              );
                            }),
                      ),
                AnimatedCoolRefresh(onRefresh: () async {}, child: threads),
                AnimatedCoolRefresh(
                    onRefresh: () async {
                      localPlaylistBloc.playlistRepo = VideoRepo();
                      localPlaylistBloc.repo = PlayListRepo();
                      localPlaylistBloc.add(FetchPlaylists(
                          userId: widget.user!.userId!.toString(),
                          pageNumber: 1));
                    },
                    child: playlists),
                aboutSection(state)
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return const ShimmerVideo();
              }),
        );
      },
    );

    if (widget.asList) {
      return blocBody;
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            const SizedBox(
              width: 5,
            ),
            if (widget.user!.userId != authHandler.loggedInUser!.userId)
              PopupMenuButton(
                child: const Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.selectionClick();
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ReportScreen(
                          userProfile: widget.user,
                        ),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.report),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Report User',
                          style: defaultSmallLabel(context),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    onTap: () async {
                      var response = await UserEngine()
                          .blockUser(widget.user!.userId!.toString());
                      if (response == 'success') {
                        userVideosBloc.videoRepo = VideoRepo();
                        userVideosBloc.add(LoadUserVideos(widget.user!, true));
                        throwHappySnackBar(context,
                            'You have blocked ${widget.user!.userName!}');
                      } else {
                        throwErrorSnackBar(
                            context, 'Something went wrong. Please try again.');
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Iconsax.forbidden_outline),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Block User',
                          style: defaultSmallLabel(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: blocBody);
  }
}
