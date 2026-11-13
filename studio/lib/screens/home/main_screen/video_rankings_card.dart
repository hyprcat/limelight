import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:flutter/material.dart';

class RankingsCard extends StatefulWidget {
  const RankingsCard({super.key});

  @override
  State<RankingsCard> createState() => _RankingsCardState();
}

class _RankingsCardState extends State<RankingsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 10, top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Theme.of(context).colorScheme.outline)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your top videos", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
          SizedBox(
            height: 250,
            child: Center(
              child: Text("Nothing here.", style: defaultSmallLabel(context)),
            ),
          )
        ],
      ),
    );
  }
}
