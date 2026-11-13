import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/lounge_home/lounge_home_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/screens/lounges/lounge_access/lounge_access.dart';
import 'package:lime_time_app/screens/lounges/expanded/lounge_expanded_posts.dart';
import 'package:lime_time_app/screens/lounges/expanded/lounge_expanded_users.dart';
import 'package:lime_time_app/screens/settings/lounges/renderers/post.dart';
import 'package:lime_time_app/screens/settings/main/renderer/user_profile_card.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:text_scroll/text_scroll.dart';

import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';

class LoungesHome extends StatefulWidget {
  const LoungesHome({super.key});

  @override
  State<LoungesHome> createState() => _LoungesHomeState();
}

class _LoungesHomeState extends State<LoungesHome> {
  ScrollController controllerX = ScrollController();
  LoungeHomeBloc loungeHomeBloc = LoungeHomeBloc();

  @override
  void initState() {
    setBadge();
    loungeHomeBloc.add(LoadLoungeHome());
    super.initState();
  }

  int requests = 0;
  UserRepo userRepo = UserRepo();
  void setBadge() async {
    userRepo = await LoungeEngine().fetchLoungeInvitations(userRepo);
    setState(() {
      requests = userRepo.profiles.length;
    });
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
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Text(label,
                style: defaultVerySmallLabelCustom(context,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontColor: isSelected
                        ? (theme == ThemeMode.light
                            ? Theme.of(context).canvasColor
                            : Theme.of(context).primaryColor)
                        : null)),
          ],
        ));
  }

  List<bool> selectedIndex = [true, false];
  Widget _buildSectionToggleRow() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Row(
        children: [
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [true, false];
                });
              },
              child: _backgroundWrapper2(
                  'Across the Globe', selectedIndex[0], Iconsax.map_bold)),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [false, true];
                });
              },
              child: _backgroundWrapper2('From your favourites',
                  selectedIndex[1], Iconsax.star_1_bold))
        ],
      ),
    );
  }

  Widget _buildFlare(String label, Color color) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).dividerColor.withAlpha(400),
          borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          label,
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget postSubSection(String title, List<Post> repo,
      {bool showTitle = true, bool showAlternateSource = false}) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showTitle)
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Top Threads",
                          style: defaultHeadingXText(context,
                              fontsize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: LoungeExpandedVideo(
                    sectionName: title,
                    alternateSourceData: showAlternateSource,
                  ),
                  withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: _buildFlare("More", Theme.of(context).cardColor)),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      repo.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: repo.length,
              controller: controllerX,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return PostWidget(
                  post: repo[index],
                  isThreadable: true,
                  showTail: false,
                  isFirst: true,
                  forLoungeHome: true,
                  isExpanded: false,
                  deleteCallbackPost: () {},
                  baseComments: [repo[index]],
                );
              })
          : SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "😭",
                    style: defaultHeadingXText(context, fontsize: 40),
                  ),
                  Text(
                    "Wow, such empty.",
                    style: defaultLabelTextForPost(context,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    ]);
  }

  Widget userSubSection(String title, List<UserProfile> repo,
      {bool showTitle = true, bool showAlternateSource = false}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showTitle)
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Top Lounges",
                              style: defaultHeadingText(context,
                                  fontsize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              InkWell(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: LoungeExpandedUsers(
                          sectionName: title,
                          alternateSourceData: showAlternateSource),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: _buildFlare("More", Theme.of(context).cardColor)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          repo.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  controller: controllerX,
                  itemCount: repo.length,
                  itemBuilder: (context, index) {
                    if (repo[index].userName == null) {
                      return Container();
                    }
                    return UserProfileCard(
                      user: repo[index],
                      forLounge: true,
                    );
                  })
              : SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      "Wow, such empty.",
                      style: defaultLabelText(context,
                          fontColor: Theme.of(context).colorScheme.primary),
                    ),
                  )),
          const SizedBox(
            height: 10,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildState(context, state) {
      if (state is LoungeHomeSuccess) {
        return AnimatedCoolRefresh(
          onRefresh: () async {
            setBadge();
            loungeHomeBloc.add(LoadLoungeHome());
          },
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            controller: controllerX,
            children: [
              selectedIndex[0]
                  ? Column(
                      children: [
                        userSubSection("Users", state.home.topLounges!,
                            showTitle: true),
                        const SizedBox(
                          height: 10,
                        ),
                        postSubSection("Posts", state.home.topLoungePosts!,
                            showAlternateSource: true),
                        const SizedBox(
                          height: 100,
                        )
                      ],
                    )
                  : Container(),
              selectedIndex[1]
                  ? Column(
                      children: [
                        userSubSection(
                            "Users", state.home.topLoungesUserJoined!,
                            showTitle: true, showAlternateSource: true),
                        const SizedBox(
                          height: 10,
                        ),
                        postSubSection(
                          "Posts",
                          state.home.topLoungePostsUserJoined!,
                          showTitle: true,
                        ),
                        const SizedBox(
                          height: 100,
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 300,
          ),
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
        ],
      );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        controller: controllerX,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: Theme.of(context).canvasColor.withOpacity(1),
              surfaceTintColor: Theme.of(context).canvasColor.withOpacity(1),
              leading: UserProfilePicture(
                radius: 16,
                userObj: authHandler.loggedInUser!,
                doNothing: true,
                callback: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: UserChannel(
                        user: authHandler.loggedInUser, asList: false),
                    withNavBar: true, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  TextScroll("Community Hub",
                      style: defaultHeadingText(context,
                          fontWeight: FontWeight.w900),
                      velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                      mode: TextScrollMode.endless,
                      intervalSpaces: 5),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const LoungeAccess(),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  icon: requests != null
                      ? Badge(
                          backgroundColor: Colors.red,
                          isLabelVisible: requests != 0,
                          label: Text(
                            requests.toString(),
                            style: defaultEvenVerySmallLabelCustom(context,
                                fontColor: Colors.white),
                          ),
                          child: const Icon(Icons.move_to_inbox),
                        )
                      : const Icon(
                          Icons.move_to_inbox,
                        ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 15, left: 0),
                  child: _buildSectionToggleRow(),
                ),
              ),
            ),
          ];
        },
        body: AnimatedCoolRefresh(
          onRefresh: () async {
            setBadge();
            loungeHomeBloc.add(LoadLoungeHome());
          },
          child: ListView(
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              BlocConsumer<LoungeHomeBloc, LoungeHomeState>(
                bloc: loungeHomeBloc,
                listener: (context, state) {},
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: buildState(context, state),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
