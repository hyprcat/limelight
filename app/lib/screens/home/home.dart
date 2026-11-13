import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';

import 'package:lime_time_app/screens/notifications/notifications_home.dart';
import 'package:lime_time_app/v1_200/discover/discover.dart';
import 'package:lime_time_app/v1_300/local_hub/local_hub.dart';

import 'package:lime_time_app/v1_300/threads_video/home.dart';
import 'package:lime_time_app/v1_300/unified_add_content/add.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/widgets/miniplayer/miniplayer_overlay.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
// ignore: library_private_types_in_public_api
  static _HomeState of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>()!;
}

class _HomeState extends State<Home> {
  void updateState() {
    setState(() {});
  }

  List<Widget> _buildScreens() {
    return [
      const LocalHub(),
      const ThreadsVideoMixer(),
      const UnifiedAdd(),
      const NotificationsHome(),
      if (isExperimental) const Discover(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        textStyle: defaultVerySmallLabelAlternative(context,
            fontWeight: FontWeight.bold),
        icon: const Icon(BoxIcons.bxs_home),
        inactiveIcon: const Icon(BoxIcons.bx_home),
        title: ("Home"),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary:
            theme == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      PersistentBottomNavBarItem(
        textStyle: defaultVerySmallLabelAlternative(context,
            fontWeight: FontWeight.bold),
        icon: const Icon(BoxIcons.bxs_message),
        inactiveIcon: const Icon(BoxIcons.bx_message),
        title: ("Map view"),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary:
            theme == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      PersistentBottomNavBarItem(
        textStyle:
            defaultEvenVerySmallLabel(context, fontWeight: FontWeight.bold),
        icon: const Icon(Iconsax.add_square_bold),
        inactiveIcon: const Icon(Iconsax.add_square_outline),
        title: ("Create"),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary:
            theme == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      if (isExperimental)
        PersistentBottomNavBarItem(
          textStyle:
              defaultEvenVerySmallLabel(context, fontWeight: FontWeight.bold),
          icon: const Icon(BoxIcons.bxs_bell),
          inactiveIcon: const Icon(BoxIcons.bx_bell),
          title: ("Discover"),
          activeColorPrimary: Theme.of(context).colorScheme.primary,
          inactiveColorPrimary:
              theme == ThemeMode.dark ? Colors.white : Colors.black,
        ),
      if (isExperimental)
        PersistentBottomNavBarItem(
          textStyle: defaultVerySmallLabelAlternative(context,
              fontWeight: FontWeight.bold),
          icon: const Icon(BoxIcons.bxs_search),
          inactiveIcon: const Icon(BoxIcons.bx_search),
          title: ("Search"),
          activeColorPrimary: Theme.of(context).colorScheme.primary,
          inactiveColorPrimary:
              theme == ThemeMode.dark ? Colors.white : Colors.black,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder(
            valueListenable: isExpanded,
            builder:
                (BuildContext context, bool? showNavigationBar, Widget? child) {
              return PersistentTabView(
                context,
                isVisible: showNavigationBar!,
                controller: pTabController,
                screens: _buildScreens(),
                items: _navBarsItems(),
                confineToSafeArea: true,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,

                backgroundColor: Theme.of(context).canvasColor,
                stateManagement: true,
                bottomScreenMargin: isExperimental ? 0 : null,
                padding: const EdgeInsets.only(top: 8),
                hideNavigationBarWhenKeyboardAppears: true,
                popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
                navBarStyle: NavBarStyle.style12, // Choose the nav bar style
                // with this property.
              );
            }),
        const Align(
            alignment: Alignment.bottomCenter, child: MiniPlayerOverlay())
      ],
    );
  }
}
