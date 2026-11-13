import 'package:flutter/material.dart';
import 'package:lime_time_app/widgets/place_holders.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerVideo extends StatefulWidget {
  const ShimmerVideo({super.key});

  @override
  State<ShimmerVideo> createState() => _ShimmerVideoState();
}

class _ShimmerVideoState extends State<ShimmerVideo> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Theme.of(context).dividerColor.withOpacity(0.9),
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const BannerPlaceholder())),
              ),
              const SizedBox(
                height: 2,
              ),
              const ContentPlaceholder(
                lineType: ContentLineType.twoLines,
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ));
  }
}
