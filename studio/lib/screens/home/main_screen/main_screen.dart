import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/screens/home/main_screen/video_rankings_card.dart';
import 'package:flutter/material.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:code_arrow_creator_studio/screens/home/main_screen/highlights_card.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> with AutomaticKeepAliveClientMixin<HomeMainScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DynMouseScroll(builder: (context, controller, physics) {
      return ListView(
        addAutomaticKeepAlives: true,
        controller: controller,
        physics: physics,
        children: [
          Text("Quick Summary of your channel", style: defaultLabelText(context)),
          SelectableText("You can view their stats and more.", style: defaultSmallLabel(context, fontColor: Theme.of(context).hintColor)),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [RankingsCard(), HighlightsCard()],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Policies"),
              Container(margin: const EdgeInsets.only(left: 10, right: 10), child: const Text("Terms and Conditions"))
            ],
          )
        ],
      );
    });
  }
}
