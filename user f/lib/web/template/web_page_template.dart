import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/component/helper/urlLauncher.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/web/template/header.dart';

// ignore: must_be_immutable
class WebPageTemplate extends ConsumerWidget {
  WebPageTemplate({super.key, required this.size});
  final Size size;
  late EdgeInsets margin = EdgeInsets.only(bottom: 25.sh(), top: 25.sh()),
      padding = EdgeInsets.symmetric(
          horizontal: size.width > 1280 ? size.width * .12 : 30.sw());
  final List<SingleChildRenderObjectWidget> _children = [];
  List<SingleChildRenderObjectWidget> get children => _children;
  set children(List<SingleChildRenderObjectWidget> children) {
    _children.clear();
    _children.addAll(children);
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          header(),
          ..._children,
          footerInfo(),
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: Divider(
                height: 5.sh(),
              ),
            ),
          ),
          footer()
        ],
      ),
    );
  }

  SliverPadding footer() {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: Builder(builder: (context) {
          final style = Theme.of(context).textTheme.bodyText1;
          return Container(
            margin: margin,
            child: OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              overflowAlignment: OverflowBarAlignment.center,
              overflowSpacing: 10.sh(),
              children: [
                WebLinkButton(
                  "© ${DateTime.now().year} Pasalko. All rights reserved",
                  style: style,
                  onPressed: () async {
                    // _scrollController.jumpTo(0);
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeIn);
                    // duration: widgetSwitchAnimationDuration,
                    // curve: Curves.elasticIn);
                  },
                ),
                // InkWell(
                //   onTap: () async {
                //     // _scrollController.jumpTo(0);
                //     _scrollController.animateTo(0,
                //         duration: const Duration(milliseconds: 150),
                //         curve: Curves.easeIn);
                //     // duration: widgetSwitchAnimationDuration,
                //     // curve: Curves.elasticIn);
                //   },
                //   child: Text(
                //     "© ${DateTime.now().year} Pasalko. All rights reserved",
                //     style: style,
                //   ),
                // ),
                // const Spacer(),
                OverflowBar(
                  alignment:
                      BreakPoint.isMobile ? MainAxisAlignment.center : null,
                  children: [
                    WebLinkButton(
                      "Privacy Policy",
                      style: style,
                      onPressed: () {
                        launchLink(
                          uri: defaultUri.replace(
                              host: "techwol.com",
                              path: "pasalko/privacy_policy"),
                        );
                      },
                    ),
                    SizedBox(
                      width: 15.sw(),
                    ),
                    WebLinkButton(
                      "Terms & Conditions",
                      onPressed: () {},
                      style: style,
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  SliverPadding footerInfo() {
    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: SliverToBoxAdapter(
        child: Builder(builder: (context) {
          return Container(
            padding: padding,
            margin: margin,
            color: CustomTheme.primaryColor,
            alignment: Alignment.topCenter,
            child: OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              overflowAlignment: OverflowBarAlignment.center,
              // overflowSpacing: 24.sh(),
              // runAlignment: WrapAlignment.center,
              children: [
                Container(
                  // color: Colors.red,
                  // alignment: Alignment.bottomCenter,
                  // width: 400.sw(),
                  // constraints: BoxConstraints(maxWidth: 800.sw()),
                  padding: margin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Groceries delivered in 30 minutes",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                            color: CustomTheme.getBlackColor(opposite: true)),
                      ),
                      SizedBox(
                        height: 18.sh(),
                      ),
                      Builder(builder: (context) {
                        const scale = 1.5;
                        return OverflowBar(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          overflowAlignment: OverflowBarAlignment.center,
                          overflowSpacing: 10.sh(),
                          children: [
                            InkWell(
                              onTap: () async {
                                await launchApp("com.techwol.pasalko");
                              },
                              child: Image.asset(
                                Assets.imagesPlayStore.web(),
                                scale: scale,
                              ),
                            ),
                            SizedBox(
                              width: 24.sw(),
                            ),
                            Image.asset(
                              Assets.imagesAppStore.web(),
                              scale: scale,
                            )
                          ],
                        );
                      })
                      // Text(
                      //   "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. ",
                      //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //       color: CustomTheme.getBlackColor(opposite: true)),
                      // ),
                    ],
                  ),
                ),
                OverflowBar(
                  // alignment: MainAxisAlignment.start,
                  overflowAlignment: OverflowBarAlignment.center,
                  // alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    footerItemBox(),
                    footerItemBox(),
                    footerItemBox(),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  SliverPadding header() {
    return SliverPadding(
      // padding: BreakPoint.isMobile ? EdgeInsets.zero : padding,
      padding: EdgeInsets.zero,
      sliver: SliverPersistentHeader(
        pinned: true,
        delegate: SliverAppBarDelegate(
            padding: padding,
            margin: margin.copyWith(top: 0),
            collapsedHeight: BreakPoint.isMobile ? 65.sh() : 60.sh(),
            expandedHeight: 80.sh()),
      ),
    );
  }

  Widget footerItemBox() {
    return Container(
      margin: EdgeInsets.all(20.sr()),
      child: Builder(builder: (context) {
        final style = Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: CustomTheme.getBlackColor(opposite: true));
        return Column(
          children: [
            Text(
              "HOW",
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: CustomTheme.getBlackColor(opposite: true)),
            ),
            SizedBox(
              height: 25.sh(),
            ),
            Text(
              "Marketing",
              style: style,
            ),
            SizedBox(
              height: 14.sh(),
            ),
            Text(
              "Analytics",
              style: style,
            ),
            SizedBox(
              height: 14.sh(),
            ),
            Text(
              "Commerce",
              style: style,
            ),
            SizedBox(
              height: 14.sh(),
            ),
            Text(
              "Insights",
              style: style,
            ),
          ],
        );
      }),
    );
  }
}
