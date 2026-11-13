import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/lounge/lounge_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/main.dart';
import 'package:lime_time_app/screens/settings/lounges/add_something.dart';
import 'package:lime_time_app/screens/settings/lounges/edit_lounge_details.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge_section.dart';
import 'package:lime_time_app/widgets/buttons/arrow_button.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/fundamentals/image_banner.dart';
import 'package:lime_time_app/widgets/text_widgets/text_metric.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:text_scroll/text_scroll.dart';

class Lounge extends StatefulWidget {
  final UserProfile user;
  const Lounge({super.key, required this.user});

  @override
  State<Lounge> createState() => _LoungeState();
}

class _LoungeState extends State<Lounge> with SingleTickerProviderStateMixin {
  LoungeBloc loungeBloc = LoungeBloc();
  bool isEditMode = false;

  final bodyGlobalKey = GlobalKey();
  final List<Widget> myTabs = [
    const Tab(height: 30, text: 'Sections'),
    const Tab(height: 30, text: 'Community Guidelines'),
  ];
  late TabController _tabController;
  late ScrollController _scrollController;
  bool fixedScroll = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_smoothScrollToTop);
    _scrollController.addListener(_scrollListener);
    loungeBloc.add(LoadLounge(false, widget.user));
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      fixedScroll = _tabController.index == 2;
    });
  }

  RichText _buildMetricRow() {
    return RichText(
      softWrap: true,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(text: "", children: [
        TextSpan(
          text: numToEng(widget.user.userLounge!.totalMembers!),
          style: defaultLabelTextC(context, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: (widget.user.userLounge!.totalMembers! > 1)
              ? " Members"
              : " Member",
          style: defaultLabelTextC(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: " • ",
          style: defaultLabelTextC(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: numToEng(widget.user.userLounge!.xP!),
          style: defaultLabelTextC(context, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: " XP gained",
          style: defaultLabelTextC(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Widget _backgroundWrapper(String label, bool isSelected) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: defaultSmallLabel(context,
                fontWeight: FontWeight.bold,
                fontColor: isSelected
                    ? Colors.black
                    : Theme.of(context).textTheme.labelSmall!.color)));
  }

  Widget _backgroundWrapper2(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).dividerColor.withAlpha(400),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  String buildLabel() {
    if (widget.user.userLounge!.isPublic!) {
      return "Make Lounge Private";
    }
    return "Make Lounge Public";
  }

  Widget _backgroundWrapper3(String label, bool isSelected, IconData icon) {
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
          child: _backgroundWrapper3(
              'Topics', _tabController.index == 0, Iconsax.ranking_bold)),
      InkWell(
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
            setState(() {
              _tabController.index = 1;
            });
          },
          child: _backgroundWrapper3('Community Guidelines',
              _tabController.index == 1, Iconsax.star_1_bold)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.0),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.0),
        leading: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).dividerColor,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 16,
                  ),
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                  },
                )),
          ],
        ),
        actions: [
          if (widget.user.userId != authHandler.loggedInUser!.userId)
            Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                child: InkWell(
                    onTap: () async {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.selectionClick();
                      analytics!.logEvent(
                          name: 'leave_video_lounge_shown',
                          parameters: <String, Object>{
                            'lounge_id': widget.user.userLounge!.id.toString(),
                            'clicked_by':
                                authHandler.loggedInUser!.userId!.toString()
                          });
                      showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black45,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (BuildContext buildContext,
                              Animation animation,
                              Animation secondaryAnimation) {
                            return Center(
                              child: Container(
                                width: 400,
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(
                                    left: 50, right: 50, top: 50, bottom: 50),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorDark,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            Theme.of(context).disabledColor)),
                                child: Material(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        "Are you sure that you want to leave this lounge?",
                                        style: defaultHeadingText(context)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SelectableText(
                                        "Once left, You cannot rejoin til you get an invite from this lounge.",
                                        style: defaultSmallLabel(context)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    PrimaryFocusButton(
                                        label: "Yes, Leave this lounge.",
                                        callback: () async {
                                          var response = await LoungeEngine()
                                              .leaveLounge({
                                            "lounge_id":
                                                widget.user.userLounge!.id,
                                            "token": sessionData!['token']
                                          });
                                          if (response == "Deleted video") {
                                            throwHappySnackBar(context,
                                                "Requested to delete your video. It should be deleted in a few moments.");
                                            Navigator.of(buildContext,
                                                    rootNavigator: true)
                                                .pop(buildContext);
                                          } else {
                                            throwErrorSnackBar(
                                                context, response);
                                            Navigator.of(buildContext,
                                                    rootNavigator: true)
                                                .pop(buildContext);
                                          }
                                        }),
                                  ],
                                )),
                              ),
                            );
                          });
                    },
                    child: Row(
                      children: [
                        Text(
                          "Leave",
                          style: defaultSmallLabel(context,
                              fontWeight: FontWeight.w600,
                              fontColor: Theme.of(context).hintColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Iconsax.arrow_right_2_outline,
                          color: Theme.of(context).hintColor,
                        )
                      ],
                    ))),
          if (widget.user.userId == authHandler.loggedInUser!.userId)
            PopupMenuButton(
              child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).dividerColor,
                  child: const Icon(
                    Icons.more_horiz,
                    size: 16,
                  )),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  enabled:
                      (widget.user.userId == authHandler.loggedInUser!.userId),
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.selectionClick();
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black45,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (BuildContext buildContext,
                            Animation animation, Animation secondaryAnimation) {
                          return Center(
                            child: Container(
                              width: 450,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(
                                  left: 50, right: 50, top: 50, bottom: 50),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                              child: Material(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Change visibility of your lounge",
                                      style: defaultHeadingText(context)),
                                  SelectableText(
                                      "Typically, your lounge is set only for your members but you can open it up for everyone so that they can interact with you.",
                                      style: defaultSmallLabel(context)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  PrimaryFocusButton(
                                      label: buildLabel(),
                                      callback: () async {
                                        var result = await LoungeEngine()
                                            .changeLoungeVisibility({
                                          'token': sessionData!['token']
                                        });
                                        if (result) {
                                          throwHappySnackBar(
                                              context, "Operation Success");
                                        } else {
                                          throwErrorSnackBar(context,
                                              "Something happened while changing lounge visibility. retry again.");
                                        }
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(context);
                                      })
                                ],
                              )),
                            ),
                          );
                        });
                  },
                  child: Row(
                    children: [
                      const Icon(Iconsax.eye_outline),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Change visibility',
                        style: defaultSmallLabel(context),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: EditLoungeDetails(
                        refreshCallback: () {
                          loungeBloc.add(LoadLounge(true, widget.user));
                        },
                      ),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  enabled:
                      (widget.user.userId == authHandler.loggedInUser!.userId),
                  child: Row(
                    children: [
                      const Icon(Iconsax.edit_outline),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Edit Lounge Details',
                        style: defaultSmallLabel(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      floatingActionButton: (widget.user.userId ==
              authHandler.loggedInUser!.userId)
          ? isEditMode
              ? FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: Text("Save",
                      style: defaultLabelText(context,
                          fontWeight: FontWeight.bold,
                          fontColor: Colors.black)),
                  onPressed: () {},
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton(
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.selectionClick();
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: AddToLounge(),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.add,
                      color: theme == ThemeMode.light
                          ? Theme.of(context).canvasColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                )
          : null,
      body: BlocConsumer<LoungeBloc, LoungeState>(
        bloc: loungeBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoungeSuccess) {
            Map<String?, List<LoungeSection>> categorySectionMap = {};

            if (state.lounge.isLocked) {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 50,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        "This lounge is locked for you. \nWatch content more from this creator to get an invite for this lounge.",
                        style: defaultNormalText(context,
                            fontWeight: FontWeight.w600,
                            fontColor: Theme.of(context).hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            for (LoungeCategory category in state.lounge.categories!) {
              final categoryName = category.categoryName;
              categorySectionMap[categoryName] = [];
              for (LoungeSection section in state.lounge.sections!) {
                if (categoryName == section.relatedCategory) {
                  categorySectionMap[categoryName]!.add(section);
                }
              }
            }

            Widget guideLineText(String rule, IconData icon) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10, top: 15, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 35,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Text(
                      rule,
                      style: defaultLabelText(context,
                          fontWeight: FontWeight.w500,
                          fontColor: Theme.of(context).hintColor),
                    ))
                  ],
                ),
              );
            }

            Widget loungeHeader() {
              return Stack(
                children: [
                  ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme == ThemeMode.light
                                  ? Colors.white54
                                  : Colors.black12,
                              theme == ThemeMode.light
                                  ? Colors.white
                                  : Colors.black
                            ]).createShader(bounds);
                      },
                      blendMode: theme == ThemeMode.light
                          ? BlendMode.lighten
                          : BlendMode.darken,
                      child: ImageBanner(userObj: widget.user)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 32 / 9,
                        child: Container(),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 20, bottom: 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Theme.of(context).dividerColor,
                              child: UserProfilePicture(
                                  radius: 52,
                                  asSquare: true,
                                  userObj: widget.user),
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: TextScroll(
                                        state.lounge.name!.isNotEmpty
                                            ? state.lounge.name!
                                            : "${widget.user.userName}'s Lounge",
                                        style: defaultHeadingText(context,
                                            fontWeight: FontWeight.bold),
                                        velocity: const Velocity(
                                            pixelsPerSecond: Offset(25, 0)),
                                        mode: TextScrollMode.endless,
                                        intervalSpaces: 5),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 10, top: 5),
                                    child: (true)
                                        ? _buildMetricRow()
                                        : Row(
                                            children: [
                                              _backgroundWrapper2([
                                                TextMetric(
                                                  label: "Members",
                                                  value: numToEng(widget
                                                      .user
                                                      .userLounge!
                                                      .totalMembers!),
                                                  reverse: true,
                                                  labelColor: Theme.of(context)
                                                      .hintColor,
                                                  valueColor: Theme.of(context)
                                                      .hintColor,
                                                  bold: false,
                                                  compact: true,
                                                ),
                                              ]),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              _backgroundWrapper2([
                                                TextMetric(
                                                  label: "Level",
                                                  value: numToEng(widget
                                                      .user.userLounge!.level!),
                                                  reverse: true,
                                                  labelColor: Theme.of(context)
                                                      .hintColor,
                                                  valueColor: Theme.of(context)
                                                      .hintColor,
                                                  bold: false,
                                                  compact: true,
                                                ),
                                              ]),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              _backgroundWrapper2([
                                                TextMetric(
                                                  label: "Total XP",
                                                  value: numToEng(widget
                                                      .user.userLounge!.xP!),
                                                  reverse: true,
                                                  labelColor: Theme.of(context)
                                                      .hintColor,
                                                  valueColor: Theme.of(context)
                                                      .hintColor,
                                                  bold: false,
                                                  compact: true,
                                                )
                                              ]),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          state.lounge.loungeDescription!.isNotEmpty
                              ? state.lounge.loungeDescription!
                              : "You can interact with the owner of the lounge in any of the lounge sections. Make sure to follow LimeLight's and Creator's guidelines for Lounges.",
                          style: defaultLabelTextForPost(context,
                              fontColor: theme == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.security_outline,
                                  size: 18,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  state.lounge.isPublic!
                                      ? "Public Lounge"
                                      : "Private Lounge",
                                  style: defaultLabelText(context,
                                      fontWeight: FontWeight.w600,
                                      fontColor: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ],
              );
            }

            Widget mainLounge() {
              return Column(
                children: [
                  state.lounge.categories!.isEmpty
                      ? Container(
                          height: 200,
                          margin: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              (widget.user.userId ==
                                      authHandler.loggedInUser!.userId)
                                  ? "Looks empty. Start by creating a new category from the bright button you see down there."
                                  : "Something legendary will be here soon.",
                              style: defaultSmallLabel(context,
                                  fontColor:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: state.lounge.categories!.length,
                          itemBuilder: (context, index) {
                            LoungeCategory category =
                                state.lounge.categories![index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: TextFormField(
                                                readOnly: true,
                                                initialValue:
                                                    category.categoryName!,
                                                style: defaultHeadingText(
                                                  context,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  border: isEditMode
                                                      ? null
                                                      : InputBorder.none,
                                                  contentPadding: isEditMode
                                                      ? const EdgeInsets.all(5)
                                                      : EdgeInsets.zero,
                                                  isDense: true,
                                                  hintText: 'Category tile',
                                                ),
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    category
                                                        .categoryDescription!,
                                                    style:
                                                        defaultVerySmallLabelCustom(
                                                      context,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (widget.user.userId ==
                                          authHandler.loggedInUser)
                                        InkWell(
                                            onTap: () {
                                              TextEditingController
                                                  categoryNameController =
                                                  TextEditingController();
                                              TextEditingController
                                                  categoryDescriptionController =
                                                  TextEditingController();

                                              categoryNameController.text =
                                                  category.categoryName!;
                                              categoryDescriptionController
                                                      .text =
                                                  category.categoryDescription!;

                                              PersistentNavBarNavigator
                                                  .pushNewScreen(
                                                context,
                                                screen: AddToLounge(
                                                  modifyMode: true,
                                                  categoryDescriptionController:
                                                      category
                                                          .categoryDescription!,
                                                  categoryNameController:
                                                      category.categoryName,
                                                  categoryId: category.id,
                                                ),
                                                withNavBar:
                                                    false, // OPTIONAL VALUE. True by default.
                                                pageTransitionAnimation:
                                                    PageTransitionAnimation
                                                        .cupertino,
                                              );
                                            },
                                            child: _backgroundWrapper(
                                                "Edit", true)),
                                      const SizedBox(
                                        width: 10,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                categorySectionMap[category.categoryName!]!
                                        .isEmpty
                                    ? Container(
                                        height: 200,
                                        margin: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                            "Create a new section for this category for all the madness you want here.",
                                            style: defaultSmallLabel(context,
                                                fontColor: Theme.of(context)
                                                    .disabledColor,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 10),
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: categorySectionMap[
                                                    category.categoryName!]!
                                                .length,
                                            shrinkWrap: true,
                                            controller: _scrollController,
                                            itemBuilder: (context, index) {
                                              LoungeSection? section =
                                                  categorySectionMap[category
                                                      .categoryName]![index];
                                              return Stack(
                                                children: [
                                                  Column(
                                                    children: [
                                                      ArrowButton(
                                                        label: section
                                                            .sectionName!,
                                                        description: section
                                                            .sectionDescription!,
                                                        index: index,
                                                        callback: () {
                                                          PersistentNavBarNavigator
                                                              .pushNewScreen(
                                                            context,
                                                            screen:
                                                                LoungeSectionPage(
                                                              section: section,
                                                              user: widget.user,
                                                            ),
                                                            withNavBar: false,
                                                            pageTransitionAnimation:
                                                                PageTransitionAnimation
                                                                    .cupertino,
                                                          );
                                                        },
                                                      ),
                                                      Divider(
                                                        color: Theme.of(context)
                                                            .dividerColor,
                                                      )
                                                    ],
                                                  ),
                                                  section.minimumLevelRequired! >
                                                          1
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            50,
                                                                        top:
                                                                            10),
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child:
                                                                    const Icon(
                                                                  Icons.lock,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .yellow,
                                                                )),
                                                          ],
                                                        )
                                                      : Container()
                                                ],
                                              );
                                            }),
                                      ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            );
                          }),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              );
            }

            Widget communityGuidelines() {
              return Column(
                children: [
                  guideLineText(
                      "Ensure your post is relevant to the section or category you are posting in.",
                      Iconsax.information_outline),
                  guideLineText(
                      "Respect the privacy of others. Do not share personal information about yourself or others.",
                      Iconsax.lock_outline),
                  guideLineText(
                      "Treat all members with respect and courtesy. No hate speech, harassment, or discrimination based on race, gender, religion, sexual orientation, or any other characteristic.",
                      Iconsax.people_outline),
                  guideLineText(
                      "Use respectful and appropriate language. Avoid profanity and offensive terms.",
                      Iconsax.language_square_outline),
                  guideLineText(
                      "No spam, self-promotion, or unsolicited advertising. Share links only if relevant to the discussion and allowed by the community rules.",
                      Iconsax.language_square_outline),
                  guideLineText(
                      "When giving feedback, be constructive and helpful. Avoid negativity and personal attacks.",
                      Iconsax.bubble_outline),
                ],
              );
            }

            return AnimatedCoolRefresh(
              onRefresh: () async {
                loungeBloc.add(LoadLounge(false, widget.user));
              },
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, value) {
                  return [
                    SliverToBoxAdapter(child: Container(child: loungeHeader())),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: TabBar(
                          controller: _tabController,
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
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [mainLounge(), communityGuidelines()],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
