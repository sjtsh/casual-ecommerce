import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';

final ratingProvider = StateProvider.autoDispose<double>((ref) {
  return 0.0;
});
final reviewProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

class OrderEnd extends StatelessWidget {
  const OrderEnd(
      {required this.order, required this.requestedShopData, super.key});
  final Order order;
  final RequestedShop requestedShopData;

  @override
  Widget build(BuildContext context) {
    // print(rating);

    return Consumer(builder: (context, ref, c) {
      final rating = ref.watch(ratingProvider);
      final review = ref.watch(reviewProvider);
      return WillPopScope(
        onWillPop: () {
          // ref.read(ratingProvider.notifier).state = 0.0;
          return Future.value(true);
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15.sw(),
            right: 15.sw(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15.sh(),
              ),
              Text(
                "Rate ${requestedShopData.staff.name}",
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(
                height: 15.sh(),
              ),

              ProfileAvatar(
                shop: requestedShopData.shop,
                size: 30.sr(),
              ),
              SizedBox(
                height: 15.sh(),
              ),
              Consumer(builder: (context, ref, c) {
                return CustomRating(
                  rating: rating,
                  align: MainAxisAlignment.center,
                  itemSize: 40.sr(),
                  showLabel: false,
                  onRatingUpdate: (value) {
                    ref.read(ratingProvider.notifier).state = value;
                  },
                );
              }),
              SizedBox(
                height: 15.sh(),
              ),
              InputTextField(
                title: "",
                onChanged: (val) {
                  ref.read(reviewProvider.notifier).state = val;
                },
                hintText: "Your Review",
              ),
              SizedBox(
                height: 15.sh(),
              ),
              OutlinedElevatedButtonCombo(
                center: true,
                outlinedButtonText: "Cancel",
                elevatedButtonText: "Submit",
                onPressedOutlined: () {
                  // ref.read(ratingProvider.notifier).state = 0.0;
                  Navigator.pop(context);
                },
                onPressedElevated: rating == 0.0
                    ? null
                    : () async {
                        try {
                          bool status = await ref
                              .read(orderHistoryServiceProvider)
                              .rateShop(
                                  review: review,
                                  rating: rating,
                                  id: requestedShopData.id);

                          if (status) {
                            Utilities.futureDelayed(1, () {
                              // ref.read(ratingProvider.notifier).state = 0.0;
                              Navigator.pop(context);
                            });
                            Utilities.futureDelayed(10, () async {
                              await showDialog(
                                  barrierColor:
                                      CustomTheme.blackColor.withOpacity(0.35),
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InfoMessage.reviewPosted(),
                                          SizedBox(
                                            height: 30.sh(),
                                          ),
                                          CustomElevatedButton(
                                            onPressedElevated: () {
                                              Navigator.pop(context);
                                            },
                                            elevatedButtonText: "Review Posted",
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            });
                          }
                        } catch (e, s) {
                          print("$e $s");
                        }
                      },
              ),
              SizedBox(
                height: 15.sh(),
              ),
              // Text(
              //   "* This feature is in progress.",
              //   style: Theme.of(context)
              //       .textTheme
              //       .bodyText2!
              //       .copyWith(color: CustomTheme.errorColor),
              // ),
              // SizedBox(
              //   height: 15.sh(),
              // ),

              // InputTextField(title: "", onChanged: (val) {})
            ],
          ),
        ),
      );
    });
  }
}
