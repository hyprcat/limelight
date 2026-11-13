import 'package:flutter/material.dart';
import 'package:lime_time_app/widgets/place_holders.dart';
import 'package:shimmer/shimmer.dart';

class FakeProfileCard extends StatefulWidget {
  const FakeProfileCard({super.key});

  @override
  State<FakeProfileCard> createState() => _FakeProfileCardState();
}

class _FakeProfileCardState extends State<FakeProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).focusColor,
        highlightColor: Theme.of(context).focusColor,
        enabled: true,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            RectPlaceholder(
              lineType: ContentLineType.twoLines,
            )
          ],
        ));
  }
}

class FakePost extends StatefulWidget {
  const FakePost({super.key});

  @override
  State<FakePost> createState() => _FakePostCardState();
}

class _FakePostCardState extends State<FakePost> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).focusColor,
        highlightColor: Theme.of(context).focusColor,
        enabled: true,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ContentPlaceholder2(
              lineType: ContentLineType.twoLines,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 73,
                ),
                Expanded(
                    child: TitlePlaceholder(
                  width: double.infinity,
                )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Divider()
          ],
        ));
  }
}
