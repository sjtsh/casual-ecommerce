import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../Components/CustomTheme.dart';
import '../../Components/Constants/ColorPalette.dart';

class ShopRatingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
        Shimmer.fromColors(
          baseColor: context.watch<CustomTheme>().isDarkMode ? ColorPalette.darkContainerColor:Colors.grey.shade300,
          highlightColor:context.watch<CustomTheme>().isDarkMode ? ColorPalette.grey: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.sr())),
        // color: Colors.grey,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Text(
                        "0.0",
                        // textAlign: TextAlign.end,
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Transform.translate(
                        offset: Offset(
                            0,
                            Theme.of(context).textTheme.headline1!.fontSize! *
                                .1),
                        child: Text(
                          " /5",
                          // textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3,
                  ),

                  Container(
                    color: Colors.grey, height: 14,width: 100,),
                  // Text(
                  //   "Based on ${shop.rateCount} Review${shop.rateCount > 1 ? "s" : ""}",
                  //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  //       fontWeight: FontWeight.w500,
                  //       color: CustomTheme.greyColor),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  RatingBar(
                      itemSize: 24,
                      initialRating:  0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                          full: const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 8,
                          ),
                          half: const Icon(
                            Icons.star_half,
                            color: Colors.orange,
                            size: 8,
                          ),
                          empty: const Icon(
                            Icons.star_outline,
                            color: Colors.orange,
                            size: 8,
                          )),
                      onRatingUpdate: (value) {
                        // setState(() => ratingProvider = value.round());
                      },
                      ignoreGestures: true)
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: List.generate(
                  5,
                        (index) => ratingCountForStar(context,
                        star:index+1,
                        count: 5,
                        total: 5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingCountForStar(BuildContext context,
      {required int star, required int count, required int total}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            "$star Star",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: CustomTheme.greyColor, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 10,
                value:count/ ((total == 0) ? 1 : total),
                backgroundColor: CustomTheme.greyColor.withAlpha(25),
                color: Colors.orange,
              ),
            ),
          )
        ],
      ),
    );
  }
}
