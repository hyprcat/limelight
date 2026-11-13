// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/screens/settings/main/renderer/user_profile_card.dart';
import 'package:lime_time_app/screens/video/renderers/thumbnails_renderer.dart';
import 'package:lime_time_app/v1_200/cards/horizontal_profile_card.dart';
import 'package:lime_time_app/v1_200/cards/user_profile_card.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class UserProfileRenderer extends StatefulWidget {
  final List<UserProfile> data;
  bool? showRank;
  bool? forLounge;
  bool? renderAsGrid;
  bool? alternateGrid;
  UserProfileRenderer(
      {super.key,
      required this.data,
      this.showRank,
      this.forLounge,
      this.alternateGrid = false,
      this.renderAsGrid = false});

  @override
  State<UserProfileRenderer> createState() => _UserProfileRendererState();
}

class _UserProfileRendererState extends State<UserProfileRenderer> {
  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
        durationMS: 200,
        scrollSpeed: 4.4,
        animationCurve: Curves.easeInOut,
        builder: (context, controller, physics) {
          if (widget.renderAsGrid!) {
            return ScrollConfiguration(
                behavior: AppScrollBehavior(),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: widget.alternateGrid! ? EdgeInsets.zero : null,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 3.0,
                      crossAxisCount: widget.alternateGrid! ? 4 : 1,
                      childAspectRatio: widget.alternateGrid! ? 0.25 : 1),
                  itemBuilder: (context, index) {
                    UserProfile user = widget.data[index];

                    if (isExperimental && !widget.alternateGrid!) {
                      return ExperimentalUserProfileCard(
                        user: user,
                        forLounge: widget.forLounge,
                      );
                    }

                    if (widget.alternateGrid!) {
                      return HorizontalUserProfileCard(
                        user: user,
                        forLounge: widget.forLounge,
                      );
                    }

                    return UserProfileCard(
                      user: user,
                      forLounge: widget.forLounge,
                    );
                  },
                ));
          }

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              controller: controller,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                UserProfile user = widget.data[index];

                if (widget.showRank!) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 45,
                            child: AutoSizeText(
                              (index + 1).toString(),
                              style: defaultHeadingText(context,
                                  fontWeight: FontWeight.w900, fontsize: 32),
                              maxLines: 1,
                            )),
                        Expanded(
                          child: UserProfileCard(
                            user: user,
                            forLounge: widget.forLounge,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return UserProfileCard(
                  user: user,
                  forLounge: widget.forLounge,
                );
              });
        });
  }
}
