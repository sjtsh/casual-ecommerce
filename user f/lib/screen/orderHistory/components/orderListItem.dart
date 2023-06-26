
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/orderHistory/components/shopReview/shopReviewList.dart';


class OrderListItem extends StatelessWidget {
  const OrderListItem(
      {Key? key, required this.order, this.detail = true, this.address = false})
      : super(key: key);

  final Order order;
  final bool detail;
  final bool address;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.sr()),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              offset: const Offset(4, 4),
              blurRadius: 12,
              color: CustomTheme.blackColor.withOpacity(0.125))
        ],
      ),
      padding: EdgeInsets.all(15.sr()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   "Order:",
              //   style: Theme.of(context).textTheme.bodyText2!.copyWith(),
              // ),
              Text(
                "#OR${order.orderId}",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              Builder(builder: (context) {
                // int? time = getTimer(order);
                return Column(
                  children: [
                    // if (order.status == 2 &&
                    //     time != null)
                    //   CountDown(
                    //     waitTime: Duration(milliseconds: time),
                    //   ),
                    StatusBox(status: order.status),
                  ],
                );
              })
            ],
          ),
          if (detail) ...[
            SizedBox(
              height: 8.sh(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order.items.isEmpty ? order.itemCount : order.items.length} Items",
                  style: kTextStyleInterRegular.copyWith(
                      fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                ),
                Text(
                  "Rs. ${order.total}",
                  maxLines: 1,
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                ),
              ],
            ),
          ],
          SizedBox(
            height: 8.sh(),
          ),
          // AddressItemWidget(
          //               click: false,
          //               isDetail: true,
          //               item: order.address!,
          //             ),
          // Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customDate(order.createdAt!, time: true),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: CustomTheme.greyColor),
              ),
              // if (address)
              if (order.fulfilled != null)
                if (!order.fulfilled!)
                  Row(
                    children: [
                      Text(
                        "Price/Qty\nchanged",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: CustomTheme.primaryColor,
                            decoration: TextDecoration.underline),
                      ),
                      // SizedBox(
                      //   width: 5.sw(),
                      // ),
                      // Icon(
                      //   Icons.error,
                      //   color: CustomTheme.errorColor.withOpacity(0.5),
                      //   size: 18.sr(),
                      // ),
                    ],
                  )

              // Text(
              //   DateFormat("hh:mm a").format(order.createdAt!),
              //   style: Theme.of(context)
              //       .textTheme
              //       .bodyText2!
              //       .copyWith(color: CustomTheme.greyColor),
              // ),
            ],
          ),
          // if (order.address != null)
          //   if (address) ...[

          //     SizedBox(
          //       height: 8.sh(),
          //     ),
          //   ],
          // Container(
          //   padding: EdgeInsets.symmetric(
          //       horizontal: 8.sw(), vertical: 4.sh()),
          //   decoration: BoxDecoration(
          //       color: orders[newIndex].status >= 2
          //           ? CustomTheme.successColor.withAlpha(30)
          //           : CustomTheme.errorColor.withAlpha(30),
          //       borderRadius: BorderRadius.circular(5.sr())),
          //   child: Text(
          //     getStatus(orders[newIndex].status).name,
          //     style: Theme.of(context)
          //         .textTheme
          //         .bodyText2!
          //         .copyWith(
          //             fontSize: 12.ssp(),
          //             color: orders[newIndex].status >= 2
          //                 ? CustomTheme.successColor
          //                 : CustomTheme.errorColor),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  StatusBox(
      {Key? key,
      required this.status,
      this.feedback = false,
      this.toolTip = true,
      this.filter})
      : super(key: key);

  final int status;
  final bool feedback;
  final Function? filter;
  bool toolTip;
  @override
  Widget build(BuildContext context) {
    final color =
        status >= 2 ? CustomTheme.successColor : CustomTheme.errorColor;
    final statusDetail = getStatusDetail(
        feedback ? getStatusForFeedback(status) : getStatus(status));
    return Tooltip(
      triggerMode: toolTip ? TooltipTriggerMode.tap : null,
      message: statusDetail.detail,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sw(), vertical: 4.sh()),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(5.sr())),
        child: Row(
          children: [
            Text(
              statusDetail.label,
              style:
                  Theme.of(context).textTheme.bodyText2!.copyWith(color: color),
            ),
            if (filter != null) ...[
              SizedBox(
                width: 5.sw(),
              ),
              GestureDetector(
                onTap: () {
                  filter!();
                },
                child: Transform.scale(
                  scale: 0.8,
                  child: Container(
                    padding: EdgeInsets.all(2.sr()),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomTheme.greyColor.withOpacity(0.4)),
                    child: Center(
                        child: FittedBox(
                            child: Icon(
                      Icons.close,
                      color: CustomTheme.getBlackColor(),
                    ))),
                  ),
                ),
              )
            ] else ...[
              SizedBox(
                width: 3.sw(),
              ),
              Icon(
                statusDetail.iconData,
                size: 15.sr(),
                color: color.withAlpha(80),
              )
            ]
          ],
        ),
      ),
    );
  }
}
