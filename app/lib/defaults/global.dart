import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/bloc/videos/comments/video_comments_bloc.dart';
import 'package:lime_time_app/bloc/videos/playlist/playlist_bloc.dart';
import 'package:lime_time_app/logics/services/auth_repository.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/widgets/miniplayer/miniplayer.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/screens/video/renderers/render_controller.dart';

RenderController listController = RenderController();
AuthRepository authHandler = AuthRepository();
TextEditingController commentController = TextEditingController();

ValueNotifier<VideoCommentRepo?> buildReplies = ValueNotifier(null);
ValueNotifier<Post?> reply = ValueNotifier(null);

VideoCommentRepo? commentsRepo;
VideoCommentsBloc? videoCommentsBloc =
    VideoCommentsBloc(VideoCommentRepo(VideoPost()));

ScrollController controllerForComments = ScrollController();
PlaylistBloc playlistBloc = PlaylistBloc();

final PersistentTabController pTabController =
    PersistentTabController(initialIndex: 0);

ValueNotifier<VideoPost?> videoListener = ValueNotifier(null);
ValueNotifier<Widget?> playerWidget = ValueNotifier(null);
ValueNotifier<bool?> isExpanded = ValueNotifier(true);

ValueNotifier<BetterPlayerController?> videoPlayerController =
    ValueNotifier(null);

List<BetterPlayerController> shortVideoTracker = [];

final MiniplayerController miniplayerController = MiniplayerController();

List<BetterPlayerController?> globalRepo = [];

int currentVideoIndex = 0;
int prevIVideoIndex = 0;

void invalidateAllControllers() {
  for (var i in globalRepo) {
    i!.dispose(forceDispose: true);
  }
  globalRepo = [];
}

ScrollController hcontroller = ScrollController();
List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.pink,
  Colors.yellow,
  Colors.teal,
  Colors.indigo,
  Colors.brown,
  Colors.cyan,
  Colors.lime,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.amber,
  Colors.blueGrey,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.green,
  Colors.indigo,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.lime,
  Colors.orange,
  Colors.pink,
  Colors.purple,
  Colors.red,
  Colors.teal,
  Colors.yellow,
];

List<Color> getColorsBannerFromText(String text) {
  // Generate a hash code from the text
  int hash = text.hashCode;
  int colorCount = colors.length;

  // Use modulo operator to select indices from the colors list
  List<Color> selectedColors = [
    colors[hash % colorCount],
    colors[(hash + 1) % colorCount],
    colors[(hash + 2) % colorCount],
    colors[(hash + 3) % colorCount],
  ];

  return selectedColors;
}

Color getBestTextColor(List<Color> backgroundColors) {
  int blackContrastScore = 0;
  int whiteContrastScore = 0;

  for (Color backgroundColor in backgroundColors) {
    double luminance = backgroundColor.computeLuminance();

    if (luminance > 0.5) {
      blackContrastScore++;
    } else {
      whiteContrastScore++;
    }
  }
  return blackContrastScore > whiteContrastScore ? Colors.black : Colors.white;
}

LinearGradient getGradient(String initial) {
  int index = initial.codeUnitAt(0) % colors.length - 1;
  return LinearGradient(
    colors: [colors[index], colors[index + 1]],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
