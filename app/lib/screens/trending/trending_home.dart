import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/trending_home/trending_home_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/screens/trending/trending_section.dart';
import 'package:lime_time_app/v1_200/discover/discover.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/blur_menu.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  String? city;
  String? categoryId;
  String? country;
  String? region;
  bool onlyShortVideos = false;
  bool? dayView = true;
  bool? yearView = false;
  bool? weekView = false;
  bool? monthView = false;

  TrendingHomeBloc trendingHome = TrendingHomeBloc();

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget searchUserField() {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const Discover(),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              BoxIcons.bx_compass,
              color: Theme.of(context).colorScheme.primary,
              size: 19,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Discover..."
              "",
              style: defaultSmallXLabelCustom(context,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void startShowCase() {}
  @override
  void initState() {
    super.initState();
    UserEngine().updateGeoDetails();
    tabController = TabController(
      initialIndex: 0,
      length: 11,
      vsync: this,
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          tabController.index = tabController.index;
        });
      }
    });

    trendingHome.add(LoadMainTrendingHome(
        city: city,
        categoryId: categoryId,
        country: country,
        onlyShorts: onlyShortVideos,
        region: region,
        isDay: dayView,
        isWeek: weekView,
        isMonth: monthView,
        isYear: yearView!));
  }

  Widget buildBlurTextButton(
      String text, IconData iconData, Function callback) {
    return InkWell(
      onTap: () async {
        callback();
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView));
        await Future.delayed(const Duration(milliseconds: 50));

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
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Within your Country", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();

        setState(() {
          country = locationData['country'];
          city = null;
          region = null;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            onlyShorts: onlyShortVideos,
            isWeek: weekView,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Within your Region", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();

        setState(() {
          country = null;
          city = null;
          region = locationData['region'];
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Within your city", Iconsax.location_outline,
          () async {
        Map locationData = await UserEngine().fetchUserLocation();
        setState(() {
          country = null;
          city = locationData['city'];
          region = null;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            onlyShorts: onlyShortVideos,
            isWeek: weekView,
            isMonth: monthView,
            isYear: yearView!));
      }),
    ];
  }

  List<Widget> buildTimePeriodMenu() {
    return [
      buildBlurTextButton("Today", Iconsax.clock_outline, () {
        setState(() {
          dayView = true;
          weekView = false;
          monthView = false;
          yearView = false;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            onlyShorts: onlyShortVideos,
            isWeek: weekView,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Past Week", Iconsax.clock_outline, () {
        setState(() {
          dayView = false;
          weekView = true;
          monthView = false;
          yearView = false;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Past Month", Iconsax.clock_outline, () {
        setState(() {
          dayView = false;
          weekView = false;
          monthView = true;
          yearView = false;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView!));
      }),
      buildBlurTextButton("Past Year", Iconsax.clock_outline, () {
        setState(() {
          dayView = false;
          weekView = false;
          monthView = false;
          yearView = true;
        });
        trendingHome.add(LoadMainTrendingHome(
            city: city,
            categoryId: categoryId,
            country: country,
            region: region,
            onlyShorts: onlyShortVideos,
            isDay: dayView,
            isWeek: weekView,
            isMonth: monthView,
            isYear: yearView!));
      }),
    ];
  }

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Color getColorForLabel(String label) {
      switch (label) {
        case 'Travel':
          return CupertinoColors.systemPink;
        case 'Gaming':
          return CupertinoColors.systemGreen;
        case 'Music':
          return CupertinoColors.systemRed;
        case 'Food and Dining':
          return CupertinoColors.systemOrange;
        case 'Entertainment':
          return CupertinoColors.systemYellow;
        case 'Education':
          return CupertinoColors.activeBlue;
        case 'Science and Technology':
          return CupertinoColors.systemPurple;
        case 'Movies':
          return CupertinoColors.systemTeal;
        case 'People':
          return CupertinoColors.systemGreen;
        case 'Sports and Fitness':
          return CupertinoColors.systemOrange;
        case 'News':
          return CupertinoColors.systemTeal;
        default:
          return Theme.of(context).iconTheme.color!; // Default color
      }
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
                style:
                    defaultHeadingText(context, fontWeight: FontWeight.bold)),
          ],
        ),
      );
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

    String buildPeriodLabel() {
      if (dayView!) {
        return "Today";
      }

      if (weekView!) {
        return "Weekly";
      }

      if (monthView!) {
        return "Monthly";
      }

      if (yearView!) {
        return "Yearly";
      }
      return "Today";
    }

    Widget backgroundWrapper2(String label, bool isSelected, IconData icon) {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 5, bottom: 5),
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
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (theme == ThemeMode.light
                        ? Theme.of(context).canvasColor
                        : Theme.of(context).primaryColor)
                    : getColorForLabel(label),
              ),
              const SizedBox(
                width: 5,
              ),
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

    List<Widget> buildSectionToggleRow() {
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
            margin: const EdgeInsets.only(left: 0),
            child: backgroundWrapper2(
                'Travel', tabController.index == 0, BoxIcons.bx_train),
          ),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 1;
            });
          },
          child: backgroundWrapper2(
              'Gaming', tabController.index == 1, BoxIcons.bx_game),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 2;
            });
          },
          child: backgroundWrapper2(
              'Music', tabController.index == 2, BoxIcons.bx_music),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 3;
            });
          },
          child: backgroundWrapper2('Food and Dining', tabController.index == 3,
              Iconsax.cake_outline),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 4;
            });
          },
          child: backgroundWrapper2(
              'Entertainment', tabController.index == 4, Bootstrap.film),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 5;
            });
          },
          child: backgroundWrapper2(
              'Education', tabController.index == 5, BoxIcons.bx_book),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 6;
            });
          },
          child: backgroundWrapper2('Science and Technology',
              tabController.index == 6, BoxIcons.bx_chip),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 7;
            });
          },
          child: backgroundWrapper2(
              'Movies', tabController.index == 7, BoxIcons.bx_movie),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 8;
            });
          },
          child: backgroundWrapper2(
              'People', tabController.index == 8, BoxIcons.bx_group),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 9;
            });
          },
          child: backgroundWrapper2('Sports and Fitness',
              tabController.index == 9, BoxIcons.bx_football),
        ),
        InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              tabController.index = 10;
            });
          },
          child: backgroundWrapper2(
              'News', tabController.index == 10, BoxIcons.bx_news),
        ),
      ];
    }

    Widget section(FinalTrendingState state, categoryId) {
      return TrendingSection(
        city: state.city,
        categoryId: categoryId,
        country: state.country,
        region: state.region,
        dayView: state.isDay,
        yearView: state.isMonth,
        weekView: state.isWeek,
        monthView: state.isYear,
        onlyShortVideos: state.onlyShortVideos,
      );
    }

    var categories = [
      'Travel',
      'Gaming',
      'Music',
      'Food and Dining',
      'Entertainment',
      'Education',
      'Science and Technology',
      'Movies',
      'People',
      "Sports and Fitness",
      'News',
    ];

    return ShowCaseWidget(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstRun) {
            ShowCaseWidget.of(context).startShowCase([_one, _two, _three]);
          }
        });

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120.0),
            child: Hero(
              tag: 'appbar-k',
              child: AppBar(
                toolbarHeight: 120,
                titleSpacing: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
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
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                ),
                flexibleSpace: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.black87,
                                  Colors.black54
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.darken,
                            child: Container()),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TabBar(
                      controller: tabController,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.zero,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      tabs: buildSectionToggleRow()),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(20),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                SystemSound.play(SystemSoundType.click);
                                HapticFeedback.selectionClick();
                                showBlurMenu([
                                  buildBlurHeadingButton(
                                      "Period", Iconsax.clock_bold),
                                  for (var item in buildTimePeriodMenu()) item,
                                ], context, half: true);
                              },
                              child: _backgroundWrapper([
                                IconLabelButton(
                                    iconColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    icon: Iconsax.clock_outline,
                                    isBig: false,
                                    label: buildPeriodLabel())
                              ])),
                          InkWell(
                              onTap: () {
                                SystemSound.play(SystemSoundType.click);
                                HapticFeedback.selectionClick();
                                showBlurMenu([
                                  buildBlurHeadingButton(
                                      "Location", Iconsax.location_bold),
                                  for (var item in buildLocationsMenu()) item,
                                ], context, half: true);
                              },
                              child: _backgroundWrapper([
                                IconLabelButton(
                                    icon: Iconsax.location_outline,
                                    iconColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    isBig: false,
                                    label: buildLocationLabel())
                              ])),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
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
                                            const Icon(
                                                Iconsax.location_outline),
                                            Text(
                                              buildLocationLabel(),
                                              style: defaultLabelText(context,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Iconsax.clock_1_outline),
                                            Text(
                                              buildPeriodLabel(),
                                              style: defaultLabelText(context,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  buildBlurHeadingButton(
                                      "Period", Iconsax.clock_bold),
                                  for (var item in buildTimePeriodMenu()) item,
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  buildBlurHeadingButton(
                                      "Location", Iconsax.location_bold),
                                  for (var item in buildLocationsMenu()) item,
                                ], context, half: true);
                              },
                              icon: Icon(
                                Iconsax.setting_4_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              )),
                          Text(
                            'Shorts Only',
                            style: defaultVerySmallLabel(context,
                                fontWeight: FontWeight.bold),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                                value: onlyShortVideos,
                                onChanged: (value) {
                                  setState(() {
                                    onlyShortVideos = value;
                                  });
                                  trendingHome.add(LoadMainTrendingHome(
                                      city: city,
                                      categoryId: categoryId,
                                      country: country,
                                      region: region,
                                      isDay: dayView,
                                      onlyShorts: onlyShortVideos,
                                      isWeek: weekView,
                                      isMonth: monthView,
                                      isYear: yearView!));
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ].reversed.toList(),
                  ),
                ),
              ),
            ),
          ),
          body: BlocConsumer<TrendingHomeBloc, TrendingHomeState>(
            bloc: trendingHome,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is FinalTrendingState) {
                var children = List.generate(tabController.length,
                    (index) => section(state, categories[index]));
                return TabBarView(
                    controller: tabController, children: children);
              }
              return Container();
            },
          ),
        );
      },
    );
  }
}
