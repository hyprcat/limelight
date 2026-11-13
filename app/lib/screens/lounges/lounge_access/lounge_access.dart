import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/lounge_invites/lounge_invites_bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/screens/lounges/lounge_access/lounge_invite_card.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/pagination_scroll_controller.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:text_scroll/text_scroll.dart';

class LoungeAccess extends StatefulWidget {
  const LoungeAccess({super.key});

  @override
  State<LoungeAccess> createState() => _LoungeAccessState();
}

class _LoungeAccessState extends State<LoungeAccess> {
  LoungeInvitesBloc localBloc = LoungeInvitesBloc();

  PaginationScrollController paginationScrollController =
      PaginationScrollController();
  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    localBloc.add(FetchAllInvites());
    paginationScrollController.init(loadAction: () async {
      int lastPage = localBloc.userRepo.lastPage + 1;
      int currentPage = localBloc.userRepo.currentPage;
      if (lastPage > currentPage) {
        localBloc.add(FetchAllInvites());
      } else if (lastPage == currentPage) {
        return true;
      }
    });
    super.initState();
  }

  int? requests;

  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: theme == ThemeMode.light
              ? Theme.of(context).splashColor
              : Theme.of(context).cardColor.withAlpha(400),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoungeInvitesBloc, LoungeInvitesState>(
      bloc: localBloc,
      listener: (context, state) {
        if (state is InviteAccepted) {
          throwHappySnackBar(context, "You have joined a new lounge.");
          localBloc.add(FetchAllInvites());
        }
        if (state is InviteRejected) {
          throwErrorSnackBar(context, "Request removed");
          localBloc.add(FetchAllInvites());
        }
        if (state is InvitationErrorNotification) {
          throwErrorSnackBar(
              context, "Can't process your request. Please try again.");
          localBloc.add(FetchAllInvites());
        }
      },
      builder: (context, state) {
        if (state is InviteFetchSuccess) {
          requests = state.repo.totalItems;

          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
              surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(2.0),
                  child: Container(
                    color: Theme.of(context).dividerColor,
                    height: 1.0,
                  )),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              titleSpacing: 0,
              title: TextScroll("Lounge Invites",
                  style: defaultHeadingXText(context),
                  velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                  mode: TextScrollMode.endless,
                  intervalSpaces: 5),
              actions: [
                (requests != null)
                    ? _backgroundWrapper([
                        InkWell(
                          onTap: () {},
                          child: IconLabelButton(
                            icon: Iconsax.user_outline,
                            label: "$requests Invites",
                            isBig: false,
                          ),
                        )
                      ])
                    : Container()
              ],
            ),
            body: (state.repo.profiles.isEmpty)
                ? Center(
                    child: Text(
                    "Wow. Such empty.",
                    style: defaultLabelText(context,
                        fontColor: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600),
                  ))
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: paginationScrollController.scrollController,
                    shrinkWrap: true,
                    itemCount: state.repo.profiles.length,
                    itemBuilder: (context, index) {
                      UserProfile user = state.repo.profiles[index];
                      return LoungeInviteCard(
                        user: user,
                        acceptCallback: () {
                          localBloc.userRepo = UserRepo();
                          localBloc.add(AcceptInvite(
                              state.repo.profiles[index].userLounge!));
                        },
                        denyCallback: () {
                          localBloc.userRepo = UserRepo();
                          localBloc.add(RejectInvite(
                              state.repo.profiles[index].userLounge!));
                        },
                      );
                    }),
          );
        }
        if (state is InvitationError) {
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
              surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(2.0),
                  child: Container(
                    color: Theme.of(context).dividerColor,
                    height: 1.0,
                  )),
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
                "Your Lounge Invites",
                style: defaultHeadingXText(context),
              ),
            ),
            body: Center(
                child: Text(
              "Error occurred",
              style: defaultLabelText(context),
            )),
          );
        }
        if (state is InvitationsLoading) {
          return Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
                surfaceTintColor:
                    Theme.of(context).canvasColor.withOpacity(0.9),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(2.0),
                    child: Container(
                      color: Theme.of(context).dividerColor,
                      height: 1.0,
                    )),
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
                  "Your Lounge Invites",
                  style: defaultLabelXText(context),
                ),
              ),
              body: Center(
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
                      backgroundColor: Theme.of(context).canvasColor,
                      pathBackgroundColor: Theme.of(context).canvasColor),
                ),
              ));
        }
        return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
              surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(2.0),
                  child: Container(
                    color: Theme.of(context).dividerColor,
                    height: 1.0,
                  )),
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
                "Your Lounge Invites",
                style: defaultLabelXText(context),
              ),
            ),
            body: Center(
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
                    backgroundColor: Theme.of(context).canvasColor,
                    pathBackgroundColor: Theme.of(context).canvasColor),
              ),
            ));
      },
    );
  }
}
