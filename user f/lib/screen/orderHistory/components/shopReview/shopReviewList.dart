import 'dart:ui';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/ratingModel.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/models/staffmodel.dart';
import 'package:intl/intl.dart';

class ShopReviewList extends ConsumerWidget {
  ShopReviewList(
      {required this.ratingWithStat,
      required this.shop,
      required this.staff,
      super.key});
  final RatingModelWithStat ratingWithStat;
  final Shop shop;
  final Staff staff;

  late final ScrollController scrollController = initScroll();

  ScrollController initScroll() {
    final controller = ScrollController();
    if (staff.rateCount! > 10) {
      controller.addListener(() async {
        if (controller.position.extentAfter < 10) {
          await CustomKeys.ref
              .read(orderHistoryServiceProvider)
              .loadMoreshopsReview(shop: shop, staff: staff);
        }
      });
    }
    return controller;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingMore =
        ref.watch(orderHistoryServiceProvider).loadingMoreShopsReview;
    int length = isLoadingMore
        ? ratingWithStat.ratings.length + 1
        : ratingWithStat.ratings.length;
    return Container(
      decoration: BoxDecoration(
          // color: Colors.red,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.sr()))),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: RatingStats(
              stats: ratingWithStat.starCounts,
              shop: shop,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: 22.sw(),
            ),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              if (isLoadingMore) {
                if (index == ratingWithStat.ratings.length) {
                  return Center(
                    child: Transform.scale(
                        scale: 0.8,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )),
                  );
                }
              }
              return Container(
                margin: EdgeInsets.symmetric(vertical: 14.sh()),
                child: ReviewListItem(
                  data: ratingWithStat.ratings[index],
                ),
              );
            }, childCount: length)),
          ),
        ],
      ),
    );
  }
}

class RatingStats extends StatelessWidget {
  const RatingStats({Key? key, required this.shop, required this.stats})
      : super(key: key);
  final Shop shop;
  final List<int> stats;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.sw(), vertical: 20.sh()),
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
                      clapRatinValue(shop.avgRating!).toStringAsFixed(1),
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
                            fontSize: 17.ssp()),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3.sh(),
                ),
                Text(
                  "Based on ${shop.rateCount} Review${shop.rateCount! > 1 ? "s" : ""}",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.greyColor),
                ),
                SizedBox(
                  height: 10.sh(),
                ),
                CustomRating(
                  ignoreGestures: true,
                  rating: shop.avgRating!,
                  itemSize: 27.sr(),
                  showLabel: false,
                  allowHalfRating: true,
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: stats
                  .asMap()
                  .entries
                  .map((e) => ratingCountForStar(context,
                      star: e.key + 1, count: e.value, total: shop.rateCount!))
                  .toList()
                  .reversed
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget ratingCountForStar(BuildContext context,
      {required int star, required int count, required int total}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sw(), vertical: 4.sh()),
      child: Row(
        children: [
          Text(
            "$star Star",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: CustomTheme.greyColor, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 12.sw(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.sr()),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: count.toString(),
                child: LinearProgressIndicator(
                  minHeight: 10.sh(),
                  value: (lerpDouble(0, 1.0, (count / total))),
                  backgroundColor: CustomTheme.greyColor.withAlpha(25),
                  color: Colors.orange,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ReviewListItem extends ConsumerWidget {
  const ReviewListItem({required this.data, super.key});
  final RatingModel data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  name: data.user!.name,
                  // size: 40.sr(),
                  padding: 10.sr(),
                  fontSize: 14.ssp(),
                ),
                SizedBox(
                  width: 12.sw(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " ${data.user!.name}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 3.sh(),
                    ),
                    CustomRating(
                      ignoreGestures: true,
                      rating: data.ratingByUser!.toDouble(),
                      itemSize: 15.sr(),
                      showLabel: false,
                    )
                  ],
                ),
              ],
            ),
            Text(
              customDate(data.createdAt!, time: true),
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: CustomTheme.greyColor),
            ),
          ],
        ),
        //Review

        if (data.reviewByUser != null) ...[
          SizedBox(
            height: 5.sh(),
          ),
          Text(
            data.reviewByUser!,
            // textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontWeight: FontWeight.w400),
          )
        ]
      ],
    );
  }
}

String customDate(DateTime date, {bool time = true}) {
  String d = date.toString().substring(0, 10) !=
          DateTime.now().toString().substring(0, 10)
      ? time
          ? DateFormat("MMM d, y \nhh:mm a").format(date)
          : DateFormat("MMM d, y ").format(date)
      : time
          ? "Today\n ${DateFormat("hh:mm a").format(date)}"
          : "Today";
  return d;
}
