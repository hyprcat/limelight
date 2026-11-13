import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lime_time_app/defaults/fonts.dart';
import 'package:lime_time_app/screens/home/home.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  Widget _buildImage(String assetName, [double width = double.infinity]) {
    return Image.asset(
      'assets/$assetName',
      width: width,
      isAntiAlias: true,
      filterQuality: FilterQuality.high,
      fit: BoxFit.fitHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    var pageDecoration = PageDecoration(
      titleTextStyle:
          const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      bodyTextStyle: bodyStyle,
      pageColor: Theme.of(context).canvasColor,
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Theme.of(context).canvasColor,
      ),
      body: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Theme.of(context).canvasColor,
        allowImplicitScrolling: true,
        infiniteAutoScroll: false,
        pages: [
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 3,
                    softWrap: true,
                    text: TextSpan(
                        text: 'Welcome to\n',
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: "LimeLight.",
                            style: defaultHeadingText(context, fontsize: 35),
                          )
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "You're awesome! Here's a sneak peek at what makes us awesome before you dive in and explore. Let's get going, shall we?",
                  style:
                      defaultNormalText(context, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('peek.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 5,
                    softWrap: true,
                    text: TextSpan(
                        text: 'We are here to make your creative journey ',
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: "fun",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary),
                          ),
                          TextSpan(
                            text: " and ",
                            style: defaultHeadingText(context, fontsize: 35),
                          ),
                          TextSpan(
                            text: "exciting!",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "We will provide you with the best tools and programs that you'll need.",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('support.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text: 'For starters, Our platform is like ',
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: "your favourite video game!",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          )
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "Upload videos or just interact with other creator's content and Gain XP!",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('game.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 3,
                    softWrap: true,
                    text: TextSpan(
                        text: 'Try our ',
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Focused Trending",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary),
                          ),
                          TextSpan(
                            text: " and ",
                            style: defaultHeadingText(context, fontsize: 35),
                          ),
                          TextSpan(
                            text: "Leaderboards!",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "As you gain XP for your video or post, You will see yourself on top of these sections. Get ready to get famous!",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('leaderboards.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text: 'Gain ',
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Ranks, ",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.secondary),
                          ),
                          TextSpan(
                            text: "Rewards ",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          ),
                          TextSpan(
                            text: "and ",
                            style: defaultHeadingText(context, fontsize: 35),
                          ),
                          TextSpan(
                            text: "more!",
                            style: defaultHeadingText(
                              context,
                              fontsize: 35,
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "We know how valuable you are and as we are a platform for you, Let's make everything cool.",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('ranks.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text: "Monetise",
                        style: defaultHeadingText(context,
                            fontsize: 35,
                            fontColor: Theme.of(context).colorScheme.tertiary),
                        children: <TextSpan>[
                          TextSpan(
                            text: " your content in a better way.",
                            style: defaultHeadingText(
                              context,
                              fontsize: 35,
                            ),
                          )
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "Oh, you're gonna love it when it comes - so that you can be a full time creator easier.",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('monetise.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text: "Be part of your favourite creator's",
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: " journey.",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          )
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "Join their lounges and you'll have new ways for interacting and supporting your creator. Spread your love!",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('lounges.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text:
                            "We will make this the best platform for creators, ever.",
                        style: defaultHeadingText(context, fontsize: 35),
                        children: <TextSpan>[
                          TextSpan(
                            text: " That's a promise.",
                            style: defaultHeadingText(context,
                                fontsize: 35,
                                fontColor:
                                    Theme.of(context).colorScheme.tertiary),
                          )
                        ]),
                  ),
                ),
              ],
            ),
            bodyWidget: Row(
              children: [
                Expanded(
                    child: Text(
                  "We will keep adding stuff to our platform such that you'll always be on top of things.",
                  style: defaultNormalText(context,
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).hintColor),
                  textAlign: TextAlign.start,
                )),
              ],
            ),
            image: _buildImage('promise.gif'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    softWrap: true,
                    text: TextSpan(
                        text: "We are just getting started.",
                        style: defaultHeadingText(context,
                            fontsize: 35,
                            fontColor: Theme.of(context).hintColor),
                        children: const <TextSpan>[]),
                  ),
                ),
              ],
            ),
            bodyWidget: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 4,
                        softWrap: true,
                        text: TextSpan(
                            text:
                                "Thanks for supporting us. Let's get into the platform now.",
                            style: defaultHeadingText(context),
                            children: <TextSpan>[
                              TextSpan(
                                text: "\nAlso Hey, We love you.",
                                style: defaultHeadingText(context,
                                    fontColor: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Art by @mari.ilustra on Instagram",
                  style: defaultSmallLabel(context,
                      fontColor: Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            image: _buildImage('end.gif'),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: false,
        back: const Icon(Icons.arrow_back),
        skip: Text('Skip',
            style: defaultLabelText(context,
                fontColor: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        next: const Icon(Icons.arrow_forward),
        done: Text('Done',
            style: defaultLabelText(context,
                fontColor: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: ShapeDecoration(
          color: Theme.of(context).canvasColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
