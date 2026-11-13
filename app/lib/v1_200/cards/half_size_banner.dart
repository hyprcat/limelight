import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/defaults/utils.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lime_time_app/logics/models/banners/small_banner_card.dart';

class HalfSizeBanner extends StatefulWidget {
  final SmallBanner banner;

  const HalfSizeBanner({super.key, required this.banner});

  @override
  State<HalfSizeBanner> createState() => _HalfSizeBannerState();
}

class _HalfSizeBannerState extends State<HalfSizeBanner> {
  Color color = Colors.grey.shade700;
  Color textColor = generateTextColor(Colors.grey.shade700);

  @override
  Widget build(BuildContext context) {
    precacheImage(NetworkImage(widget.banner.bannerLink!), context);
    Widget body = Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10)),
      child: AspectRatio(
        aspectRatio: 21 / 9,
        child: Stack(
          children: [
            Positioned.fill(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(int.parse(widget.banner.color!, radix: 16))
                                .withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomLeft,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.hardLight,
                      child: CachedNetworkImage(
                        imageUrl: widget.banner.bannerLink!,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low,
                      ),
                    ))),
            Container(
              decoration: BoxDecoration(
                color: widget.banner.bannerLink == null ? Colors.black54 : null,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    AutoSizeText(
                      widget.banner.title!,
                      maxLines: 2,
                      style: defaultHeadingText(
                        context,
                        fontWeight: FontWeight.w800,
                        fontColor: widget.banner.shouldUseDarkText!
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    AutoSizeText(
                      widget.banner.description!,
                      style: defaultLabelText(
                        context,
                        fontWeight: FontWeight.w600,
                        fontColor: widget.banner.shouldUseDarkText!
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.banner.ctaLabel == null
                        ? Container()
                        : Row(
                            children: [
                              Expanded(child: Container()),
                              PrimaryFocusButton(
                                  label: widget.banner.ctaLabel!,
                                  callback: () async {
                                    if (widget.banner.containsUrl!) {
                                      final Uri url =
                                          Uri.parse(widget.banner.url!);
                                      if (!await launchUrl(url)) {
                                        throw Exception(
                                            'Could not launch $url');
                                      }
                                    } else {
                                      Navigator.of(context, rootNavigator: true)
                                          .pushNamed(
                                        '/${widget.banner.url}',
                                      );
                                    }
                                  })
                            ],
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return body;
  }
}
