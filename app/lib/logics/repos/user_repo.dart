import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/screens/settings/main/renderer/user_profile_renderer.dart';

class UserRepo {
  int currentPage = 1;
  int lastPage = 1;
  int totalItems = 0;
  List<UserProfile> profiles = [];

  void removeDuplicates() {
    final seen = <int>{}; // Set to store seen videoIds
    profiles.retainWhere((video) {
      return seen.add(video.userId!);
    });
  }

  Widget noProfilesFound(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          "Wow, such empty.",
          style: defaultSmallLabel(context,
              fontColor: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget renderProfiles(BuildContext context,
      {bool showRanks = false,
      bool forLounge = false,
      bool renderAsGrid = false,
      bool alternateGrid = false}) {
    if (profiles.isEmpty) {
      return noProfilesFound(context);
    }
    removeDuplicates();
    return UserProfileRenderer(
      data: profiles,
      renderAsGrid: renderAsGrid,
      showRank: showRanks,
      forLounge: forLounge,
      alternateGrid: alternateGrid,
    );
  }
}
