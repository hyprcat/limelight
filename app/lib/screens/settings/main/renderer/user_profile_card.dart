// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';

class UserProfileCard extends StatefulWidget {
  final UserProfile user;
  bool? forLounge;
  Function? isUntouchable;
  UserProfileCard(
      {super.key,
      required this.user,
      this.isUntouchable,
      this.forLounge = false});

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
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
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: UserProfilePicture(
                                  radius: 20,
                                  userObj: widget.user,
                                  asSquare: true,
                                  doNothing: true,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.forLounge!
                                                    ? (widget.user.userLounge!
                                                            .name!.isNotEmpty
                                                        ? widget.user
                                                            .userLounge!.name!
                                                        : "${widget.user.userChannel!.name!}'s Lounge")
                                                    : widget
                                                        .user.userChannel!.name!
                                                        .toString(),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: defaultLabelText(context,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "@${widget.user.userName!}",
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    defaultVerySmallLabelAlternative(
                                                        context,
                                                        fontColor:
                                                            Theme.of(context)
                                                                .hintColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        if (widget
                                                .user.subscribedByCurrentUser !=
                                            null)
                                          BlocConsumer<UserChannelBloc,
                                              UserChannelState>(
                                            bloc: userChannelBloc,
                                            listener: (context, state) {
                                              if (state is RefreshChannel) {
                                                userChannelBloc.add(
                                                    LoadUserChannel(
                                                        true, true));
                                              }
                                            },
                                            builder: (context, state) {
                                              if (state is LoadingChannel) {
                                                return Center(
                                                  child: SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: LoadingIndicator(
                                                        indicatorType: Indicator
                                                            .lineScalePulseOut,
                                                        colors: [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .tertiary
                                                        ],
                                                        strokeWidth: 2,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .canvasColor,
                                                        pathBackgroundColor:
                                                            Theme.of(context)
                                                                .canvasColor),
                                                  ),
                                                );
                                              }
                                              if (state
                                                  is SuccessfullyLoadedChannel) {
                                                Widget child = ConfettiWidget(
                                                  confettiController:
                                                      _controllerCenter,
                                                  blastDirectionality:
                                                      BlastDirectionality
                                                          .explosive,
                                                  shouldLoop: false,
                                                  colors: const [
                                                    Colors.green,
                                                    Colors.blue,
                                                    Colors.pink,
                                                    Colors.orange,
                                                    Colors.purple
                                                  ], // manually specify the colors to be used
                                                  createParticlePath: drawStar,
                                                  child: PrimaryFocusButton(
                                                    compact: true,
                                                    useRoundedCorner: true,
                                                    label: state
                                                            .subscriptionStatus
                                                        ? 'Already following'
                                                        : 'Follow',
                                                    showArrow: !state
                                                        .subscriptionStatus,
                                                    alternateColor:
                                                        state.subscriptionStatus
                                                            ? Theme.of(context)
                                                                .focusColor
                                                            : null,
                                                    callback: () {
                                                      if (state
                                                          .subscriptionStatus) {
                                                        userChannelBloc
                                                            .add(Unsubscribe());
                                                      } else {
                                                        _controllerCenter
                                                            .play();
                                                        userChannelBloc
                                                            .add(Subscribe());
                                                      }
                                                    },
                                                    highLight: !state
                                                        .subscriptionStatus,
                                                  ),
                                                );

                                                if (!state.subscriptionStatus) {
                                                  return child;
                                                }
                                                return child;
                                              }
                                              return Container();
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 2,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
