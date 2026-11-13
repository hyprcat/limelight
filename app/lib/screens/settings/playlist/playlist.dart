import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/videos/playlist/playlist_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/playlist_engine.dart';
import 'package:lime_time_app/logics/repos/playlist_repo.dart';
import 'package:lime_time_app/screens/settings/playlist/playlist_details.dart';
import 'package:lime_time_app/widgets/buttons/arrow_button.dart';
import 'package:lime_time_app/widgets/fundamentals/animated_refresh.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lime_time_app/screens/settings/playlist/edit_playlist.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  @override
  void initState() {
    playlistBloc.add(FetchPlaylists(
        userId: authHandler.loggedInUser!.userId.toString(), pageNumber: 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).canvasColor, // Ensure
          statusBarIconBrightness: Brightness.light, // Adjust to fit
          // your theme
        ),
        backgroundColor: Theme.of(context).canvasColor.withAlpha(200),
        surfaceTintColor: Theme.of(context).canvasColor.withAlpha(200),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            )),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          "Playlists",
          style: defaultHeadingXText(context, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                SystemSound.play(SystemSoundType.click);
                HapticFeedback.selectionClick();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: EditPlaylist(
                    editMode: false,
                    callback: (name, description) {
                      playlistBloc.add(
                          CreatePlaylist(name: name, description: description));
                      playlistBloc.repo = PlayListRepo();
                      playlistBloc.add(FetchPlaylists(
                          userId: authHandler.loggedInUser!.userId.toString(),
                          pageNumber: 1));
                    },
                  ),
                  withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: AnimatedCoolRefresh(
        onRefresh: () async {
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
          playlistBloc.repo = PlayListRepo();
          playlistBloc.add(FetchPlaylists(
              userId: authHandler.loggedInUser!.userId.toString(),
              pageNumber: 1));
        },
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            BlocConsumer<PlaylistBloc, PlaylistState>(
              bloc: playlistBloc,
              listener: (context, state) {
                if (state is PlaylistCreated) {
                  throwHappySnackBar(context, "Playlist created.");
                }
                if (state is PlaylistModified) {
                  throwHappySnackBar(context, "Playlist modified.");
                }
              },
              builder: (context, state) {
                if (state is PlaylistsError) {
                  return Center(
                      child: Text(
                    "Error occurred",
                    style: defaultLabelText(context),
                  ));
                }

                if (state is LoadingPlaylists) {
                  return Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
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
                  );
                }

                if (state is PlaylistLoaded) {
                  return state.repo.playlists.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height / 2,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: Text(
                              'Start by creating a playlist by pressing the "+" on the top.',
                              style: defaultLabelText(context,
                                  fontColor:
                                      Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.repo.playlists.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Dismissible(
                              key: Key(
                                  state.repo.playlists[index].name.toString()),
                              onDismissed: (direction) async {
                                SystemSound.play(SystemSoundType.click);
                                HapticFeedback.selectionClick();
                                String msg = await PlaylistHelper()
                                    .removePlaylist(state
                                        .repo.playlists[index].playlistId!);

                                setState(() {
                                  state.repo.playlists.removeAt(index);
                                });
                                throwHappySnackBar(context, msg);
                                playlistBloc.add(FetchPlaylists(
                                    userId: authHandler.loggedInUser!.userId
                                        .toString(),
                                    pageNumber: 1));
                              },
                              background: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.only(
                                    top: 5, left: 20, right: 20, bottom: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      "Delete playlist",
                                      style: defaultSmallLabel(context,
                                          fontWeight: FontWeight.bold,
                                          fontColor: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.only(
                                    top: 5, left: 20, right: 20, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Delete playlist",
                                      style: defaultSmallLabel(context,
                                          fontWeight: FontWeight.bold,
                                          fontColor: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: getGradient(state
                                            .repo.playlists[index].name
                                            .toString())),
                                  ),
                                  Expanded(
                                    child: ArrowButton(
                                      label: state.repo.playlists[index].name
                                          .toString(),
                                      description: state
                                          .repo.playlists[index].description
                                          .toString(),
                                      index: 0,
                                      isPlaylist: true,
                                      callback: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: PlaylistDetails(
                                            playlist:
                                                state.repo.playlists[index],
                                            index: index,
                                          ),
                                          withNavBar:
                                              true, // OPTIONAL VALUE. True by default.
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            );
                          });
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
