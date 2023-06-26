import 'dart:ui';

import 'package:ezdeliver/screen/auth/login/login.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'dart:math' as math;

import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/loader/loader.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/screen/search/search.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const SliverAppBarDelegate(
      {required this.collapsedHeight,
      required this.expandedHeight,
      required this.margin,
      this.padding});

  final double expandedHeight;
  final double collapsedHeight;
  final EdgeInsets margin;
  final EdgeInsets? padding;

  @override
  double get minExtent => collapsedHeight;
  @override
  double get maxExtent => math.max(expandedHeight, minExtent);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build

    final pColor = Color.lerp(Theme.of(context).scaffoldBackgroundColor,
        Theme.of(context).primaryColor, shrinkOffset / maxExtent);
    final pColorOpposite = Color.lerp(Theme.of(context).primaryColor,
        Theme.of(context).scaffoldBackgroundColor, shrinkOffset / maxExtent);
    final blackColor = Color.lerp(CustomTheme.getBlackColor(),
        CustomTheme.whiteColor, shrinkOffset / maxExtent);

    final opactiy =
        1.0 - lerpDouble(0, maxExtent, (shrinkOffset / maxExtent) / 100)!;
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: widgetSwitchAnimationDuration,
            color: pColor,
            // margin: margin,
            padding: padding?.copyWith(top: 15.sh(), bottom: 15.sh()) ??
                EdgeInsets.symmetric(horizontal: 18.sw(), vertical: 15.sh()),
            // constraints: BoxConstraints(maxHeight: 60),
            // color: Colors.red,
            child: Row(
              children: [
                FittedBox(
                  child: logo(context, pColorOpposite),
                ),

                if (!BreakPoint.isMobile) ...[
                  if (BreakPoint.isDesktop) ...[
                    VerticalDivider(
                      thickness: 3,
                      width: 40.ssp(),
                      color: CustomTheme.blackColor,
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                  Expanded(
                      flex: BreakPoint.isDesktop ? 4 : 2,
                      child: search(opactiy)),
                  if (BreakPoint.isDesktop)
                    const Spacer(
                      flex: 1,
                    ),
                ],
                // Spacer(),

                Expanded(
                    flex: 2,
                    child: location(blackColor, context, pColorOpposite)),
                SizedBox(
                  width: 20.sw(),
                ),
                FittedBox(child: menu(pColorOpposite, pColor, context))

                // InkWell(
                //   child: ,
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
    // TODO: implement shouldRebuild
    // return expandedHeight != oldDelegate.maxExtent
    //       || collapsedHeight != oldDelegate.minExtent;
  }
}

Row menu(Color? pColorOpposite, Color? pColor, BuildContext context) {
  return Row(
    children: [
      if (BreakPoint.isMobile)
        CustomSearchButton(
          color: pColorOpposite,
        ),
      InkWell(
        onTap: () {
          CustomKeys.webScaffoldKey.currentState!.openEndDrawer();
        },
        child: CartBottomNav(
          colorCart: pColorOpposite,
          colorLabel: pColor,
          up: true,
        ),
      ),
      SizedBox(
        width: 15.sw(),
      ),
      CustomElevatedButton(
          onPressedElevated: () {
            Utilities.checkIfLoggedIn(context: context, doIfLoggedIN: () {});
          },
          elevatedButtonText:
              CustomKeys.ref.read(userChangeProvider).loggedInUser.value != null
                  ? "Madhav Gyawali"
                  : "Log In")
    ],
  );
}

Text logo(BuildContext context, Color? pColorOpposite) {
  return Text(
    BreakPoint.isMobile ? "F" : "Faasto",
    style: Theme.of(context).textTheme.headline1!.copyWith(
        color: pColorOpposite, fontWeight: FontWeight.w600, fontSize: 50.ssp()),
  );
}

Row location(Color? blackColor, BuildContext context, Color? pColorOpposite) {
  return Row(
    children: [
      if (!BreakPoint.isMobile) ...[
        Icon(
          Icons.location_on_outlined,
          color: blackColor,
        ),
        SizedBox(
          width: 5.sw(),
        ),
        Text(
          "Deliver to",
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: blackColor),
        ),
      ],
      SizedBox(
        width: 18.sw(),
      ),
      Expanded(
          child: AddressInfoBox(
        color: pColorOpposite,
      ))
    ],
  );
}

Opacity search(double opactiy) {
  return Opacity(
    opacity: opactiy,
    child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.sw()),
        child: TextField(
          decoration: InputDecoration(
              suffixIcon: InkWell(
                onTap: () {},
                child: Container(
                    child: Icon(
                  Icons.search,
                  color: CustomTheme.primaryColor,
                )),
              ),
              hintText: "Search products..."),
        )),
  );
}
