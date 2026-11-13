import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/main.dart';

class HazelAIHome extends StatefulWidget {
  const HazelAIHome({super.key});

  @override
  State<HazelAIHome> createState() => _HazelAIHomeState();
}

class _HazelAIHomeState extends State<HazelAIHome> {
  Widget Tile(int index, String title, String description, String progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(400),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: defaultHeadingText(context),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  description,
                  style: defaultVerySmallLabel(context,
                      fontColor: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (index == 0)
                  CupertinoSwitch(
                      value: isExperimental,
                      onChanged: (newval) {
                        MyApp.of(context).toggleExperimentalUI();
                      })
              ],
            ),
          ),
        ],
      ),
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
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(Iconsax.cloud_lightning_outline),
                const SizedBox(
                  width: 5,
                ),
                Text("Upcoming Features", style: defaultHeadingText(context)),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
                "Our experiments and soon to be launched features are here. You can toggle them on once they are available.",
                style: defaultLabelText(context,
                    fontColor: Theme.of(context).hintColor)),
            Divider(
              color: Theme.of(context).dividerColor,
            ),
            Tile(0, "Experimental Layout", "A new redesign with major changes",
                ""),
            Tile(
                1,
                "Custom Feeds",
                "You can create custom feeds by choosing your favourite topics and your favourite creators - enabling content from only from these categories will be visible in this feed. You can share this feed with anybody on the platform",
                "JUST AROUND THE CORNER"),
            Tile(
                2,
                "Hazel Bots",
                "Localised bots for each lounge, trained on your content on the platform along with AI Bot that will act as a summarizer for all search queries, videos, comments and other things on platform.",
                "JUST AROUND THE CORNER"),
            Tile(
                3,
                "Achievements and Ranks",
                "Your level will be used to unlock various achievements along with how you interact with the platform. Note that you are currently also gaining points in each of the major category-wise too, thus unlocking ranks. ",
                "JUST AROUND THE CORNER"),
            Tile(
                4,
                "Rewards",
                "By interacting with the platform more frequently, you will gain Hazel Tokens - that you can use to get first party or third party rewards along with a mechanism to trade these rewards between your friends and other people on platform. ",
                "JUST AROUND THE CORNER"),
            Tile(
                5,
                "Narratives",
                "A new type of highly interactive content that factors in multiple forms of content that provides a cohesive story to the viewer with a storyline.",
                "SOON"),
            Tile(
                5,
                "Mini games and more",
                "You will be able to create mini games, polls, challenges and more in your lounges for your audiences to build engagement and loyalty. ",
                "SOON"),
            Tile(
                6,
                "Token Governance",
                "You will be to vote for the features and policies you want on the platform each month using your Hazel Tokens. Priority will be given to the one with highest votes.",
                "SOON"),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
