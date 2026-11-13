import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/search/search_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/screens/home/custom_feeds/select_topics.dart';
import 'package:lime_time_app/screens/settings/main/renderer/user_profile_card.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:lime_time_app/logics/models/users/user_profile.dart';

class SelectCreatorsCustomFeed extends StatefulWidget {
  final Map basicInfo;
  const SelectCreatorsCustomFeed({super.key, required this.basicInfo});

  @override
  State<SelectCreatorsCustomFeed> createState() =>
      _SelectCreatorsCustomFeedState();
}

class _SelectCreatorsCustomFeedState extends State<SelectCreatorsCustomFeed> {
  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(
        right: 10,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(150)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  TextEditingController textEditingController = TextEditingController();
  Widget searchUserField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: TextField(
          autofocus: false,
          maxLength: 100,
          controller: textEditingController,
          style: defaultSmallLabel(context, fontWeight: FontWeight.w600),
          onChanged: (text) {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            searchBloc.add(SearchUsers(text));
          },
          maxLines: 1,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: "Find your creators here.",
            hintStyle: defaultSmallLabel(context,
                fontColor: Theme.of(context).hintColor),
            suffixIcon: InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                searchBloc.add(SearchUsers(textEditingController.text));
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: _backgroundWrapper([
                  Text(
                    "Search",
                    style:
                        defaultSmallLabel(context, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Iconsax.search_normal_1_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<UserProfile> selectedUsers = [];
  SearchBloc searchBloc = SearchBloc();

  @override
  void initState() {
    super.initState();
  }

  void callback(user) {
    bool flag = true;
    for (UserProfile i in selectedUsers) {
      if (user.userId == i.userId) {
        flag = false;
      }
    }
    if (flag) {
      setState(() {
        selectedUsers.add(user);
      });
      throwHappySnackBar(context, "User selected");
    } else {
      throwErrorSnackBar(context, "User already selected");
    }
  }

  Widget buildState(context, state) {
    if (state is UserSearchState) {
      var widget = ListView.builder(
          shrinkWrap: true,
          itemCount: state.repo.profiles.length,
          itemBuilder: (context, index) {
            UserProfile user = state.repo.profiles[index];
            return InkWell(
                onTap: () {},
                child: UserProfileCard(
                  user: user,
                  isUntouchable: callback,
                ));
          });
      return AnimatedCoolRefresh(
          onRefresh: () async {},
          child: Stack(
            children: [
              Padding(padding: const EdgeInsets.only(top: 10), child: widget),
            ],
          ));
    }

    if (state is SearchError) {
      return Center(
          child: Text(
        "Error occurred",
        style: defaultLabelText(context),
      ));
    }
    return Container();
  }

  Widget _searchUsers() {
    return BlocConsumer<SearchBloc, SearchState>(
      bloc: searchBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: buildState(context, state),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        actions: [
          InkWell(
            onTap: () {
              var userIds = [];
              for (var i in selectedUsers) {
                userIds.add(i.userId);
              }
              Map info = widget.basicInfo;
              info['user_obj'] = selectedUsers;
              info['creators'] = userIds;
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: SelectTopics(
                  info: info,
                ),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            child: _backgroundWrapper([
              Text(
                "Next",
                style: defaultLabelText(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary),
              )
            ]),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text("Select creators that you wanna see.",
                style: defaultHeadingText(context)),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 3),
              child: StepProgressIndicator(
                totalSteps: 4,
                currentStep: 2,
                selectedColor: Theme.of(context).colorScheme.secondary,
                unselectedColor: Theme.of(context).dividerColor,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (selectedUsers.isNotEmpty)
              Wrap(children: [
                for (UserProfile i in selectedUsers)
                  InkWell(
                    onTap: () {
                      for (int j = 0; j < selectedUsers.length; j++) {
                        if (i.userId == selectedUsers[j].userId) {
                          selectedUsers.removeAt(j);
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: Builder(builder: (context) {
                        Color random = randomOpaqueColor();
                        Color textColor = random.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white;
                        return Chip(
                            backgroundColor: random,
                            label: Text(
                              i.userChannel!.name!,
                              style: defaultLabelText(context,
                                  fontWeight: FontWeight.w600,
                                  fontColor: textColor),
                            ));
                      }),
                    ),
                  )
              ]),
            const SizedBox(
              height: 20,
            ),
            searchUserField(),
            _searchUsers()
          ],
        ),
      ),
    );
  }
}
