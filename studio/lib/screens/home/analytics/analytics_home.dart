import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/screens/home/analytics/bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class AnalyticsHome extends StatefulWidget {
  const AnalyticsHome({super.key});

  @override
  State<AnalyticsHome> createState() => _AnalyticsHomeState();
}

class _AnalyticsHomeState extends State<AnalyticsHome> {
  List<bool> selectedItem = List.generate(5, (index) => false);

  @override
  Widget build(BuildContext context) {
    Widget buildData() {
      if (selectedItem[0]) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            SelectableText("Watch time", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            SelectableText("Views", style: defaultHeadingText(context)),
            SelectableText("For your videos in past 24 hours.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            SelectableText("Experience Points", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider()
          ],
        );
      } else if (selectedItem[1]) {
        return Wrap(
          runSpacing: 10,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Likes", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Total Likes", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Dislikes", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Total Dislikes", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Impressions", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Total Impressions", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Views", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Total Views", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Audience Retention Percentage", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Average Audience retention percentage", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Bounce rate", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Average Bounce rate", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText("Conversion rate", style: defaultHeadingText(context)),
                  SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 1)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText("Current Conversion Rate.", style: defaultSmallLabel(context)),
                          SelectableText("0", style: defaultLabelText(context, fontColor: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 400, child: LineChartSample2()),
                ],
              ),
            ),
          ],
        );
      } else if (selectedItem[2]) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            SelectableText("Watch time", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            SelectableText("Views", style: defaultHeadingText(context)),
            SelectableText("For your videos in past 24 hours.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            SelectableText("Experience Points", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider()
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            SelectableText("Watch time", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            SelectableText("Views", style: defaultHeadingText(context)),
            SelectableText("For your videos in past 24 hours.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            SelectableText("Experience Points", style: defaultHeadingText(context)),
            SelectableText("For all your videos combined.", style: defaultSmallLabel(context)),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 400, child: LineChartSample2()),
            const Divider()
          ],
        );
      }
    }

    List<Widget> buildBody() {
      List<Widget> children = [
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    selectedItem = List.generate(5, (index) => false);
                    selectedItem[0] = true;
                    setState(() {});
                  },
                  child: ChoiceChip(label: const Text('Overview'), selected: selectedItem[0])),
              InkWell(
                onTap: () {
                  selectedItem = List.generate(5, (index) => false);
                  selectedItem[1] = true;
                  setState(() {});
                },
                child: Container(
                    margin: const EdgeInsets.only(right: 5, left: 5), child: ChoiceChip(label: const Text('Content'), selected: selectedItem[1])),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        buildData()
      ];
      return children;
    }

    return DynMouseScroll(builder: (context, controller, physics) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 640,
        ),
        child: ListView(addAutomaticKeepAlives: true, controller: controller, physics: physics, shrinkWrap: false, children: buildBody()),
      );
    });
  }
}
