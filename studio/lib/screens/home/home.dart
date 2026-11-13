import 'package:code_arrow_creator_studio/blocs/home/main/home_main_bloc.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/user_profile.dart';

import 'package:code_arrow_creator_studio/main.dart';
import 'package:code_arrow_creator_studio/screens/not_found.dart';
import 'package:code_arrow_creator_studio/screens/home/analytics/analytics_home.dart';
import 'package:code_arrow_creator_studio/screens/home/content/all_drafts/all_drafts.dart';
import 'package:code_arrow_creator_studio/screens/home/main_screen/main_screen.dart';
import 'package:code_arrow_creator_studio/screens/home/main_screen/upload_file_card.dart';
import 'package:code_arrow_creator_studio/screens/route_guard.dart';
import 'package:code_arrow_creator_studio/widgets/highlighted_box_item.dart';
import 'package:code_arrow_creator_studio/widgets/logo.dart';
import 'package:code_arrow_creator_studio/widgets/user_profile_picture.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class CreatorStudioHome extends StatefulWidget {
  const CreatorStudioHome({super.key});

  @override
  State<CreatorStudioHome> createState() => _CreatorStudioHomeState();

  static List<bool> selectedThing = List.generate(11, (index) => false);
}

Widget homeMainScreen = const HomeMainScreen();
List<Widget> availableSections = [
  homeMainScreen,
  const ShowAllDrafts(),
  Container(),
  const AnalyticsHome(),
  Container(),
  Container(),
  Container(),
  Container(),
  Container(),
  Container()
];

class _CreatorStudioHomeState extends State<CreatorStudioHome> with AutomaticKeepAliveClientMixin<CreatorStudioHome> {
  @override
  bool get wantKeepAlive => true;

  HomeMainBloc homeMainBloc = HomeMainBloc();

  UserProfile? userProfile;

  Widget activeContent = const HomeMainScreen();

  void _drawerCallback(int index) {
    var newStateList = List.generate(11, (index) => false);
    newStateList[index] = true;
    CreatorStudioHome.selectedThing = newStateList;
    activeContent = availableSections[index];
    setState(() {});
  }

  Widget _buildUploadThing() {
    return DynMouseScroll(builder: (context, controller, physics) {
      return ListView(
        addAutomaticKeepAlives: true,
        controller: controller,
        physics: physics,
        shrinkWrap: true,
        children: const [
          ImportVideoCard(),
          Divider(),
        ],
      );
    });
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Logo(),
      backgroundColor: Theme.of(context).canvasColor,
      automaticallyImplyLeading: false,
      actions: [
        InkWell(
          onTap: () {
            showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black45,
                transitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
                      height: 750,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.primary)),
                      child: Material(child: _buildUploadThing()),
                    ),
                  );
                });
          },
          child: Center(
            child: Icon(
              Icons.upload_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(margin: const EdgeInsets.only(left: 10, right: 10), child: UserProfilePicture(radius: 20, userObj: userProfile!))
      ],
    );
  }

  Widget _buildDrawerItems(controller, physics) {
    return ListView(
      controller: controller,
      physics: physics,
      addAutomaticKeepAlives: true,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: HighlightedBoxItem(
            icon: const Icon(Icons.dashboard),
            label: 'Dashboard',
            callback: _drawerCallback,
            index: 0,
          ),
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.video_library),
          label: 'Content',
          callback: _drawerCallback,
          index: 1,
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.group),
          label: 'Lounge',
          callback: _drawerCallback,
          index: 2,
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.analytics),
          label: 'Analytics',
          callback: _drawerCallback,
          index: 3,
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.comment),
          label: 'Comments',
          callback: _drawerCallback,
          index: 4,
        ),
        HighlightedBoxItem(icon: const Icon(Icons.subtitles), label: 'Subtitles', callback: _drawerCallback, index: 5),
        HighlightedBoxItem(
          icon: const Icon(Icons.monetization_on_outlined),
          label: 'Earn',
          callback: _drawerCallback,
          index: 6,
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.dashboard_customize),
          label: 'Customisation',
          callback: _drawerCallback,
          index: 7,
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Divider()),
        HighlightedBoxItem(
          icon: const Icon(Icons.settings),
          label: 'Settings',
          callback: _drawerCallback,
          index: 8,
        ),
        HighlightedBoxItem(
          icon: const Icon(Icons.help),
          label: 'Help',
          callback: (index) async {
            var newStateList = List.generate(11, (index) => false);
            newStateList[index] = true;
            CreatorStudioHome.selectedThing = newStateList;

            setState(() {});
          },
          index: 9,
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Divider()),
        HighlightedBoxItem(
          icon: const Icon(Icons.help),
          label: 'Sign out',
          callback: (index) {
            var newStateList = List.generate(11, (index) => false);
            newStateList[index] = true;
            CreatorStudioHome.selectedThing = newStateList;

            setState(() {});
            sessionData = null;
            storage.delete(key: 'token');
            Navigator.pushReplacementNamed(context, '/');
          },
          index: 10,
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 230,
      ),
      child: DynMouseScroll(builder: (context, controller, physics) {
        return _buildDrawerItems(controller, physics);
      }),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: DynMouseScroll(builder: (context, controller, physics) {
        return _buildDrawerItems(controller, physics);
      }),
    );
  }

  Widget _buildBody() {
    return Container(margin: const EdgeInsets.only(left: 10, right: 10), child: activeContent);
  }

  Widget _buildBodyDesktop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildPanel(),
        const SizedBox(
          width: 20,
        ),
        Expanded(child: activeContent),
      ],
    );
  }

  @override
  void initState() {
    CreatorStudioHome.selectedThing[0] = true;
    homeMainBloc.add(HomeMainLoading());
    super.initState();
  }

  Widget _buildHome() {
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      return Scaffold(
        appBar: _buildAppbar(),
        body: _buildBodyDesktop(),
      );
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      return Scaffold(
        drawer: _buildDrawer(),
        appBar: _buildAppbar(),
        body: _buildBody(),
      );
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      return Scaffold(
        drawer: _buildDrawer(),
        appBar: _buildAppbar(),
        body: _buildBody(),
      );
    } else {
      return Scaffold(
        appBar: _buildAppbar(),
        body: _buildBodyDesktop(),
      );
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Container(margin: const EdgeInsets.only(top: 5), child: Text("Loading", style: defaultLabelText(context))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RouteGuardPage(
        child: BlocConsumer<HomeMainBloc, HomeMainState>(
      bloc: homeMainBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return _buildLoadingScreen();
        }
        if (state is HomeLoadSuccess) {
          userProfile = state.loggedInUser;
          return _buildHome();
        }
        return const Error404();
      },
    ));
  }
}
