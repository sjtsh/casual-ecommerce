import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderdetail.dart';

class CancelOrderReasonItem {
  CancelOrderReasonItem({required this.text});
  final String text;
}

List<CancelOrderReasonItem> cancelOrderReasonItems = [
  CancelOrderReasonItem(text: "Change/Combine order"),
  CancelOrderReasonItem(text: "Delivery time is too long"),
  CancelOrderReasonItem(text: "Duplicate Order"),
  CancelOrderReasonItem(text: "Change of Delivery Address"),
  CancelOrderReasonItem(text: "Delivery charge"),
  CancelOrderReasonItem(text: "Change of mind"),
  CancelOrderReasonItem(text: "Found cheaper alternative"),
  CancelOrderReasonItem(text: "Decided for alternate product"),
];

class CancelOrder extends ConsumerWidget {
  CancelOrder({required this.selectedOrder, this.requestId, super.key});
  final Order selectedOrder;
  final String? requestId;
  final selectProvider = StateProvider<int>((ref) {
    return 100;
  });
  final selectRadioProvider = StateProvider<int>((ref) {
    return 100;
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () {
        ref.read(orderHistoryServiceProvider).cancelOrderPage = false;
        return Future.value(true);
      },
      child: Scaffold(
          appBar: simpleAppBar(context,
              title: "Order Cancellation",
              search: false,
              close: false, back: () {
            ref.read(orderHistoryServiceProvider).cancelOrderPage = false;
          }),
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            normalOrderList(
              selectedOrder,
            ),
            Divider(
              thickness: 1,
              color: CustomTheme.getBlackColor(),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sw()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cancellation Reason",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(
                      height: 14.sh(),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Theme.of(context).backgroundColor,
                            context: context,
                            builder: (context) {
                              return Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Consumer(
                                              builder: (context, ref, c) {
                                            final selected = ref
                                                .read(selectProvider.notifier)
                                                .state;
                                            return RadioListTile(
                                                value: selected == index,
                                                groupValue: true,
                                                title: Text(
                                                    cancelOrderReasonItems[
                                                            index]
                                                        .text),
                                                onChanged: (val) {
                                                  ref
                                                      .read(selectProvider
                                                          .notifier)
                                                      .state = index;
                                                  Navigator.pop(context);
                                                });
                                          }),
                                        );
                                      },
                                      itemCount: cancelOrderReasonItems.length,
                                    ),
                                  ),
                                  // CustomElevatedButton(
                                  //     onPressedElevated: () {
                                  //       ref
                                  //               .read(selectProvider.notifier)
                                  //               .state =
                                  //           ref.read(selectRadioProvider);
                                  //       Navigator.pop(context);
                                  //     },
                                  //     elevatedButtonText: "Confirm")
                                ],
                              );
                            });
                      },
                      child: Container(
                        // height: 15.sh(),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.sr())),
                            color: CustomTheme.greyColor.withOpacity(0.08)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ref.watch(selectProvider) == 100
                                  ? "Select"
                                  : cancelOrderReasonItems[
                                          ref.read(selectProvider)]
                                      .text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: CustomTheme.primaryColor),
                            ),
                            Icon(
                              Icons.expand_more,
                              color: CustomTheme.primaryColor,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.sh(),
                    ),
                    Text(
                      "Comments",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(
                      height: 14.sh(),
                    ),
                    InputTextField(
                      title: "Remarks",
                      isVisible: false,
                      onChanged: (val) {},
                    ),
                    SizedBox(
                      height: 30.sh(),
                    ),
                    CustomElevatedButton(
                      onPressedElevated: ref.watch(selectProvider) == 100
                          ? null
                          : () async {
                              final orderHistoryService =
                                  ref.read(orderHistoryServiceProvider);
                              try {
                                var status = await orderHistoryService
                                    .cancelOrder(selectedOrder.id!,
                                        requestId: requestId);
                                if (status) {
                                  orderHistoryService.cancelOrderPage = false;
                                  Utilities.futureDelayed(1, () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                  snack.success("Order cancelled sucessfully");
                                }
                              } catch (e) {
                                print(e);
                                snack.error(e);
                              }
                            },
                      elevatedButtonText: "Submit",
                    )
                  ],
                ),
              ),
            )
          ])),
    );
  }
}
