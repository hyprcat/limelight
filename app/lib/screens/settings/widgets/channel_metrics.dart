// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/screens/settings/channel/edit_channel_details.dart';
import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:text_scroll/text_scroll.dart';

class ChannelMetrics extends StatefulWidget {
  final UserProfile? obj;
  final bool compact;
  final bool superCompact;
  final bool showChannelMetrics;
  Function? refreshCallback;
  bool showBanner;
  ChannelMetrics(
      {super.key,
      required this.obj,
      required this.compact,
      required this.showChannelMetrics,
      this.showBanner = true,
      this.superCompact = false,
      this.refreshCallback});

  @override
  State<ChannelMetrics> createState() => _ChannelMetricsState();
}

class _ChannelMetricsState extends State<ChannelMetrics> {
  late UserChannelBloc userChannelBloc;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    userChannelBloc = UserChannelBloc(
        widget.obj!.userChannel!, authHandler.loggedInUser!, widget.obj!);
    userChannelBloc.add(LoadUserChannel(false, true));
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

  bool? cacheSubscription;

  bool conditionCheck(date) {
    var base = DateTime(2024, 6, 15);
    var t1 = DateTime.parse(date);
    var difference = t1.difference(base).inDays;
    return difference.abs() <= 30;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserChannelBloc, UserChannelState>(
      bloc: userChannelBloc,
      listener: (context, state) {
        if (state is RefreshChannel) {
          userChannelBloc.add(LoadUserChannel(true, true));
        }
      },
      builder: (context, state) {
        if (state is SuccessfullyLoadedChannel) {
          cacheSubscription = state.subscriptionStatus;
          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: Theme.of(context).dividerColor,
                          child: UserProfilePicture(
                              radius: 52, asSquare: true, userObj: state.obj),
                        )),
                  ),
                  TextScroll(state.obj.userChannel!.name!,
                      style: defaultHeadingText(context,
                          fontsize: 20, fontWeight: FontWeight.bold),
                      velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                      mode: TextScrollMode.endless,
                      intervalSpaces: 5),
                  Text(
                      '@${state.obj.userName!}  Joined ${formatTimeAgoFull(widget.obj!.creationDate!)}',
                      style: defaultVerySmallLabel(context,
                          fontWeight: FontWeight.w500,
                          fontColor: Theme.of(context).disabledColor)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconLabelButton(
                        icon: Iconsax.people_outline,
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                        label:
                            "${numToEng(widget.obj!.userChannel!.subscriberCount!)} Followers",
                        vertical: true,
                        isBig: false,
                      ),
                      IconLabelButton(
                        icon: Iconsax.message_outline,
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                        isBig: false,
                        label:
                            "${numToEng(widget.obj!.userChannel!.videosCount!)} Threads",
                        vertical: true,
                      ),
                      IconLabelButton(
                        icon: Iconsax.huobi_token_ht_outline,
                        iconColor: Theme.of(context).colorScheme.inverseSurface,
                        isBig: false,
                        label:
                            "${numToEng(widget.obj!.userChannel!.xP!)} Points",
                        vertical: true,
                      )
                    ],
                  ),
                  (authHandler.loggedInUser!.userId! == widget.obj!.userId!)
                      ? SizedBox(
                          height: 51,
                          child: InkWell(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: EditChannelDetails(
                                  refreshCallback: widget.refreshCallback!,
                                  channel: widget.obj!.userChannel!,
                                ),
                                withNavBar:
                                    true, // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                    PageTransitionAnimation.fade,
                              );
                            },
                            child: const IconLabelButton(
                              label: 'Edit Profile',
                              icon: BoxIcons.bx_edit,
                            ),
                          ))
                      : Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 15,
                          ),
                          height: 51,
                          child: ConfettiWidget(
                            confettiController: _controllerCenter,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple
                            ], // manually specify the colors to be used
                            createParticlePath:
                                drawStar, // define a custom shape/path.(
                            child: PrimaryFocusButton(
                              useRoundedCorner: true,
                              label: cacheSubscription!
                                  ? 'Already following'
                                  : 'Follow',
                              callback: () {
                                if (cacheSubscription!) {
                                  userChannelBloc.add(Unsubscribe());
                                } else {
                                  _controllerCenter.play();
                                  userChannelBloc.add(Subscribe());
                                }
                              },
                              highLight: !state.subscriptionStatus,
                              showArrow: !state.subscriptionStatus,
                              alternateColor: state.subscriptionStatus
                                  ? Theme.of(context).dividerColor
                                  : null,
                            ),
                          )),
                ],
              ),
            ],
          );
        }

        if (state is LoadingChannel) {
          return Center(
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Center(
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
            ),
          );
        }

        return Center(
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
        );
      },
    );
  }
}
