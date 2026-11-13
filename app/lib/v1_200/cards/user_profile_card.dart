// ignore_for_file: must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/screens/settings/channel/user_channel.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:random_avatar/random_avatar.dart';

import 'package:lime_time_app/bloc/user_profile/user_channel/user_channel_bloc.dart';

class ExperimentalUserProfileCard extends StatefulWidget {
  final UserProfile user;
  bool? forLounge;
  Function? isUntouchable;
  ExperimentalUserProfileCard(
      {super.key,
      required this.user,
      this.isUntouchable,
      this.forLounge = false});

  @override
  State<ExperimentalUserProfileCard> createState() =>
      _ExperimentalUserProfileCardState();
}

class _ExperimentalUserProfileCardState
    extends State<ExperimentalUserProfileCard> {
  late UserChannelBloc userChannelBloc;
  late ConfettiController _controllerCenter;

  Color color = Colors.grey.shade700;
  Color textColor = generateTextColor(Colors.grey.shade700);

  Future<PaletteGenerator> _updatePaletteGenerator() async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image(
        image: ResizeImage(
          CachedNetworkImageProvider(
            profilePictureUrl(widget.user.userName),
          ),
          width: 10,
          height: 10,
        ),
      ).image,
    );
    setState(() {
      color = paletteGenerator.dominantColor?.color ?? Colors.grey;
      textColor = generateTextColor(color);
    });
    return paletteGenerator;
  }

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
    Widget buildChild() {
      Widget svgCode = RandomAvatar(widget.user.userName!,
          height: 50, width: 50, trBackground: true);

      try {
        if (widget.user.profilePicture != null &&
            widget.user.profilePicture != "") {
          var x = Image.network(
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary
                        ],
                        strokeWidth: 2,
                        backgroundColor: Colors.transparent,
                        pathBackgroundColor: Colors.transparent),
                  ),
                ],
              );
            },
            profilePictureUrl(widget.user.userName),
            errorBuilder: (BuildContext context, _, __) {
              return svgCode;
            },
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          );

          return Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: x,
          );
        }

        return svgCode;
      } catch (e) {
        return svgCode;
      }
    }

    Widget body() {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.hardLight,
                  child: buildChild()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.userName!,
                      overflow: TextOverflow.ellipsis,
                      style: defaultLabelText(context,
                          fontColor: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    if (widget.user.subscribedByCurrentUser != null)
                      BlocConsumer<UserChannelBloc, UserChannelState>(
                        bloc: userChannelBloc,
                        listener: (context, state) {
                          if (state is RefreshChannel) {
                            userChannelBloc.add(LoadUserChannel(true, true));
                          }
                        },
                        builder: (context, state) {
                          if (state is LoadingChannel) {
                            return Center(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.lineScalePulseOut,
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.tertiary
                                    ],
                                    strokeWidth: 2,
                                    backgroundColor:
                                        Theme.of(context).canvasColor,
                                    pathBackgroundColor:
                                        Theme.of(context).canvasColor),
                              ),
                            );
                          }
                          if (state is SuccessfullyLoadedChannel) {
                            Widget child = ConfettiWidget(
                              confettiController: _controllerCenter,
                              blastDirectionality:
                                  BlastDirectionality.explosive,
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
                                label: state.subscriptionStatus
                                    ? 'Already following'
                                    : 'Follow',
                                showArrow: !state.subscriptionStatus,
                                alternateColor: state.subscriptionStatus
                                    ? Theme.of(context).dividerColor
                                    : null,
                                callback: () {
                                  if (state.subscriptionStatus) {
                                    userChannelBloc.add(Unsubscribe());
                                  } else {
                                    _controllerCenter.play();
                                    userChannelBloc.add(Subscribe());
                                  }
                                },
                                highLight: !state.subscriptionStatus,
                              ),
                            );

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
      );
    }

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
        child: FutureBuilder<PaletteGenerator>(
            future: _updatePaletteGenerator(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return body();
                default:
                  return body();
              }
            }));
  }
}
