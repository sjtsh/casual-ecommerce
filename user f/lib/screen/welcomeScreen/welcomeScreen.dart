import 'dart:ui';

import 'package:ezdeliver/screen/auth/authscreen.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key, this.log = false});
  final bool log;

  @override
  Widget build(BuildContext context, ref) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const Expanded(
              child: IntroductionScreenItem(
                image: Assets.imagesSplash960,
                body:
                    "Grocery delivery in minutes. Escape hassle of \nparking & long check-out queues. Shop from",
                bodyHilight: "Faasto.",
              ),
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: 22.sw(), vertical: 18.sh()),
              child: CustomElevatedButton(
                  // elevatedButtonPadding: EdgeInsets.symmetric(
                  //     horizontal: 25.sw(), vertical: 12.sh()),
                  onPressedElevated: () async {
                    // SystemChannels.platform
                    //     .invokeMethod('SystemNavigator.pop');
                    // await launchApp("com.techwol.pasalko");
                    await Future.delayed(const Duration(milliseconds: 800), () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        if (storage.read("onboarding") == null) {
                          return const IntroductionScreen();
                        } else {
                          return const AuthScreen();
                        }
                      }));
                    });
                    if (log) {
                      await FirebaseAnalytics.instance.logEvent(
                        name: "Lets_get_started",
                      );
                    }
                  },
                  elevatedButtonText: "Get Started"),
            ),
            // Container(
            //   padding:
            //       EdgeInsets.symmetric(horizontal: 25.sw(), vertical: 12.sh()),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).primaryColor,
            //     borderRadius: BorderRadius.circular(4.sr()),
            //   ),
            //   child: Text("Let's Get Started",
            //       style: Theme.of(context).textTheme.headline4!.copyWith(
            //           color: CustomTheme.whiteColor, fontSize: 18.ssp())),
            // ),
          ],
        ),
      ),
    );
  }
}

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();
  int page = 0;

  final List<IntroductionScreenItem> items = const [
    IntroductionScreenItem(
      image: Assets.lottieFirstIntro,
      lottieAsset: true,
      repeat: false,
      heading: "Over 5000 products",
      body: "Shop thousands of grocery and \nhousehold products from",
      bodyHilight: "Faasto",
    ),
    IntroductionScreenItem(
      image: Assets.lottieSecondIntro,
      lottieAsset: true,
      heading: "Time flies, so do we",
      body:
          "Don’t wait. Get the deliveries of your order\nin minutes. We are the fastest one out\nthere.",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
                onPageChanged: (newPage) {
                  setState(() {
                    page = newPage;
                  });
                },
                controller: _controller,
                children: items),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items
                .asMap()
                .entries
                .map((e) => AnimatedContainer(
                      duration: 0.12.seconds,
                      margin: EdgeInsets.symmetric(horizontal: 3.sw()),
                      decoration: BoxDecoration(
                          borderRadius: page == e.key
                              ? BorderRadius.circular(6.sr())
                              : BorderRadius.all(Radius.circular(100.sr())),
                          // shape: page == e.key
                          //     ? BoxShape.rectangle
                          //     : BoxShape.circle,
                          color: page == e.key
                              ? CustomTheme.primaryColor
                              : CustomTheme.greyColor),
                      width: page == e.key ? 20.sw() : 8.sw(),
                      height: 8.sh(),
                    ))
                .toList(),
          ),
          SizedBox(
            height: 10.sh(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    completeOnboarding();
                  },
                  child: Text(
                    "Skip",
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
              TextButton(
                  onPressed: () {
                    hanldeNext();
                  },
                  child: Text("Start",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceTint))
                      .animate(target: (page == (items.length - 1)) ? 0 : 1)
                      .swap(builder: (context, child) {
                    final newChild = child as Text;
                    return Text(
                      "Next ==>",
                      style: newChild.style,
                    ).animate().fadeIn();
                  })),

              // page == items.length - 1
              //  "Next ==>"
            ],
          )
        ]
            .map((e) => e is Expanded
                ? e
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.sw(),
                      vertical: 3.sh(),
                    ),
                    child: e,
                  ))
            .toList(),
      ),
    );
  }

  hanldeNext() {
    if (page < items.length - 1) {
      _controller.animateToPage(page + 1,
          duration: 0.3.seconds, curve: Curves.ease);
    } else {
      completeOnboarding();
    }
  }

  completeOnboarding() async {
    storage.write("onboarding", true);
    await Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        // return const AuthScreen();
        return const AuthScreen();
      }));
    });
  }
}

class IntroductionScreenItem extends StatelessWidget {
  const IntroductionScreenItem(
      {super.key,
      required this.image,
      this.lottieAsset,
      this.heading,
      this.body,
      this.bodyHilight,
      this.repeat = true});

  final String image;
  final String? heading;
  final String? body, bodyHilight;
  final bool? lottieAsset;
  final bool repeat;
  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w600, color: CustomTheme.getBlackColor());

    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(color: CustomTheme.getBlackColor(), height: 1.5);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            flex: lottieAsset != null ? 4 : 3,
            child: Container(
                alignment: Alignment.bottomCenter,
                // color: Colors.red,
                padding: EdgeInsets.all(12.sr()),
                child: lottieAsset != null
                    ? Lottie.asset(image,
                        repeat: repeat, alignment: Alignment.bottomCenter)
                    : Image.asset(image).animate().fadeIn(duration: 1.seconds)),
          ),
          if (heading != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 88.sw(),
              ),
              child: Text(
                heading!,
                style: headingStyle,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 0.5.seconds),
            ),
          if (body != null) ...[
            SizedBox(
              height: 30.sh(),
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: bodyStyle, children: [
                  TextSpan(text: "$body"),
                  if (bodyHilight != null)
                    TextSpan(
                        text: "\n $bodyHilight",
                        style: bodyStyle.copyWith(fontWeight: FontWeight.bold))
                ])).animate().fadeIn(delay: 0.2.seconds, duration: 0.5.seconds)
          ],
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
