import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lime_time_app/bloc/content/drafts/drafts_bloc.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/screens/video/video_card.dart';
import 'package:lime_time_app/screens/video/video_table.dart';
import 'package:lime_time_app/widgets/not_found.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class ShowAllDrafts extends StatefulWidget {
  const ShowAllDrafts({super.key});

  @override
  State<ShowAllDrafts> createState() => _ShowAllDraftsState();
}

class _ShowAllDraftsState extends State<ShowAllDrafts> {
  bool _isTabularView = true;
  DraftsBloc draftsBloc = DraftsBloc();

  List<bool> selectedItem = List.generate(5, (index) => false);

  @override
  void initState() {
    selectedItem[0] = true;
    draftsBloc.add(LoadDrafts('fetch_all_videos'));
    super.initState();
  }

  List<DataRow> _dataRows = [];
  List<DataColumn> _datacolumns = [];

  Widget _animatedBuilder(LoadDraftsState state) {
    _datacolumns = buildVideoTableColumns(context);
    Set<DataRow> tmpSet = {};
    for (VideoPost i in state.repo.videos) {
      tmpSet.add(buildVideoDataRow(i));
    }
    _dataRows = tmpSet.toList();

    if (state.repo.videos.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            "Wow, such empty.",
            style: defaultLabelText(context,
                fontColor: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _isTabularView
              ? Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  children: state.repo.videos
                      .map((i) => VideoCard(video: i))
                      .toList(),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: DataTable(columns: _datacolumns, rows: _dataRows))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DraftsBloc, DraftsState>(
      bloc: draftsBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is DraftsLoading) {
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
        if (state is LoadDraftsState) {
          return DynMouseScroll(
              durationMS: 200,
              scrollSpeed: 4.4,
              animationCurve: Curves.easeInOut,
              builder: (context, controller, physics) {
                return ListView(
                  physics: physics,
                  controller: controller,
                  addAutomaticKeepAlives: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("All your content",
                                style: defaultLabelText(context)),
                            SelectableText("You can view their stats and more.",
                                style: defaultSmallLabel(context,
                                    fontColor: Theme.of(context).hintColor)),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _isTabularView = !_isTabularView;
                              });
                            },
                            icon: Icon(!_isTabularView
                                ? Icons.grid_4x4_outlined
                                : Icons.table_chart_rounded))
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {
                                selectedItem =
                                    List.generate(5, (index) => false);
                                selectedItem[0] = true;
                                draftsBloc.add(LoadDrafts('fetch_all_videos'));
                              },
                              child: ChoiceChip(
                                  label: const Text('All'),
                                  selected: selectedItem[0])),
                          InkWell(
                            onTap: () {
                              selectedItem = List.generate(5, (index) => false);
                              selectedItem[1] = true;
                              draftsBloc.add(LoadDrafts('fetch_unlisted'));
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(right: 5, left: 5),
                                child: ChoiceChip(
                                    label: const Text('Unlisted'),
                                    selected: selectedItem[1])),
                          ),
                          InkWell(
                            onTap: () {
                              selectedItem = List.generate(5, (index) => false);
                              selectedItem[2] = true;
                              draftsBloc.add(LoadDrafts('fetch_all_drafts'));
                            },
                            child: Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                    label: const Text('Drafts'),
                                    selected: selectedItem[2])),
                          ),
                          InkWell(
                            onTap: () {
                              selectedItem = List.generate(5, (index) => false);
                              selectedItem[3] = true;
                              draftsBloc
                                  .add(LoadDrafts('fetch_scheduled_videos'));
                            },
                            child: Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                    label: const Text('Scheduled'),
                                    selected: selectedItem[3])),
                          ),
                          InkWell(
                            onTap: () {
                              selectedItem = List.generate(5, (index) => false);
                              selectedItem[4] = true;
                              draftsBloc.add(LoadDrafts('fetch_lounge_only'));
                            },
                            child: Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                    label: const Text('Lounge-only'),
                                    selected: selectedItem[4])),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _animatedBuilder(state)
                  ],
                );
              });
        }
        return const Error404();
      },
    );
  }
}
