import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';

import 'package:lime_time_app/defaults/fonts.dart';

List<DataColumn> buildVideoTableColumns(BuildContext context) {
  List<DataColumn> columns = [];
  TextStyle columnTextStyle = defaultLabelText(context,
      fontColor: Theme.of(context).colorScheme.primary);

  columns.add(DataColumn(label: Text('Title', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('Thumbnail', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('created on', style: columnTextStyle)));
  columns.add(DataColumn(label: Text('Status', style: columnTextStyle)));

  return columns;
}

DataRow buildVideoDataRow(VideoPost video) {
  List<DataCell> cells = [];
  cells.add(DataCell(Text(video.title!)));
  cells.add(DataCell(
      Text(video.thumbnail!.isEmpty ? "Not added" : video.thumbnail!)));
  cells.add(DataCell(Text(video.creationDate!)));
  var r = video.getStatus();
  cells.add(DataCell(Text(r)));
  return DataRow(cells: cells);
}

class EditButton extends StatelessWidget {
  final VideoPost video;
  const EditButton({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () {}, icon: const Icon(Iconsax.edit_outline));
  }
}
