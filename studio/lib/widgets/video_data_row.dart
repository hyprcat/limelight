import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/engines/models/video_post.dart';
import 'package:code_arrow_creator_studio/engines/video_engine.dart';
import 'package:code_arrow_creator_studio/screens/home/content/edit_draft.dart';
import 'package:code_arrow_creator_studio/widgets/primary_focus_button.dart';
import 'package:code_arrow_creator_studio/widgets/throw_error_snackbar.dart';
import 'package:code_arrow_creator_studio/widgets/throw_happy_snackbar.dart';

import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VideoPost video;
  const EditButton({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black45,
              transitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
                    height: 750,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).colorScheme.primary)),
                    child: Material(child: EditVideoDraft(video: video)),
                  ),
                );
              });
        },
        icon: const Icon(Icons.edit));
  }
}

class DeleteButton extends StatelessWidget {
  final VideoPost video;
  const DeleteButton({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black45,
              transitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                return Center(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
                    height: 300,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).colorScheme.primary)),
                    child: Material(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("You sure want to delete this video?", style: defaultHeadingText(context)),
                        SelectableText(
                            "Once deleted, You can't recover it back and XP points that you might have gained from this video will disappear.",
                            style: defaultSmallLabel(context)),
                        const Divider(),
                        PrimaryFocusButton(
                            label: "Yes, Delete this video",
                            callback: () async {
                              var response = await VideoEngine().deleteVideo(video.id!);
                              if (response == "Deleted video") {
                                throwHappySnackBar(context, "Requested to delete your video. It should be deleted in a few moments.");
                              } else {
                                throwErrorSnackBar(context, response);
                              }
                              Navigator.pop(context);
                            }),
                      ],
                    )),
                  ),
                );
              });
        },
        icon: const Icon(Icons.delete));
  }
}

List<DataColumn> buildVideoTableColumns(BuildContext context) {
  List<DataColumn> columns = [];
  TextStyle columnTextStyle = defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary);

  columns.add(DataColumn(label: Text('Title', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('Thumbnail', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('created on', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('Status', style: columnTextStyle)));

  columns.add(DataColumn(label: Text('Edit', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('Delete', style: columnTextStyle)));
  return columns;
}

DataRow buildVideoDataRow(VideoPost video) {
  List<DataCell> cells = [];
  cells.add(DataCell(Text(video.title!)));
  cells.add(DataCell(Text(video.thumbnail!.isEmpty ? "Not added" : video.thumbnail!)));
  cells.add(DataCell(Text(video.creationDate!)));
  var r = video.getStatus();
  cells.add(DataCell(Text(r)));
  cells.add(DataCell(EditButton(
    video: video,
  )));
  cells.add(DataCell(DeleteButton(
    video: video,
  )));
  return DataRow(cells: cells);
}
