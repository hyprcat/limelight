import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/models/banners/small_banner_card.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/notifications/notifications_home.dart';
import 'package:lime_time_app/screens/settings/main/settings.dart';
import 'package:lime_time_app/v1_200/cards/half_size_banner.dart';
import 'package:lime_time_app/v1_200/home/section_renderer/grid_layout_generator.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';

class LocalHub extends StatefulWidget {
  const LocalHub({super.key});

  @override
  State<LocalHub> createState() => _LocalHubState();
}

class _LocalHubState extends State<LocalHub> {
  final ScrollController _nestedScrollController = ScrollController();

  void setBadge() async {
    var temp = await NotifierEngine().getNotificationsCount();
    setState(() {
      notificationCount.value = temp;
    });
  }

  @override
  void initState() {
    setBadge();
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

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).canvasColor,
              surfaceTintColor: Theme.of(context).canvasColor,
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
              snap: true,
              floating: true,
              actions: [
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const SettingsMain(),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    icon: Icon(
                      Iconsax.language_square_outline,
                      size: 22,
                      color: theme == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                    )),
                IconButton(
                    padding: EdgeInsets.zero,
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
                              size: 22,
                              color: theme == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          );
                        })),
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
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
                      size: 22,
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
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                addAutomaticKeepAlives: true,
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: state.repo.homeSections!.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, top: 20),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: IconLabelButton(
                                icon: Iconsax.location_outline,
                                label: 'Change Location',
                                iconColor: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              )),
                        ),
                        HalfSizeBanner(
                          banner: SmallBanner(
                              label: "competition_stats",
                              type: 'metric',
                              title: "Welcome to Limelight Dehradun!",
                              description:
                                  "Your hub for everything social here.",
                              color: "121212",
                              shouldUseDarkText: false,
                              bannerLink:
                                  'https://s3.india.com/wp-content/uploads/2024/04/Feature-Image_-Mussoorie-13.jpg'),
                        ),
                        SectionGenerator(
                            section: state.repo.homeSections![index])
                      ],
                    );
                  }
                  return SectionGenerator(
                      section: state.repo.homeSections![index]);
                },
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
                    backgroundColor: Colors.transparent,
                    pathBackgroundColor: Colors.transparent),
              ),
            );
          },
        ),
      ),
    );
  }
}
