import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/models/staffmodel.dart';
import 'package:ezdeliver/screen/orderHistory/components/shopReview/shopReviewList.dart';

class ShopProfile extends ConsumerWidget {
  ShopProfile({required this.shop, required this.staff, super.key});
  final Shop shop;
  final Staff staff;

  // late final shopRatingProvider =
  //     FutureProvider<RatingModelWithStat>((ref) async {
  //   var data = await ref
  //       .read(orderHistoryServiceProvider)
  //       .getReviews(shopId: shop.id, clear: true);
  //   return data;
  // });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(shop.id);

    return WillPopScope(
      onWillPop: () {
        ref.read(orderHistoryServiceProvider).clear();
        return Future.value(true);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: shop.image.isNotEmpty
                              ? BoxFit.cover
                              : BoxFit.scaleDown,
                          image: CachedNetworkImageProvider(shop.image.first
                              .replaceAll("localhost", Api.localUrl)))),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      // color: Colors.black.withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: 15,
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.3))
                      ]),
                  padding: EdgeInsets.symmetric(
                      horizontal: 22.sw(), vertical: 14.sh()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          // SizedBox(
                          //   height: 5.sh(),
                          // ),
                          // CustomRating(
                          //   rating: shop.avgRating!.toDouble(),
                          //   itemSize: 20.sr(),
                          //   count: shop.rateCount!,
                          //   ignoreGestures: true,
                          //   highlight: true,
                          // )
                        ],
                      ),
                      // Text("asdsad")
                    ],
                  ),
                  //  SizedBox(
                  //   height: 3.sh(),
                  // ),
                ),
              )
            ],
          ),
          Consumer(builder: (context, ref, c) {
            final orderHistoryService = ref.watch(orderHistoryServiceProvider);
            final staffRating = orderHistoryService.staffRating;
            final gettingShopReviewFirstTime =
                ref.watch(orderHistoryServiceProvider).gettingfirstTimeReview;
            // print(gettingShopReviewFirstTime);
            if (gettingShopReviewFirstTime) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(12.sr()),
                  child: const CircularProgressIndicator(),
                ),
              );
            }
            return staffRating.ratings.isEmpty
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 25.sh()),
                    child: InfoMessage.noReview())
                : SizedBox(
                    height: MediaQuery.of(context).size.height * .5,
                    child: ShopReviewList(
                      staff: staff,
                      shop: shop,
                      ratingWithStat: staffRating,
                    ),
                  );
          }),
          // ratingFuture.when(data: (data) {
          //   //khali
          //   return data.ratings.isEmpty
          //       ? Container(
          //           margin: EdgeInsets.symmetric(vertical: 25.sh()),
          //           child: InfoMessage.noReview())
          //       : SizedBox(
          //           height: MediaQuery.of(context).size.height * .5,
          //           child: ShopReviewList(
          //             shop: shop,
          //             ratingWithStat: data,
          //           ),
          //         );
          // }, error: (e, s) {
          //   print(e);
          //   return Container();
          // }, loading: () {
          //   return const Center(
          //     child: Padding(
          //       padding: EdgeInsets.all(8.0),
          //       child: CircularProgressIndicator(),
          //     ),
          //   );
          // })
        ],
      ),
    );
  }
}
