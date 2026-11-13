import 'dart:ui';

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
import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:showcaseview/showcaseview.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard>
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

  @override
  Widget build(BuildContext context) {
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
                style:
                    defaultHeadingText(context, fontWeight: FontWeight.bold)),
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
                    fontWeight: FontWeight.w500,
                    fontColor: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildState(context, state) {
      if (state is LeaderboardHomeSuccess) {
        return DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(95.0),
              child: Hero(
                tag: 'appbar-k',
                child: AppBar(
                  toolbarHeight: 110,
                  backgroundColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
                  surfaceTintColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  leading: UserProfilePicture(
                    radius: 18,
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
                  titleSpacing: 0,
                  title: searchUserField(),
                  actions: [
                    IconButton(
                        onPressed: () {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.selectionClick();
                          showBlurMenu([
                            buildBlurHeadingButton(
                                "Now Showing", Iconsax.setting_2_outline),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 10, top: 10, bottom: 30),
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
                            buildBlurHeadingButton(
                                "Location", Iconsax.location_bold),
                            for (var item in buildLocationsMenu()) item,
                          ], context, half: true);
                        },
                        icon: Icon(
                          Iconsax.setting_4_outline,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        )),
                  ],
                  bottom: TabBar(
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    padding: EdgeInsets.zero,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorPadding: EdgeInsets.zero,
                    unselectedLabelStyle: defaultLabelText(
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                    labelStyle: defaultLabelText(
                      context,
                      fontWeight: FontWeight.bold,
                    ),
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 2,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    tabs: <Widget>[
                      Tab(
                        height: 35,
                        child: Row(
                          children: [
                            const Icon(
                              Bootstrap.calendar2_day,
                              color: CupertinoColors.systemPink,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            buildTabBarText("Today's Top"),
                          ],
                        ),
                      ),
                      Tab(
                          height: 30,
                          child: Row(
                            children: [
                              const Icon(
                                Bootstrap.calendar2_week,
                                color: CupertinoColors.systemGreen,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              buildTabBarText("In this Week"),
                            ],
                          )),
                      Tab(
                          height: 30,
                          child: Row(
                            children: [
                              const Icon(
                                Bootstrap.calendar2_month,
                                color: CupertinoColors.systemTeal,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              buildTabBarText("In this month"),
                            ],
                          )),
                    ],
                  ),
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
