// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';

class HorizontalUserProfileCard extends StatefulWidget {
  final UserProfile user;
  bool? forLounge;
  Function? isUntouchable;
  HorizontalUserProfileCard(
      {super.key,
      required this.user,
      this.isUntouchable,
      this.forLounge = false});

  @override
  State<HorizontalUserProfileCard> createState() =>
      _HorizontalUserProfileCardState();
}

class _HorizontalUserProfileCardState extends State<HorizontalUserProfileCard> {
  late UserChannelBloc userChannelBloc;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    userChannelBloc = UserChannelBloc(
        widget.user.userChannel!, authHandler.loggedInUser!, widget.user);
    userChannelBloc.add(LoadUserChannel(false, false));
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget buildFlare(String label, Color color) {
    return Container(
      height: 20,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(right: 4, top: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          label,
          style: defaultVerySmallLabel(context,
              fontColor: theme == ThemeMode.light
                  ? Theme.of(context).canvasColor
                  : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget backgroundWrapper2(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
          color: theme == ThemeMode.light
              ? Theme.of(context).splashColor
              : Theme.of(context).cardColor.withAlpha(400),
          borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.isUntouchable == null) {
          if (widget.forLounge!) {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: Lounge(user: widget.user),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          } else {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: UserChannel(
                user: widget.user,
                asList: false,
                canBuildVideo: checkCanBuildVideo,
              ),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        } else {
          widget.isUntouchable!(widget.user);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: getGradient(widget.forLounge!
                ? (widget.user.userLounge!.name!.isNotEmpty
                    ? widget.user.userLounge!.name!
                    : "${widget.user.userChannel!.name!}'s Lounge")
                : widget.user.userChannel!.name!.toString())),
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
              color: Colors.black38,
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        widget.forLounge!
                            ? (widget.user.userLounge!.name!.isNotEmpty
                                ? widget.user.userLounge!.name!
                                : "${widget.user.userChannel!.name!}'s Lounge")
                            : widget.user.userChannel!.name!.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: defaultLabelText(context,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PrimaryFocusButton(
                        useRoundedCorner: true,
                        label: 'Check out',
                        callback: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Lounge(user: widget.user),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        showArrow: false,
                        alternateColor: Theme.of(context).dividerColor,
                        compact: true,
                      ),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
