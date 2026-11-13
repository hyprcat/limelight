import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/widgets/fundamentals/full_banner_viewer.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:random_avatar/random_avatar.dart';

class ImageBanner extends StatefulWidget {
  final UserProfile userObj;
  const ImageBanner({super.key, required this.userObj});

  @override
  State<ImageBanner> createState() => _ImageBannerState();
}

class _ImageBannerState extends State<ImageBanner> {
  Widget _buildChild() {
    RandomAvatar(widget.userObj.userName!, width: double.infinity);
    if (widget.userObj.profileBanner != null &&
        widget.userObj.profileBanner != "") {
      return AspectRatio(
          aspectRatio: 32 / 9,
          child: Image.network(
            userBannerUrl(widget.userObj.userName),
            errorBuilder: (BuildContext context, _, __) {
              return AspectRatio(
                aspectRatio: 32 / 9,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      )),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                                text: "LimeLight.",
                                style: defaultHeadingText(context,
                                    fontColor: Theme.of(context)
                                        .cardColor
                                        .withAlpha(200),
                                    fontsize: 40),
                                children: const []),
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black12,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ));
    }
    return AspectRatio(
      aspectRatio: 32 / 9,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            )),
            child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                      text: "LimeLight.",
                      style: defaultHeadingXText(context,
                          fontColor: Theme.of(context).cardColor.withAlpha(200),
                          fontsize: 40),
                      children: const []),
                )),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black12,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: FullBannerView(userObj: widget.userObj),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: _buildChild());
  }
}
