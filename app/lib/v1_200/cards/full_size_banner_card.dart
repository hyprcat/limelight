import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lime_time_app/logics/models/banners/big_banner.dart';
import 'package:lime_time_app/widgets/buttons/primary_focus_button.dart';
import 'package:url_launcher/url_launcher.dart';

class FullSizeBannerCard extends StatefulWidget {
  final ContestBanner banner;
  const FullSizeBannerCard({super.key, required this.banner});

  @override
  State<FullSizeBannerCard> createState() => _FullSizeBannerCardState();
}

class _FullSizeBannerCardState extends State<FullSizeBannerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30, top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(20)),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          children: [
            Positioned.fill(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(int.parse(widget.banner.color!, radix: 16))
                                .withOpacity(0.8)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.hardLight,
                      child: CachedNetworkImage(
                        imageUrl: widget.banner.bannerLink!,
                        fit: BoxFit.cover,
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
                      style: TextStyle(
                        color: widget.banner.shouldUseDarkText!
                            ? Colors.black
                            : Colors.white,
                        height: 1.2,
                        fontFamily: 'Gil',
                        fontWeight: FontWeight.w800,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0,
                          ),
                        ],
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                      ),
                    ),
                    AutoSizeText(
                      widget.banner.description!,
                      style: TextStyle(
                        color: widget.banner.shouldUseDarkText!
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0,
                          ),
                        ],
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge!.fontSize,
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
