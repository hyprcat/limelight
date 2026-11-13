import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/screens/home/custom_feeds/complete_feed.dart';
import 'package:lime_time_app/widgets/snackbars/throw_error_snackbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SelectTopics extends StatefulWidget {
  final Map info;
  const SelectTopics({super.key, required this.info});

  @override
  State<SelectTopics> createState() => _SelectTopicsState();
}

class _SelectTopicsState extends State<SelectTopics> {
  Widget _backgroundWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      margin: const EdgeInsets.only(
        right: 10,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(150)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  List<String> topics = [];

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        surfaceTintColor: Theme.of(context).canvasColor.withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Map info = widget.info;
              info['topics'] = topics;
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CompleteFeed(
                  data: info,
                ),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            child: _backgroundWrapper([
              Text(
                "Next",
                style: defaultLabelText(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary),
              )
            ]),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          shrinkWrap: true,
          controller: controller,
          children: [
            Text("Select Topics you wanna see.",
                style: defaultHeadingText(context)),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 3),
              child: StepProgressIndicator(
                totalSteps: 4,
                currentStep: 3,
                selectedColor: Theme.of(context).colorScheme.secondary,
                unselectedColor: Theme.of(context).dividerColor,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (topics.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selected",
                    style:
                        defaultLabelText(context, fontWeight: FontWeight.bold),
                  ),
                  Wrap(children: [
                    for (var i in topics)
                      InkWell(
                        onTap: () {
                          for (int j = 0; j < topics.length; j++) {
                            if (i == topics[j]) {
                              topics.removeAt(j);
                            }
                          }
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          child: Builder(builder: (context) {
                            Color random = randomOpaqueColor();
                            Color textColor = random.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white;
                            return Chip(
                                backgroundColor: random,
                                label: Text(
                                  i,
                                  style: defaultLabelText(context,
                                      fontWeight: FontWeight.w600,
                                      fontColor: textColor),
                                ));
                          }),
                        ),
                      )
                  ]),
                ],
              ),
            const Divider(),
            ListView.builder(
                shrinkWrap: true,
                controller: controller,
                itemCount: categoryMap.keys.length,
                itemBuilder: (context, index) {
                  String categoryName = categoryMap.keys.toList()[index];
                  List<String> subCategories =
                      categoryMap[categoryMap.keys.toList()[index]];
                  return ListView(
                    shrinkWrap: true,
                    controller: controller,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        categoryName,
                        style: defaultHeadingText(context),
                      ),
                      Wrap(children: [
                        for (var i in subCategories)
                          InkWell(
                            onTap: () {
                              if (topics.contains(i)) {
                                throwErrorSnackBar(context, "Already added");
                              } else {
                                topics.add(i);
                              }
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: Builder(builder: (context) {
                                return Chip(
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    label: Text(
                                      i,
                                      style: defaultSmallLabel(context,
                                          fontWeight: FontWeight.w600),
                                    ));
                              }),
                            ),
                          )
                      ]),
                      const Divider(),
                    ],
                  );
                }),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
