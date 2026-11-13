import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/home/recommended/recommended_bloc.dart';
import 'package:lime_time_app/bloc/trending_home/trending_home_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/models/banners/small_banner_card.dart';
import 'package:lime_time_app/screens/home/default/scaffold_wrapped_top_videos.dart';
import 'package:lime_time_app/screens/home/recommendations_page.dart';
import 'package:lime_time_app/screens/search/search_screen.dart';
import 'package:lime_time_app/v1_200/cards/half_size_banner.dart';
import 'package:lime_time_app/v1_200/discover/trending_scaffold_wrapper.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:text_scroll/text_scroll.dart';

import 'package:lime_time_app/screens/lounges/expanded/lounge_expanded_posts.dart';

class Discover extends StatefulWidget {
  const Discover({super.key});

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String? city;
  String? categoryId;
  String? country;
  String? region;

  bool? dayView = true;
  bool? yearView = false;
  bool? weekView = false;
  bool? monthView = false;

  TrendingHomeBloc trendingHome = TrendingHomeBloc();
  bool onlyShortVideos = false;
  @override
  void initState() {
    trendingHome.add(LoadMainTrendingHome(
        city: city,
        categoryId: categoryId,
        country: country,
        region: region,
        isDay: dayView,
        isWeek: weekView,
        isMonth: monthView,
        onlyShorts: onlyShortVideos,
        isYear: yearView!));
    trendingHome.add(LoadMainTrendingHome(
        city: city,
        categoryId: categoryId,
        country: country,
        region: region,
        isDay: dayView,
        isWeek: weekView,
        isMonth: monthView,
        onlyShorts: onlyShortVideos,
        isYear: yearView!));
    super.initState();
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
            isMonth: monthView,
            onlyShorts: onlyShortVideos,
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

  bool onlyShorts = false;
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
            onlyShorts: onlyShortVideos,
            isWeek: weekView,
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
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
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
            onlyShorts: onlyShortVideos,
            isWeek: weekView,
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
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
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
            onlyShorts: onlyShortVideos,
            isDay: dayView,
            isWeek: weekView,
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
            isDay: dayView,
            isWeek: weekView,
            onlyShorts: onlyShortVideos,
            isMonth: monthView,
            isYear: yearView!));
      }),
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

  @override
  Widget build(BuildContext context) {
    Widget buildCategoryItem({
      required String url,
      required String title,
      required Widget icon,
      required Function onTap,
      required EdgeInsets padding,
      required double containerHeight,
      required Gradient shaderGradient,
    }) {
      precacheImage(CachedNetworkImageProvider(url), context);
      Widget body(color, textColor) {
        return InkWell(
          onTap: () => onTap(),
          child: Padding(
            padding: padding,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.darken,
                    child: Container(
                      height: containerHeight,
                      decoration: BoxDecoration(
                        gradient: getGradient(title + url),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(url),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: containerHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        icon,
                        TextScroll(title,
                            style: defaultHeadingText(
                              context,
                              fontsize: 17,
                              fontColor: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            velocity:
                                const Velocity(pixelsPerSecond: Offset(25, 0)),
                            mode: TextScrollMode.endless,
                            intervalSpaces: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return body(Colors.black87, null);
    }

    Widget categoryRow({
      required String url1,
      required String url2,
      required String title1,
      required String title2,
      required Function onOneTap,
      required Function onTwoTap,
      required Widget icon1,
      required Widget icon2,
      required state,
    }) {
      double containerHeight = 100;

      return Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: buildCategoryItem(
                  url: url1,
                  title: title1,
                  icon: icon1,
                  onTap: onOneTap,
                  padding: const EdgeInsets.only(right: 4.0),
                  containerHeight: containerHeight,
                  shaderGradient: const LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Expanded(
                child: buildCategoryItem(
                  url: url2,
                  title: title2,
                  icon: icon2,
                  onTap: onTwoTap,
                  padding: const EdgeInsets.only(left: 4.0),
                  containerHeight: containerHeight,
                  shaderGradient: const LinearGradient(
                    colors: [Colors.transparent, Colors.black45],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget card(url, title) {
      precacheImage(CachedNetworkImageProvider(url), context);
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              blendMode: BlendMode.darken,
              child: Container(
                height: 175,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low),
                ),
              ),
            ),
            SizedBox(
              height: 175,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: defaultVerySmallLabel(context,
                          fontWeight: FontWeight.bold,
                          fontColor: Theme.of(context).hintColor),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    Widget searchUserField() {
      return InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const SearchScreen(),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.fade,
          );
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border:
                Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.search_normal_outline,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                "Search..",
                style: defaultLabelTextC(context,
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      child: CupertinoPageScaffold(
        child: SuperScaffold(
          brightness: Brightness.dark,
          appBar: SuperAppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            leadingWidth: 100,
            title: Text(
              "Explore",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontFamily: 'Gil'),
            ),
            searchBar: SuperSearchBar(
              enabled: false,
              resultColor: Colors.black,
              scrollBehavior: SearchBarScrollBehavior.pinned,
              resultBehavior: SearchBarResultBehavior.visibleOnFocus,
            ),
            largeTitle: SuperLargeTitle(
                largeTitle: "Explore",
                textStyle: defaultHeadingText(context, fontsize: 40)),
          ),
          body: BlocConsumer<TrendingHomeBloc, TrendingHomeState>(
            bloc: trendingHome,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is FinalTrendingState) {
                return ListView(
                  addAutomaticKeepAlives: true,
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchUserField(),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    recommendedBloc = RecommendedBloc();
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: const TopVideosScreen(
                                          onlyShortVideos: true),
                                      withNavBar:
                                          true, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: card(
                                      "https://i.giphy.com/hrp6x9Pb0KaiXbgRV0.webp",
                                      "Shorts"),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    recommendedBloc = RecommendedBloc();
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: const TopVideosScreen(
                                          onlyShortVideos: false),
                                      withNavBar:
                                          true, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: card(
                                      "https://i.giphy.com/yvgaJzI8Q01Ow.webp",
                                      "Videos"),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: const LoungeExpandedVideo(
                                        sectionName: "Threads",
                                        alternateSourceData: false,
                                      ),
                                      withNavBar:
                                          true, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: card(
                                      "https://i.giphy.com/bVcpc4QFNUxkOfCw0E.webp",
                                      "Threads"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Video Topics",
                            style: defaultHeadingText(context),
                          ),
                          categoryRow(
                              url1:
                                  "https://i.giphy.com/3ohs4oVhPxtxcgRIE8.webp",
                              url2:
                                  "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExaHo5ZWFuMWR5cTI2MHhiMmE2b2pqb3N6N25lMHg1OHlsM2xwNm9hNiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KbHJfvwP3qCZitAdl5/giphy.webp",
                              title1: "Travel",
                              title2: "Entertainment",
                              icon1: const Icon(BoxIcons.bx_train),
                              icon2: const Icon(Bootstrap.film),
                              onOneTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Travel",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onTwoTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Entertainment",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              state: state),
                          categoryRow(
                              url1:
                                  "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExOXFyN2o1dmN6bWZlYmI1bzBmc3ZpYWExYzhhdmV0dDY1dDdkdG5zbCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tAnvFB51UTTBoJMbZj/giphy.webp",
                              url2:
                                  "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExb2xycXRldmZoNmpiZHRxN3VzeXB0NDNmaXRpOTh0ZndrYXhkdW9zeSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l2R09gx3cEIxsWNmo/giphy.webp",
                              title1: "Gaming",
                              title2: "Food and Dining",
                              icon1: const Icon(BoxIcons.bx_game),
                              icon2: const Icon(Iconsax.cake_outline),
                              onOneTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Gaming",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onTwoTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Food and Dining",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              state: state),
                          categoryRow(
                              url1:
                                  "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExZzNnNXN1b21sM2ltNWl6bGh2ZnRneDE0djkydTEyM2o0cTM0ZGV1aiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KDYB0cH4HW8xc3VIAx/giphy.webp",
                              url2:
                                  "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExdjNvbGtyd3JpNGZzcWhvcjZoZTZ1OXlieHM3dHZvajczMndsdDZrOCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/MTtTKjVDz26lrN6EBo/giphy.webp",
                              title1: "Education",
                              title2: "Science and Technology",
                              icon1: const Icon(BoxIcons.bx_book),
                              icon2: const Icon(BoxIcons.bx_chip),
                              onOneTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Education",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onTwoTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Science and Technology",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              state: state),
                          categoryRow(
                              url1:
                                  "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExOG93MG9qMzkzYXd1Z2dpY3IzOGdqdDNjbmg2YTJhN2p2ZnQ1YnhzdiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3o7aD7TFLsZjgzXrZS/giphy.webp",
                              url2:
                                  "https://i.giphy.com/3o6MbsWjZwURvye0ko.webp",
                              title1: "Movies",
                              title2: "People",
                              icon1: const Icon(BoxIcons.bx_movie),
                              icon2: const Icon(BoxIcons.bx_group),
                              onOneTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Movies",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onTwoTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "People",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              state: state),
                          categoryRow(
                              url1:
                                  "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMnd2MzJ2Z3p6YTV5eDR3bnE0dGM4c2JuaGljMGt6MGYzeXVxMjk3aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/q2sDtXyQtPYqc/giphy.webp",
                              url2: "https://i.giphy.com/4oMoIbIQrvCjm.webp",
                              title1: "Sports and Fitness",
                              title2: "Music",
                              icon1: const Icon(BoxIcons.bx_football),
                              icon2: const Icon(BoxIcons.bx_music),
                              onOneTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Sports and Fitness",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onTwoTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TrendingScaffoldWrapper(
                                    city: state.city,
                                    categoryId: "Music",
                                    country: state.country,
                                    region: state.region,
                                    dayView: state.isDay,
                                    yearView: state.isMonth,
                                    weekView: state.isWeek,
                                    monthView: state.isYear,
                                  ),
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              state: state),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HalfSizeBanner(
                      banner: SmallBanner(
                          label: "competition_stats",
                          type: 'metric',
                          color: 'FF010101',
                          shouldUseDarkText: false,
                          title: "Not finding what you're looking for?",
                          description:
                              'Start creating content you would love to see on LimeLight!',
                          bannerLink: 'https://i.giphy.com/MDJ9IbxxvDUQM.webp'),
                    ),
                    const SizedBox(
                      height: 150,
                    )
                  ],
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }
}
