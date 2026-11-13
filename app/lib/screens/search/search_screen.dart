// ignore_for_file: unused_local_variable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/search/search_lounge_posts.dart';
import 'package:lime_time_app/screens/search/search_users.dart';
import 'package:lime_time_app/screens/search/search_videos.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

SearchBloc searchBloc = SearchBloc();
ValueNotifier<String> query = ValueNotifier("");

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  Widget buildTabBarText(String text) {
    return Text(text);
  }

  late TabController tabController;

  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _selectedIndex = 1;
  int _prevIndex = 1;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    tabController.animation?.addListener(() {
      if (!_tapIsBeingExecuted &&
          !_swipeIsInProgress &&
          (tabController.offset >= 0.5 || tabController.offset <= -0.5)) {
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
            ((tabController.offset < 0.5 && tabController.offset > 0) ||
                (tabController.offset > -0.5 && tabController.offset < 0))) {
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
              tabController.index = 0;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            child: _backgroundWrapper2(
                'Videos', tabController.index == 0, Iconsax.ranking_bold),
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
              'Users', tabController.index == 1, Iconsax.star_1_bold)),
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
                  "Threads", tabController.index == 2, Iconsax.star_1_bold)),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.setting_4_outline,
                color: Theme.of(context).colorScheme.inverseSurface,
              )),
        ],
      ),
    ];
  }

  Widget searchUserField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 5),
        child: TextField(
          autofocus: true,
          maxLength: 100,
          style: defaultSmallXLabelCustom(context, fontWeight: FontWeight.w600),
          onChanged: (text) {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            searchQuery.value = text;
          },
          maxLines: 1,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: "What are you looking for?",
            hintStyle: defaultSmallXLabelCustom(context,
                fontColor: Theme.of(context).disabledColor),
            prefix: InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Iconsax.search_normal_1_outline,
                  color: Theme.of(context).colorScheme.inverseSurface,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController control = TextEditingController();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Hero(
          tag: 'appbar-k',
          child: AppBar(
            elevation: 0,
            titleSpacing: 10,
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
            automaticallyImplyLeading: true,
            title: searchUserField(),
            bottom: TabBar(
              controller: tabController,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              tabs: _buildSectionToggleRow(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          SearchVideosScreen(
            withScaffold: false,
          ),
          SearchUsersScreen(
            withScaffold: false,
          ),
          SearchLoungePostsScreen()
        ],
      ),
    );
  }
}
