import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/trending/trending_section.dart';

import 'package:lime_time_app/bloc/trending_home/trending_home_bloc.dart';

class TrendingScaffoldWrapper extends StatefulWidget {
  String? city;
  String? categoryId;
  String? country;
  String? region;

  bool? dayView = true;
  bool? yearView = false;
  bool? weekView = false;
  bool? monthView = false;

  TrendingScaffoldWrapper(
      {this.city,
      this.categoryId,
      this.country,
      this.region,
      this.dayView,
      this.yearView,
      this.weekView,
      this.monthView,
      super.key});

  @override
  State<TrendingScaffoldWrapper> createState() =>
      _TrendingScaffoldWrapperState();
}

class _TrendingScaffoldWrapperState extends State<TrendingScaffoldWrapper> {
  bool onlyShortVideos = false;

  TrendingHomeBloc trendingHome = TrendingHomeBloc();
  @override
  void initState() {
    trendingHome.add(LoadMainTrendingHome(
        city: widget.city,
        categoryId: widget.categoryId,
        country: widget.country,
        region: widget.region,
        onlyShorts: onlyShortVideos,
        isDay: widget.dayView,
        isWeek: widget.weekView,
        isMonth: widget.monthView,
        isYear: widget.yearView!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          widget.categoryId!,
          style: defaultHeadingText(context),
        ),
        actions: [
          Text(
            'Shorts Only',
            style: defaultVerySmallLabel(context, fontWeight: FontWeight.bold),
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
                      city: widget.city,
                      categoryId: widget.categoryId,
                      country: widget.country,
                      region: widget.region,
                      onlyShorts: onlyShortVideos,
                      isDay: widget.dayView,
                      isWeek: widget.weekView,
                      isMonth: widget.monthView,
                      isYear: widget.yearView!));
                }),
          ),
        ],
      ),
      body: BlocConsumer<TrendingHomeBloc, TrendingHomeState>(
        bloc: trendingHome,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FinalTrendingState) {
            return TrendingSection(
              city: state.city,
              categoryId: state.categoryId,
              country: state.country,
              region: state.region,
              dayView: state.isDay,
              yearView: state.isYear,
              weekView: state.isWeek,
              monthView: state.isMonth,
              onlyShortVideos: state.onlyShortVideos,
            );
          }
          return Container();
        },
      ),
    );
  }
}
