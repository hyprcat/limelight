import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/notifications/notifications_home.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/main/settings.dart';
import 'package:lime_time_app/v1_200/home/section_renderer/grid_layout_generator.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeExperimentalGridLayout extends StatefulWidget {
  const HomeExperimentalGridLayout({super.key});

  @override
  State<HomeExperimentalGridLayout> createState() =>
      _HomeExperimentalGridLayoutState();
}

class _HomeExperimentalGridLayoutState
    extends State<HomeExperimentalGridLayout> {
  final ScrollController _nestedScrollController = ScrollController();

  void setBadge() async {
    var temp = await NotifierEngine().getNotificationsCount();
    setState(() {
      notificationCount.value = temp;
    });
  }

  @override
  void initState() {
    experimentalUI.add(LoadExperimentalUI());
    super.initState();
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    super.dispose();
  }

  Widget buildTabBarText(String text) {
    return Text(text);
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

  List<bool> selectedIndex = [true, false, false];
  Widget _buildSectionToggleRow() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [true, false, false];
                });
                experimentalUI.add(LoadExperimentalUI());
              },
              child: _backgroundWrapper2(
                  'All', selectedIndex[0], Iconsax.ranking_bold)),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [false, true, false];
                });
                experimentalUI.add(LoadExperimentalUIVideos());
              },
              child: _backgroundWrapper2(
                  'Videos', selectedIndex[1], Iconsax.star_1_bold)),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [false, false, true];
                });
                experimentalUI.add(LoadExperimentalUIThreads());
              },
              child: _backgroundWrapper2(
                  'Threads', selectedIndex[2], Iconsax.star_1_bold)),
        ],
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
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
              toolbarHeight: 60,
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
              title: _buildSectionToggleRow(),
              actions: [
                IconButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const NotificationsHome(),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    icon: ValueListenableBuilder(
                        valueListenable: notificationCount,
                        builder: (context, value, _) {
                          return Badge(
                            backgroundColor: Colors.red,
                            label: Text(
                              numToEng(value),
                              style: defaultEvenVerySmallLabelCustom(context,
                                  fontColor: Colors.white),
                            ),
                            isLabelVisible: value != 0,
                            child: Icon(
                              Iconsax.notification_bold,
                              color: theme == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          );
                        })),
                IconButton(
                    onPressed: () {
                      UserEngine().getSeptemberContestDetails();
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const SettingsMain(),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    icon: Icon(
                      Iconsax.setting_2_bold,
                      color: theme == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                    )),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ];
        },
        body: BlocConsumer<RecommendedBloc, RecommendedState>(
          bloc: experimentalUI,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ExperimentalHomeSection) {
              return AnimatedCoolRefresh(
                onRefresh: () async {
                  if (selectedIndex[0]) {
                    experimentalUI.add(LoadExperimentalUI());
                  }
                  if (selectedIndex[1]) {
                    experimentalUI.add(LoadExperimentalUIVideos());
                  }
                  if (selectedIndex[2]) {
                    experimentalUI.add(LoadExperimentalUIThreads());
                  }
                },
                child: ListView.builder(
                  primary: true,
                  physics: const BouncingScrollPhysics(),
                  addAutomaticKeepAlives: true,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: state.repo.homeSections!.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          SectionGenerator(
                              section: state.repo.homeSections![index])
                        ],
                      );
                    }
                    return SectionGenerator(
                        section: state.repo.homeSections![index]);
                  },
                ),
              );
            }
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
          },
        ),
      ),
    );
  }
}
