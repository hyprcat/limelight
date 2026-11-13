// ignore_for_file: prefer_final_fields, must_be_immutable

import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/widgets/fundamentals/full_dp_viewer.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:random_avatar/random_avatar.dart';

class UserProfilePicture extends StatefulWidget {
  final double radius;
  final UserProfile userObj;
  bool? asSquare;
  bool doNothing;
  Function? callback;
  bool? differentColor;
  bool? useCache;
  UserProfilePicture(
      {super.key,
      required this.radius,
      required this.userObj,
      this.callback,
      this.doNothing = false,
      this.asSquare = false,
      this.differentColor = false,
      this.useCache = false});

  @override
  State<UserProfilePicture> createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<UserProfilePicture> {
  MultipartFile? userProfilePicture;

  bool showSvg = false;
  Widget buildSvg() {
    Widget svgCode = RandomAvatar(widget.userObj.userName!,
        height: widget.radius * 2, width: widget.radius * 2);
    return CircleAvatar(
        key: const ValueKey<int>(1),
        radius: widget.radius + (7 % widget.radius),
        backgroundColor: Theme.of(context).dividerColor.withAlpha(125),
        child: svgCode);
  }

  Widget _buildChild() {
    Widget svgCode = RandomAvatar(widget.userObj.userName!,
        height: widget.radius * 2, width: widget.radius * 2);

    try {
      if (widget.userObj.profilePicture != null &&
          widget.userObj.profilePicture != "") {
        var x = ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            cacheKey:
                widget.userObj.userName! + DateTime.now().minute.toString(),
            placeholder: (_, __) {
              return svgCode;
            },
            imageUrl: profilePictureUrl(widget.userObj.userName),
            errorWidget: (BuildContext context, _, __) {
              return svgCode;
            },
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
        );

        return SizedBox(
          height: widget.radius * 2,
          width: widget.radius * 2,
          child: ClipOval(
            clipBehavior: Clip.hardEdge,
            child: x,
          ),
        );
      }

      return svgCode;
    } catch (e) {
      return svgCode;
    }
  }

  Widget mainChild() {
    return CircleAvatar(
        key: const ValueKey<int>(2),
        radius: widget.radius + (widget.radius < 19 ? 2 : 4 % widget.radius),
        backgroundColor: Colors.transparent,
        child: _buildChild());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          setState(() {
            showSvg = true;
          });
        } else {
          setState(() {
            showSvg = false;
          });
        }
      },
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
        if (!widget.doNothing) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: FullScreenDpView(userObj: widget.userObj),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        } else {
          if (widget.callback != null) {
            widget.callback!();
          }
        }
      },
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: showSvg ? buildSvg() : mainChild()),
    );
  }
}
