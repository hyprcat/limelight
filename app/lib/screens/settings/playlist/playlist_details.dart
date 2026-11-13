import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/bloc/videos/playlist/playlist_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/logics/engines/playlist_engine.dart';
import 'package:lime_time_app/logics/models/videos/playlist.dart';
import 'package:lime_time_app/screens/video/renderers/videos_renderer.dart';
import 'package:lime_time_app/screens/video/small_card.dart';
import 'package:lime_time_app/widgets/snackbars/throw_happy_snackbar.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:lime_time_app/screens/settings/playlist/edit_playlist.dart';

class PlaylistDetails extends StatefulWidget {
  final PlayList playlist;
  final int index;
  const PlaylistDetails(
      {required this.playlist, required this.index, super.key});

  @override
  State<PlaylistDetails> createState() => _PlaylistDetailsState();
}

class _PlaylistDetailsState extends State<PlaylistDetails> {
  PlaylistBloc playlistBloc = PlaylistBloc();

  @override
  void initState() {
    playlistBloc
        .add(FetchPlaylistItems(playlistId: widget.playlist.playlistId!));
    super.initState();
  }

  Color color = Colors.grey.shade700;
  Color textColor = generateTextColor(Colors.grey.shade700);

  LinearGradient getGradient(String initial) {
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
    int index = initial.codeUnitAt(0) % colors.length;
    return LinearGradient(
      colors: [colors[index], colors[index + 1]],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget thumbnail() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(
                        videoThumbnailUrl(widget.playlist.firstVideoId!)),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 2.0,
                    sigmaY: 2.0,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                    ),
                    width: double.infinity,
                    child: Image.network(
                      videoThumbnailUrl(widget.playlist.firstVideoId!),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, __, ___) {
                        return Container(
                          decoration: BoxDecoration(
                              gradient: getGradient(widget.playlist.name!)),
                        );
                      },
                    ),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Future<PaletteGenerator> _updatePaletteGenerator() async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image(
        image: ResizeImage(
          CachedNetworkImageProvider(
              videoThumbnailUrl(widget.playlist.firstVideoId!)),
          width: 10,
          height: 10,
        ),
      ).image,
    );
    setState(() {
      color = paletteGenerator.dominantColor?.color ?? Colors.grey;
      textColor = generateTextColor(color);
    });
    return paletteGenerator;
  }

  Widget videos() {
    return BlocConsumer<PlaylistBloc, PlaylistState>(
      bloc: playlistBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoadingPlaylistItems) {
          return state.repo.videos.isEmpty
              ? Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
                  child: Center(
                    child: Text(
                      'Add videos from the "Add to playlist" button from any video.',
                      textAlign: TextAlign.center,
                      style: defaultSmallLabel(context,
                          fontColor: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                )
              : DynMouseScroll(
                  durationMS: 200,
                  scrollSpeed: 4.4,
                  animationCurve: Curves.easeInOut,
                  builder: (context, controller, physics) {
                    return ListView.builder(
                        controller: controller,
                        physics: physics,
                        shrinkWrap: true,
                        itemCount: state.repo.videos.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: Key(state.repo.videos[index].id.toString()),
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
                            onDismissed: (direction) async {
                              String msg = await PlaylistHelper()
                                  .removeVideoToPlaylist(
                                      widget.playlist.playlistId!,
                                      state.repo.videos[index].id!);
                              setState(() {
                                state.repo.videos.removeAt(index);
                              });
                              throwHappySnackBar(context, msg);
                              playlistBloc.add(FetchPlaylistItems(
                                  playlistId: widget.playlist.playlistId!));
                            },
                            child: SmallCard(
                              video: state.repo.videos[index],
                              canBuildVideo: checkCanBuildVideo,
                            ),
                          );
                        });
                  });
        }
        if (state is PlaylistsError) {
          return Center(
              child: Text(
            "Error occurred",
            style: defaultLabelText(context),
          ));
        }
        return Container();
      },
    );
  }

  RichText _buildUserRow() {
    return RichText(
      softWrap: true,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(text: "", children: [
        TextSpan(
            text: "@${widget.playlist.createdBy!.userName!}",
            style: defaultLabelTextC(
              context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            )),
        TextSpan(
          text: ' • ${formatTimeAgo(widget.playlist.creationDate!)}',
          style: defaultLabelTextC(context,
              fontColor: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Widget body() {
    return ListView(
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [color, Colors.black12],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                            backgroundColor: Theme.of(context).cardColor,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              ),
                              onPressed: () {
                                SystemSound.play(SystemSoundType.click);
                                HapticFeedback.selectionClick();
                                Navigator.of(context).pop();
                              },
                            )),
                        if (authHandler.loggedInUser!.userId! ==
                            widget.playlist.createdBy!.userId!)
                          CircleAvatar(
                              backgroundColor: Theme.of(context).cardColor,
                              child: IconButton(
                                icon: Icon(
                                  BoxIcons.bx_edit,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                ),
                                onPressed: () {
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.selectionClick();
                                  PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: EditPlaylist(
                                          editMode: true,
                                          playlist: widget.playlist,
                                          callback: (name, description) {
                                            widget.playlist.name = name;
                                            widget.playlist.description =
                                                description;
                                            setState(() {});
                                            playlistBloc.add(ModifyPlaylist(
                                                name: name,
                                                description: description,
                                                playlistId: widget
                                                    .playlist.playlistId!));
                                            playlistBloc.add(FetchPlaylistItems(
                                                playlistId: widget
                                                    .playlist.playlistId!));
                                          }));
                                },
                              )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: thumbnail(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.playlist.name.toString(),
                    style: defaultHeadingText(context,
                        fontWeight: FontWeight.bold),
                  ),
                  _buildUserRow(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.playlist.description.toString(),
                    style: defaultLabelTextC(
                      context,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
        videos()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<PaletteGenerator>(
          future: _updatePaletteGenerator(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return body();
              default:
                return body();
            }
          }),
    );
  }
}
