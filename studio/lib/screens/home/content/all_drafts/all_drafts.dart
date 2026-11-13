import 'package:code_arrow_creator_studio/blocs/content/drafts/drafts_bloc.dart';
import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/screens/not_found.dart';
import 'package:code_arrow_creator_studio/widgets/video_card.dart';
import 'package:code_arrow_creator_studio/widgets/video_data_row.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Widget _buildBody(List<Widget> children) {
    return DynMouseScroll(builder: (context, controller, physics) {
      return ListView(addAutomaticKeepAlives: true, controller: controller, physics: physics, shrinkWrap: true, children: children);
    });
  }

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
            style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary),
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
                  children: state.repo.videos.map((i) => VideoCard(video: i)).toList(),
                )
              : Align(alignment: Alignment.centerLeft, child: DataTable(columns: _datacolumns, rows: _dataRows))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DraftsBloc, DraftsState>(
      bloc: draftsBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is DraftsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is LoadDraftsState) {
          return DynMouseScroll(builder: (context, controller, physics) {
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
                        Text("All your content", style: defaultLabelText(context)),
                        SelectableText("You can view their stats and more.",
                            style: defaultSmallLabel(context, fontColor: Theme.of(context).hintColor)),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isTabularView = !_isTabularView;
                          });
                        },
                        icon: Icon(!_isTabularView ? Icons.grid_4x4_outlined : Icons.table_chart_rounded))
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            selectedItem = List.generate(5, (index) => false);
                            selectedItem[0] = true;
                            draftsBloc.add(LoadDrafts('fetch_all_videos'));
                          },
                          child: ChoiceChip(label: const Text('All'), selected: selectedItem[0])),
                      InkWell(
                        onTap: () {
                          selectedItem = List.generate(5, (index) => false);
                          selectedItem[1] = true;
                          draftsBloc.add(LoadDrafts('fetch_unlisted'));
                        },
                        child: Container(
                            margin: const EdgeInsets.only(right: 5, left: 5),
                            child: ChoiceChip(label: const Text('Unlisted'), selected: selectedItem[1])),
                      ),
                      InkWell(
                        onTap: () {
                          selectedItem = List.generate(5, (index) => false);
                          selectedItem[2] = true;
                          draftsBloc.add(LoadDrafts('fetch_all_drafts'));
                        },
                        child: Container(
                            margin: const EdgeInsets.only(right: 5), child: ChoiceChip(label: const Text('Drafts'), selected: selectedItem[2])),
                      ),
                      InkWell(
                        onTap: () {
                          selectedItem = List.generate(5, (index) => false);
                          selectedItem[3] = true;
                          draftsBloc.add(LoadDrafts('fetch_scheduled_videos'));
                        },
                        child: Container(
                            margin: const EdgeInsets.only(right: 5), child: ChoiceChip(label: const Text('Scheduled'), selected: selectedItem[3])),
                      ),
                      InkWell(
                        onTap: () {
                          selectedItem = List.generate(5, (index) => false);
                          selectedItem[4] = true;
                          draftsBloc.add(LoadDrafts('fetch_lounge_only'));
                        },
                        child: Container(
                            margin: const EdgeInsets.only(right: 5), child: ChoiceChip(label: const Text('Lounge-only'), selected: selectedItem[4])),
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
