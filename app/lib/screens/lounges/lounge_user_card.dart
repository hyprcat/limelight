import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

import 'package:lime_time_app/widgets/buttons/icon_label_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';

class LoungeUserCard extends StatefulWidget {
  final UserProfile user;
  const LoungeUserCard({super.key, required this.user});

  @override
  State<LoungeUserCard> createState() => _LoungeUserCardState();
}

class _LoungeUserCardState extends State<LoungeUserCard> {
  Widget _buildFlare(String label, Color color) {
    return Container(
      height: 20,
      padding: const EdgeInsets.only(left: 10, right: 10),
      margin: const EdgeInsets.only(right: 4, top: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: theme == ThemeMode.light
                        ? Colors.grey.shade400
                        : Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: UserProfilePicture(
                  radius: 45,
                  userObj: widget.user,
                  asSquare: true,
                  doNothing: true,
                )),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            widget.user.userName.toString(),
            style: defaultLabelText(context, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildFlare("Level ${widget.user.userLounge!.level}",
                  Theme.of(context).colorScheme.secondary),
              IconLabelButton(
                  icon: Iconsax.ranking_outline,
                  label: "${widget.user.userLounge!.level} XP"),
            ],
          )
        ],
      ),
    );
  }
}
