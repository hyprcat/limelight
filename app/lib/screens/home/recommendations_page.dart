import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/screens/home/default/default_subscribed_to_videos.dart';
import 'package:lime_time_app/screens/home/default/default_top_videos.dart';
import 'package:lime_time_app/screens/notifications/notifications_home.dart';
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/main/settings.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:showcaseview/showcaseview.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

RecommendedBloc recommendedBloc = RecommendedBloc();
RecommendedBloc subscriptionBloc = RecommendedBloc();
RecommendedBloc experimentalUI = RecommendedBloc();

ValueNotifier<int> notificationCount = ValueNotifier(0);

class _RecommendationsPageState extends State<RecommendationsPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  final GlobalKey _zero = GlobalKey();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _selectedIndex = 1;
  int _prevIndex = 1;

  final ScrollController _nestedScrollController = ScrollController();

  void setBadge() async {
    var temp = await NotifierEngine().getNotificationsCount();
    setState(() {
      notificationCount.value = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    recommendedBloc.add(LoadRecommendedEvent('fetch_all_videos'));
    subscriptionBloc.add(LoadSubscribedVideos());

    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    setBadge();

    tabController.animation?.addListener(() {
      if (!_tapIsBeingExecuted &&
          !_swipeIsInProgress &&
          (tabController.offset >= 0.3 || tabController.offset <= -0.3)) {
        int newIndex = tabController.offset > 0
            ? tabController.index + 1
            : tabController.index - 1;
        _swipeIsInProgress = true;
        _prevIndex = _selectedIndex;
        setState(() {
          _selectedIndex = newIndex;
        });
      } else {
        if (!_tapIsBeingExecuted &&
            _swipeIsInProgress &&
            ((tabController.offset < 0.3 && tabController.offset > 0) ||
                (tabController.offset > -0.3 && tabController.offset < 0))) {
          _swipeIsInProgress = false;
          setState(() {
            _selectedIndex = _prevIndex;
          });
        }
      }
    });
    tabController.addListener(() {
      _swipeIsInProgress = false;
      setState(() {
        _selectedIndex = tabController.index;
      });
      if (_tapIsBeingExecuted == true) {
        _tapIsBeingExecuted = false;
      } else {
        if (tabController.indexIsChanging) {
          // this is only true when the tab is changed via tap
          _tapIsBeingExecuted = true;
        }
      }
    });
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

  List<bool> selectedIndex = [true, false];
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
                  selectedIndex = [true, false];
                });
              },
              child: _backgroundWrapper2(
                  'Top Videos', selectedIndex[0], Iconsax.ranking_bold)),
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  selectedIndex = [false, true];
                });
              },
              child: _backgroundWrapper2(
                  'Subscriptions', selectedIndex[1], Iconsax.star_1_bold)),
        ],
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      blurValue: 1.5,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstRun) {
            ShowCaseWidget.of(context).startShowCase([_zero, _one, _two]);
          }
        });
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                  backgroundColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
                  surfaceTintColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
                  titleSpacing: 0,
                  title: _buildSectionToggleRow(),
                  leading: makeShowCase(
                    context: context,
                    key: _two,
                    description:
                        "See your channel, playlists and more from here.",
                    child: UserProfilePicture(
                      radius: 16,
                      userObj: authHandler.loggedInUser!,
                      doNothing: true,
                      callback: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: UserChannel(
                              user: authHandler.loggedInUser, asList: false),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const NotificationsHome(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
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
                                  style: defaultEvenVerySmallLabelCustom(
                                      context,
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
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const SettingsMain(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
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
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: selectedIndex[0]
                  ? const DefaultTopVideos(
                      key: ValueKey<int>(0),
                    )
                  : const DefaultSubscribedToVideos(
                      key: ValueKey<int>(1),
                    ),
            ),
          ),
        );
      },
    );
  }
}
