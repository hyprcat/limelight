import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/contests/september_bloc.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/banners/big_banner.dart';
import 'package:lime_time_app/v1_200/cards/full_size_banner_card.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:lime_time_app/defaults/fonts.dart';

class SeptemberContest extends StatefulWidget {
  const SeptemberContest({super.key});

  @override
  State<SeptemberContest> createState() => _SeptemberContestState();
}

class _SeptemberContestState extends State<SeptemberContest> {
  SeptemberBloc septemberBloc = SeptemberBloc();

  @override
  void initState() {
    septemberBloc.add(LoadContestData());
    super.initState();
  }

  Widget guideLineText(String rule, IconData icon) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10, top: 15, bottom: 10),
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
            style: defaultLabelText(
              context,
              fontWeight: FontWeight.w500,
            ),
          ))
        ],
      ),
    );
  }

  Widget miniGuideLineText(String rule, IconData icon) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10, top: 15, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(
            rule,
            style: defaultSmallLabel(context,
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).disabledColor),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        titleSpacing: 0,
        title: Text(
          "September Contest 2024",
          style: defaultLabelText(context, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: BlocConsumer<SeptemberBloc, SeptemberState>(
        bloc: septemberBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoadingSeptemberState) {
            return Center(
              child: SizedBox(
                height: 100,
                width: 100,
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

          if (state is ErrorSeptemberState) {
            return AspectRatio(
              aspectRatio: 4 / 5,
              child: Center(
                  child: Text(
                "Error occurred",
                style: defaultLabelText(context),
              )),
            );
          }

          if (state is SeptemberContestLoadSuccessful) {
            String titleText() {
              if (state.data.subscriberCount == 0) {
                return "Start sharing your LimeLight profile and win exciting prizes!";
              }
              return 'You have gained ${state.data.subscriberCount} subscribers!';
            }

            String descriptionText() {
              if (state.data.subscriberCount == 0) {
                return "Chance to become a star creator, ₹10,000 and more!";
              }
              return 'Keep going like this and you might win the contest!';
            }

            return ListView(
              children: [
                FullSizeBannerCard(
                  banner: ContestBanner(
                      label: "competition_stats",
                      type: 'metric',
                      color: '990000',
                      shouldUseDarkText: false,
                      title: titleText(),
                      description: descriptionText(),
                      bannerLink: 'https://i.giphy.com/l46C4V2qwwdO9786k.webp'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "HOW TO PARTICIPATE",
                    style: defaultLabelText(context,
                        fontColor: Theme.of(context).hintColor),
                  ),
                ),
                guideLineText(
                    "Create Limelight profile during ${dateTimeToWords(state.data.startDate!)} and ${dateTimeToWords(state.data.endDate!)}",
                    Iconsax.user_cirlce_add_outline),
                guideLineText(
                    "Add your friends, family and people you know into Limelight. Ask them to subscribe you here on @${authHandler.loggedInUser!.userName}.",
                    Iconsax.share_outline),
                guideLineText(
                    'The user who has gained the most subscribers during this period will win the prize money, followed by exclusive gifts to the Top 10.',
                    Iconsax.information_outline),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "GENERAL RULES",
                    style: defaultLabelText(context,
                        fontColor: Theme.of(context).hintColor),
                  ),
                ),
                guideLineText(
                    "Exclusive rewards include TWS earbuds and other sorts of gifts.",
                    Iconsax.gift_outline),
                guideLineText(
                    'We will be reaching you out via your email, ${authHandler.loggedInUser!.userEmail!}, Please check your email once the contest is over.',
                    Iconsax.message_2_outline),
                const SizedBox(
                  height: 20,
                ),
                miniGuideLineText(
                    "DISCLAIMER: This contest is part of LimeLight Social's marketing strategy and is not sponsored, endorsed, administered by, or associated with Apple Inc., Google Play, or any other companies affiliated with LimeLight. LimeLight Social and its associates do not promote or allow gambling activities on the platform.",
                    Iconsax.information_outline),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Have issues with the contest? \nReach out to us at support@hazel.gg",
                        style: defaultVerySmallLabel(context,
                            fontColor: Theme.of(context).disabledColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 150,
                ),
              ],
            );
          }

          return Container();
        },
      ),
    );
  }
}
