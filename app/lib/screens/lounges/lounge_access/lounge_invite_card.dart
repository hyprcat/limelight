import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/screens/settings/lounges/lounge.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:lime_time_app/widgets/fundamentals/user_profile_picture.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:readmore/readmore.dart';

class LoungeInviteCard extends StatelessWidget {
  final UserProfile user;
  final Function acceptCallback;
  final Function denyCallback;
  const LoungeInviteCard(
      {super.key,
      required this.user,
      required this.acceptCallback,
      required this.denyCallback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: Lounge(user: user),
          withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: UserProfilePicture(
                    radius: 30,
                    userObj: user,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    user.userLounge!.name!.isNotEmpty
                                        ? user.userLounge!.name!
                                        : "${user.userName}'s Lounge",
                                    style: defaultLabelText(context,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  "@${user.userName!}",
                                  overflow: TextOverflow.ellipsis,
                                  style: defaultSmallXLabelCustom(context,
                                      fontColor:
                                          Theme.of(context).disabledColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                ReadMoreText(
                                  user.userLounge!.loungeDescription!.isNotEmpty
                                      ? user.userLounge!.loungeDescription!
                                      : generateRandomString(user.userName!),
                                  trimMode: TrimMode.Line,
                                  trimLines: 1,
                                  colorClickableText: Colors.pink,
                                  trimCollapsedText: '\nShow more',
                                  trimExpandedText: '\nShow less',
                                  style: defaultLabelTextForPost(context,
                                      fontColor: theme == ThemeMode.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500),
                                  moreStyle: defaultSmallLabel(context,
                                      fontWeight: FontWeight.w500,
                                      fontColor: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  lessStyle: defaultSmallLabel(context,
                                      fontWeight: FontWeight.w500,
                                      fontColor: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8, top: 4, bottom: 8),
            child: Row(
              children: [
                Expanded(
                    child: PrimaryFocusButton(
                        label: 'Join Lounge',
                        alternateColor: Theme.of(context).colorScheme.tertiary,
                        highLight: true,
                        callback: () {
                          acceptCallback();
                        })),
                Expanded(
                    child: PrimaryFocusButton(
                        label: 'Remove Request',
                        alternateColor: Theme.of(context).focusColor,
                        callback: () {
                          denyCallback();
                        })),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
            height: 0,
          )
        ],
      ),
    );
  }
}
