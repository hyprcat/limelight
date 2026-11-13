import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/notifications/sections/n_for_you.dart';
import 'package:lime_time_app/screens/notifications/sections/n_subscriptions.dart';
import 'package:lime_time_app/screens/notifications/sections/n_threads.dart';

class NotificationsHome extends StatefulWidget {
  const NotificationsHome({super.key});

  @override
  State<NotificationsHome> createState() => _NotificationsHomeState();
}

class _NotificationsHomeState extends State<NotificationsHome>
    with SingleTickerProviderStateMixin {
  Widget buildTabBarText(String text) {
    return Text(text);
  }

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _tabController.index = _tabController.index;
        });
      });
    });
    super.initState();
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
              _tabController.index = 0;
            });
          },
          child: _backgroundWrapper2(
              'For you', _tabController.index == 0, Iconsax.ranking_bold)),
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              _tabController.index = 1;
            });
          },
          child: _backgroundWrapper2(
              'Subscriptions', _tabController.index == 1, Iconsax.star_1_bold)),
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              _tabController.index = 2;
            });
          },
          child: _backgroundWrapper2(
              'Threads', _tabController.index == 2, Iconsax.star_1_bold))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          elevation: 0,
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
          title: Text("Notifications",
              style: defaultLabelText(context, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    tabs: _buildSectionToggleRow(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [NForYou(), NSubscriptions(), NThreads()],
      ),
    );
  }
}
