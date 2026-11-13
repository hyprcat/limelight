import 'dart:ui';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/leaderboard_home/leaderboard_home_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';

import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/leaderboards/leaderboard_section.dart';
import 'package:lime_time_app/screens/search/search_users.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';

class LeaderboardExperimental extends StatefulWidget {
  const LeaderboardExperimental({super.key});

  @override
  State<LeaderboardExperimental> createState() =>
      _LeaderboardExperimentalState();
}

class _LeaderboardExperimentalState extends State<LeaderboardExperimental>
    with TickerProviderStateMixin {
  String? city;
  String? categoryId;
  String? country;
  String? region;

  bool? dayView = true;
  bool? yearView = false;
  bool? weekView = false;
  bool? monthView = false;
  LeaderboardHomeBloc leaderboardHomeBloc = LeaderboardHomeBloc();

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    UserEngine().updateGeoDetails();
    tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          tabController.index = tabController.index;
        });
      }
    });

    leaderboardHomeBloc.add(LoadLeaderboardHome(
      city: city,
      categoryId: categoryId,
      country: country,
      region: region,
      isDay: dayView,
      isWeek: weekView,
      isMonth: monthView,
    ));
  }

  final GlobalKey _zero = GlobalKey();
  final GlobalKey _one = GlobalKey();

  leagues() {
    var activeStep =
        getLeagueIndex(authHandler.loggedInUser!.userChannel!.level! + 1);

    return EasyStepper(
      activeStep: 0,
      defaultStepBorderType: BorderType.normal,
      padding: EdgeInsets.zero,
      stepShape: StepShape.circle,
      stepBorderRadius: 15,
      borderThickness: 2,
      stepRadius: 28,
      finishedStepBorderColor: Colors.deepOrange,
      finishedStepTextColor: Colors.deepOrange,
      finishedStepBackgroundColor: Colors.deepOrange,
      activeStepIconColor: Colors.deepOrange,
      showLoadingAnimation: false,
      showTitle: false,
      steps: [
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 0 ? 1 : 0.3,
              child: Icon(
                Iconsax.star_bold,
                color: activeStep >= 0
                    ? CupertinoColors.systemYellow
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 1 ? 1 : 0.5,
              child: Icon(
                activeStep >= 1 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.systemGrey4
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 2 ? 1 : 0.3,
              child: Icon(
                activeStep >= 2 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.systemYellow
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 3 ? 1 : 0.3,
              child: Icon(
                activeStep >= 2 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.white
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 4 ? 1 : 0.3,
              child: Icon(
                activeStep >= 4 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.systemTeal
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 5 ? 1 : 0.3,
              child: Icon(
                activeStep >= 5 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.systemPurple
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 6 ? 1 : 0.3,
              child: Icon(
                activeStep >= 6 ? Iconsax.star_1_bold : Iconsax.star_1_outline,
                color: activeStep >= 0
                    ? CupertinoColors.systemRed
                    : Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ],
      onStepReached: (index) => setState(() => activeStep = index),
    );
  }

  remainingDay(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFC800),
        ),
      ),
    );
  }

  message(String text) {
    return Text(
      getNextTierLevel(authHandler.loggedInUser!.userChannel!.level!),
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
    );
  }

  bigTitle(String text) {
    return Text(getLeague(authHandler.loggedInUser!.userChannel!.level!),
        textAlign: TextAlign.center, style: defaultHeadingText(context));
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

  List<Widget> _buildSectionToggleRow() {
    return [
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 0;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            child: _backgroundWrapper2(
                'Today', tabController.index == 0, Iconsax.ranking_bold),
          )),
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 1;
            });
          },
          child: _backgroundWrapper2(
              'This week', tabController.index == 1, Iconsax.star_1_bold)),
      Row(
        children: [
          InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                setState(() {
                  tabController.index = 2;
                });
              },
              child: _backgroundWrapper2(
                  'This month', tabController.index == 2, Iconsax.star_1_bold)),
          IconButton(
              onPressed: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                showBlurMenu([
                  buildBlurHeadingButton(
                      "Now Showing", Iconsax.setting_2_outline),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 10, top: 10, bottom: 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.location_outline),
                            Text(
                              buildLocationLabel(),
                              style: defaultLabelText(context,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  buildBlurHeadingButton("Location", Iconsax.location_bold),
                  for (var item in buildLocationsMenu()) item,
                ], context, half: true);
              },
              icon: Icon(
                Iconsax.setting_4_outline,
                color: Theme.of(context).colorScheme.inverseSurface,
              )),
        ],
      ),
    ];
  }

  Widget buildBlurHeadingButton(String text, IconData iconData) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Icon(
            iconData,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(text,
              style: defaultHeadingText(context, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildTabBarText(String text) {
    return Text(text);
  }

  Widget buildBlurTextButton(
      String text, IconData iconData, Function callback) {
    return InkWell(
      onTap: () async {
        callback();
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(text,
                    style: defaultLabelText(context,
                        fontColor: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  List<Widget> buildLocationsMenu() {
    return [
      buildBlurTextButton("Across the Globe", Iconsax.location_outline, () {
        setState(() {
          city = null;
          country = null;
          region = null;
        });
        leaderboardHomeBloc.add(LoadLeaderboardHome(
          city: city,
          categoryId: categoryId,
          country: country,
          region: region,
          isDay: dayView,
          isWeek: weekView,
          isMonth: monthView,
        ));
      }),
      buildBlurTextButton("Within your Country", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();

        setState(() {
          country = locationData['country'];
          city = null;
          region = null;
        });
        leaderboardHomeBloc.add(LoadLeaderboardHome(
          city: city,
          categoryId: categoryId,
          country: country,
          region: region,
          isDay: dayView,
          isWeek: weekView,
          isMonth: monthView,
        ));
      }),
      buildBlurTextButton("Within your Region", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();

        setState(() {
          country = null;
          city = null;
          region = locationData['region'];
        });
        leaderboardHomeBloc.add(LoadLeaderboardHome(
          city: city,
          categoryId: categoryId,
          country: country,
          region: region,
          isDay: dayView,
          isWeek: weekView,
          isMonth: monthView,
        ));
      }),
      buildBlurTextButton("Within your city", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();

        setState(() {
          country = null;
          city = locationData['city'];
          region = null;
        });
        leaderboardHomeBloc.add(LoadLeaderboardHome(
          city: city,
          categoryId: categoryId,
          country: country,
          region: region,
          isDay: dayView,
          isWeek: weekView,
          isMonth: monthView,
        ));
      }),
    ];
  }

  String buildLocationLabel() {
    if (city != null) {
      return city!;
    }

    if (country != null) {
      return country!;
    }

    if (region != null) {
      return region!;
    }
    return "Global";
  }

  Widget buildFlare(String label, Color color, IconData icon) {
    return Container(
      height: 20,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(right: 10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            width: 3,
          ),
          Center(
            child: Text(
              label,
              style:
                  defaultVerySmallLabel(context, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchUserField() {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const SearchUsersScreen(
            withScaffold: true,
          ),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).focusColor,
        ),
        child: Row(
          children: [
            Text(
              "Search handles..",
              style: defaultSmallXLabelCustom(context,
                  fontWeight: FontWeight.w500, fontColor: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildState(context, state) {
      if (state is LeaderboardHomeSuccess) {
        return DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(235.0),
              child: Hero(
                tag: 'appbar-k',
                child: AppBar(
                  toolbarHeight: 230,
                  backgroundColor: Theme.of(context).canvasColor,
                  surfaceTintColor: Theme.of(context).canvasColor,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  titleSpacing: 0,
                  title: Container(
                    margin: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              leagues(),
                              bigTitle('Amethyst League'),
                              IconLabelButton(
                                icon: Iconsax.location_bold,
                                label: buildLocationLabel(),
                                isBig: false,
                              ),
                              message('Top 10 advance to the next league'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: TabBar(
                      controller: tabController,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.zero,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      tabs: _buildSectionToggleRow()),
                ),
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                LeaderboardSection(
                  city: city.toString(),
                  categoryId: categoryId,
                  country: country.toString(),
                  region: region.toString(),
                  dayView: true,
                  weekView: false,
                  monthView: false,
                ),
                LeaderboardSection(
                  city: city.toString(),
                  categoryId: categoryId,
                  country: country.toString(),
                  region: region.toString(),
                  dayView: false,
                  monthView: true,
                  weekView: false,
                ),
                LeaderboardSection(
                  city: city.toString(),
                  categoryId: categoryId,
                  country: country.toString(),
                  region: region.toString(),
                  dayView: false,
                  weekView: false,
                  monthView: true,
                )
              ],
            ),
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
    }

    return ShowCaseWidget(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstRun) {
            ShowCaseWidget.of(context).startShowCase([_zero, _one]);
          }
        });
        return BlocConsumer<LeaderboardHomeBloc, LeaderboardHomeState>(
          bloc: leaderboardHomeBloc,
          listener: (context, state) {},
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: buildState(context, state),
            );
          },
        );
      },
    );
  }
}

@immutable
class GithubHeader extends StatelessWidget {
  const GithubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.5),
            decoration: BoxDecoration(
                color: const Color(0xff2f2f37),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                )),
            child: const Row(
              children: [
                Icon(Icons.filter_list),
                Badge(
                  label: Text(
                    "1",
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  backgroundColor: Colors.white,
                )
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 7.0,
              right: 1,
              top: 1,
              bottom: 1,
            ),
            decoration: BoxDecoration(
                color: const Color(0xff2f2f37),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                )),
            child: const Row(
              children: [
                Text("Inbox"),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white12,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.5),
            decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: Colors.white30,
                  width: 1,
                )),
            child: const Text(
              "Unread",
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 7.0,
              right: 1,
              top: 1,
              bottom: 1,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff2f2f37),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Colors.white12,
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Text("Repository"),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
