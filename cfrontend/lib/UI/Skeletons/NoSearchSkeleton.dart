import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:ezdelivershop/UI/Skeletons/LoadingGrid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Components/Constants/CardStylePalette.dart';
import '../../Components/Constants/SpacePalette.dart';
import 'LoadingImage.dart';

const LinearGradient grad = LinearGradient(
  colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);
const LinearGradient gradDark = LinearGradient(
  colors: [Colors.grey, Color(0xFFF4F4F4), Colors.grey],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class NoSearchSkeleton extends StatelessWidget {
  final bool column;
  final int count;

  NoSearchSkeleton({this.column = false, this.count = 6});

  Widget gridViewShimmer() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: SpacePalette.paddingMediumV,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.watch<CustomTheme>().isDarkMode
                      ? ColorPalette.darkContainerColor
                      : Colors.white,
                  boxShadow: [CardStylePalette.kBoxShadow]),
              child: LoadingGrid());
        });
  }

  @override
  Widget build(BuildContext context) {
    // return gridViewShimmer();

    List<Widget> widgets = List.generate(
        count,
        (index) => Padding(
              padding:
                  SpacePalette.paddingExtraLargeH.copyWith(top: 10, bottom: 10),
              child: Container(
                  padding: SpacePalette.paddingMediumV,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.watch<CustomTheme>().isDarkMode
                          ? ColorPalette.darkContainerColor
                          : Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Shimmer.fromColors(
                            baseColor: context.watch<CustomTheme>().isDarkMode
                                ? ColorPalette.darkContainerColor
                                : Colors.grey.shade300,
                            highlightColor: context.watch<CustomTheme>().isDarkMode
                                ? ColorPalette.grey
                                : Colors.white,
                            child: Container(
                                color: Colors.black, width: 100, height: 15)),
                      ),
                      SpacePalette.spaceTiny,
                      const ProductSkeleton()
                      // SingularProduct(
                      //   pr, gestureEdit: query != null,),
                    ],
                  )),
            ));
    return column
        ? Column(
            children: widgets,
          )
        : ListView(
            children: widgets,
          );
  }
}

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: 2,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 240,
              padding: SpacePalette.paddingMediumV,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.watch<CustomTheme>().isDarkMode
                    ? ColorPalette.darkContainerColor
                    : Colors.white,
                boxShadow: [CardStylePalette.kBoxShadow],
              ),
              height: 300,
              child: Shimmer.fromColors(
                baseColor: context.watch<CustomTheme>().isDarkMode
                    ? ColorPalette.darkContainerColor
                    : Colors.grey.shade300,
                highlightColor: context.watch<CustomTheme>().isDarkMode
                    ? ColorPalette.grey
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(child: LoadingImage()),
                      SpacePalette.spaceMedium,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: Colors.white,
                            height: 12,
                            width: 100,
                          ),
                          Row(
                            children: const [
                              Icon(Icons.check),
                              Icon(Icons.check),
                              Icon(Icons.check),
                            ],
                          ),
                        ],
                      ),
                      SpacePalette.spaceMedium,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.white,
                                height: 12,
                                width: 60,
                              ),
                              SpacePalette.spaceTiny,
                              Container(
                                color: Colors.white,
                                height: 12,
                                width: 54,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                            width: 48,
                            child: Transform.scale(
                              scale: .8,
                              child: CupertinoSwitch(
                                value: false,
                                onChanged: (c) {},
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
