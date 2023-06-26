// import 'package:ezdeliver/screen/cart/components/cartItems.dart';
// import 'package:ezdeliver/screen/cart/components/checkoutbox.dart';
// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/models/orderModel.dart';
// import 'package:ezdeliver/screen/orderHistory/cancelorder/cancelorder.dart';
// import 'package:ezdeliver/screen/orderHistory/components/orderEnd.dart';
// import 'package:ezdeliver/screen/orderHistory/components/orderListItem.dart';
// import 'package:ezdeliver/screen/orderHistory/components/shopReview/shopReview.dart';
// import 'package:flutter/foundation.dart';

// class SingleShopFeedback extends StatefulWidget {
//   const SingleShopFeedback(
//       {required this.requestedShopData,
//       required this.order,
//       this.log = false,
//       super.key,
//       required this.index});
//   final RequestedShop requestedShopData;
//   final Order order;
//   final int index;
//   final bool log;

//   @override
//   State<SingleShopFeedback> createState() => _SingleShopFeedbackState();
// }

// class _SingleShopFeedbackState extends State<SingleShopFeedback> {
//   final double verticalPadding = 10;
//   int total = 0;
//   bool expanded = false;
//   @override
//   void initState() {
//     super.initState();
//     for (var element in widget.requestedShopData.feedback.itemsAllocated) {
//       total += element.total;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalItems = widget.requestedShopData.feedback.itemsAllocated.length;
//     final itemLength = checkItemsLength(totalItems, expanded);

//     return Consumer(builder: (context, ref, c) {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 9.sw(), vertical: 15.sh()),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4.sr()),
//           color: Theme.of(context).scaffoldBackgroundColor,
//           boxShadow: [
//             BoxShadow(
//                 offset: const Offset(0, 4),
//                 blurRadius: 4,
//                 color: CustomTheme.getBlackColor().withOpacity(0.08))
//           ],
//         ),
//         child: Column(
//           children: [
//             // Image.network(widget.requestedShopData.shop.),
//             GestureDetector(
//               onTap: () {
//                 // Utilities.pushPage(
//                 //     Scaffold(
//                 //       body: ShopProfile(
//                 //         shop: widget.requestedShopData.shop,
//                 //       ),
//                 //     ),
//                 //     10);
//                 ref.read(orderHistoryServiceProvider).getReviews(
//                     shopId: widget.requestedShopData.shop.id, clear: true);
//                 showModalBottomSheet(
//                     backgroundColor: Theme.of(context).backgroundColor,
//                     context: context,
//                     isScrollControlled: true,
//                     // isDismissible: false,
//                     builder: (context) {
//                       return ShopProfile(
//                         shop: widget.requestedShopData.shop,
//                       );
//                     });
//               },
//               child: Row(
//                 children: [
//                   ProfileAvatar(
//                     fontSize: 14.ssp(),
//                     padding: 10,
//                     size: 50,
//                     shop: widget.requestedShopData.shop,
//                   ),
//                   SizedBox(
//                     width: 4.sw(),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               " ${widget.requestedShopData.shop.name}",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyText1!
//                                   .copyWith(fontWeight: FontWeight.w500),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                   color: Colors.transparent,
//                                   // color: Theme.of(context).primaryColor,
//                                   borderRadius: BorderRadius.circular(6.sr())),
//                               padding: EdgeInsets.symmetric(vertical: 3.sh()),
//                               child: Text(
//                                 " ~${widget.requestedShopData.distance ~/ 1000} km",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyText2!
//                                     .copyWith(
//                                         // fontSize: 10.ssp(),
//                                         color: CustomTheme.greyColor),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 3.sw(),
//                             ),
//                             const Spacer(),
//                             call(context, widget.log),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 3.sh(),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomRating(
//                               margin: EdgeInsets.symmetric(horizontal: 5.sw()),
//                               short: true,
//                               rating:
//                                   widget.requestedShopData.shop.avgRating ?? 0,
//                               itemSize: 15.sr(),
//                               count:
//                                   widget.requestedShopData.shop.rateCount ?? 0,
//                               ignoreGestures: true,
//                               allowHalfRating: true,
//                               shop: widget.requestedShopData.shop,
//                             ),
//                             if (getStatusForFeedback(
//                                             widget.requestedShopData.status)
//                                         .index ==
//                                     Status.ontheway.index &&
//                                 widget.requestedShopData.verficationOTP != null)
//                               RichText(
//                                 text: TextSpan(
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodyText1!
//                                       .copyWith(),
//                                   children: [
//                                     const TextSpan(
//                                       text: "OTP code: ",
//                                     ),
//                                     TextSpan(
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyText1!
//                                           .copyWith(),
//                                       text: widget
//                                           .requestedShopData.verficationOTP
//                                           .toString(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (getStatusForFeedback(
//                                         widget.requestedShopData.status)
//                                     .index ==
//                                 Status.completed.index)
//                               if (widget.order.requestedShops[widget.index]
//                                       .feedback.rating?.user ==
//                                   null)
//                                 GestureDetector(
//                                   onTap: () async {
//                                     showModalBottomSheet(
//                                         backgroundColor:
//                                             Theme.of(context).backgroundColor,
//                                         context: context,
//                                         isScrollControlled: true,
//                                         builder: (context) {
//                                           return OrderEnd(
//                                             order: widget.order,
//                                             requestedShopData:
//                                                 widget.requestedShopData,
//                                           );
//                                         });
//                                   },
//                                   child: RichText(
//                                     text: TextSpan(
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyText1!
//                                           .copyWith(
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                               decoration:
//                                                   TextDecoration.underline),
//                                       children: const [
//                                         TextSpan(
//                                           text: "Review",
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),

//             // SizedBox(
//             //   height: 20.sh(),
//             // ),
//             // for (int i = 0;
//             //     i <
//             //         checkItemsLength(
//             //             widget.requestedShopData.feedback.itemsAllocated.length,
//             //             expanded);
//             //     i++)
//             //   ProductItems(
//             //     item: widget.order.items
//             //         .where((element) =>
//             //             element.product.id ==
//             //             widget.requestedShopData.feedback.itemsAllocated[i]
//             //                 .product.id)
//             //         .first,
//             //     feedBackItems:
//             //         widget.requestedShopData.feedback.itemsAllocated[i],
//             //     cart: false,
//             //   ),
//             // SizedBox(
//             //   height: 20.sh(),
//             // ),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //   children: [
//             //     GestureDetector(
//             //       onTap: () {
//             //         setState(() {
//             //           expanded = !expanded;
//             //         });
//             //       },
//             //       child: Row(
//             //         children: [
//             //           Icon(
//             //             Icons.call,
//             //             size: 18.sr(),
//             //             color: Theme.of(context).primaryColor,
//             //           ),
//             //           SizedBox(
//             //             width: 3.sw(),
//             //           ),
//             //           Text(
//             //             widget.requestedShopData.shop.phone,
//             //             style: Theme.of(context).textTheme.bodyText2,
//             //           ),
//             //         ],
//             //       ),
//             //     )
//             //   ],
//             // ),
//             SizedBox(
//               height: 20.sh(),
//             ),
//             AnimatedSize(
//               duration: const Duration(milliseconds: 350),
//               child: Column(
//                 children: [
//                   for (int i = 0; i < itemLength; i++)
//                     Container(
//                       margin: EdgeInsets.only(bottom: 20.sh()),
//                       child: ProductItems(
//                         feedBackItems:
//                             widget.requestedShopData.feedback.itemsAllocated[i],
//                         item: widget.order.items
//                             .where((element) =>
//                                 element.product.id ==
//                                 widget.requestedShopData.feedback
//                                     .itemsAllocated[i].product.id)
//                             .first,
//                         cart: false,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             // SizedBox(
//             //   height: 20.sh(),
//             // ),
//             if (widget.order.requestedShops[widget.index].feedback.rating
//                     ?.ratingByShop !=
//                 null)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Rating by shop",
//                     style: Theme.of(context).textTheme.bodyText2!.copyWith(),
//                   ),
//                   CustomRating(
//                       showLabel: false,
//                       ignoreGestures: true,
//                       rating: clapRatinValue(
//                         widget.requestedShopData.feedback.rating!.ratingByShop!
//                             .toDouble(),
//                       ),
//                       itemSize: 18.sr()),
//                 ],
//               ),
//             SizedBox(height: 8.sh()),
//             Row(children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     expanded = !expanded;
//                   });
//                 },
//                 child: Container(
//                   color: Colors.transparent,
//                   child: Text(
//                     expanded
//                         ? "Show less"
//                         : totalItems > itemLength
//                             ? "Show ${totalItems - itemLength} more"
//                             : "",
//                     style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                         color: Theme.of(context).primaryColor.withOpacity(0.8)),
//                   ),
//                 ),
//               ),
//               const Spacer(),
//               if (widget.requestedShopData.status == 2)
//                 GestureDetector(
//                   onTap: () async {
//                     Utilities.pushPage(
//                         CancelOrder(
//                           selectedOrder: widget.order,
//                           requestId: widget.requestedShopData.id,
//                         ),
//                         15);
//                     try {
//                       var status = await ref
//                           .read(orderHistoryServiceProvider)
//                           .cancelOrder(widget.order.id!,
//                               requestId: widget.requestedShopData.id);
//                       if (status) {
//                         snack.success("Order cancelled sucessfully");
//                       }
//                     } catch (e) {
//                       print(e);
//                       snack.error(e);
//                     }
//                   },
//                   child: Container(
//                     color: Colors.transparent,
//                     child: Text(
//                       "Cancel",
//                       style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                           color: Theme.of(context).primaryColor,
//                           decoration: TextDecoration.underline),
//                     ),
//                   ),
//                 ),
//               // else
//               Builder(builder: (context) {
//                 // print(widget.requestedShopData.status);
//                 return Row(
//                   children: [
//                     if (widget.requestedShopData.status >= 3) ...[
//                       if (widget.requestedShopData.status == 3)
//                         //   Text("OTP: ${widget.order.verificationOTP}"),
//                         // SizedBox(
//                         //   width: 8.sw(),
//                         // ),
//                         StatusBox(
//                           status: widget.requestedShopData.status,
//                           feedback: true,
//                         ),
//                     ],
//                     if (widget.requestedShopData.status == -2)
//                       StatusBox(
//                         status: widget.requestedShopData.status,
//                         feedback: true,
//                       ),
//                   ],
//                 );
//               })
//             ]),
//             // if (expanded) ...[
//             SizedBox(
//               height: 3.sh(),
//             ),
//             InfoSpacedBox(
//               showLabel: false,
//               value: "${widget.requestedShopData.feedback.deliveryTime} min",
//               label: "Delivery Time",
//               verticalPadding: verticalPadding,
//             ),
//             InfoSpacedBox(
//               value:
//                   widget.requestedShopData.feedback.deliveryCharge.toString(),
//               label: "Delivery Fee",
//               verticalPadding: verticalPadding,
//             ),
//             InfoSpacedBox(
//               value: total.toString(),
//               label: "Sub Total",
//               verticalPadding: verticalPadding,
//             ),
//             // ],
//             Divider(
//               height: 25.sh(),
//               color: CustomTheme.greyColor,
//               thickness: 0.5,
//             ),
//             InfoSpacedBox(
//               focused: true,
//               value: (total + widget.requestedShopData.feedback.deliveryCharge)
//                   .toString(),
//               label: "Total",
//               verticalPadding: verticalPadding,
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget call(BuildContext context, bool log) {
//     return GestureDetector(
//       onTap: () async {
//         if (log) {
//           await FirebaseAnalytics.instance
//               .logEvent(name: "Call_Shop", parameters: {
//             "id":
//                 CustomKeys.ref.read(userChangeProvider).loggedInUser.value?.id,
//             "name":
//                 CustomKeys.ref.read(userChangeProvider).loggedInUser.value?.name
//           });
//         }
//         showDialog(
//             context: context,
//             builder: (context) {
//               return CustomDialog(
//                   textSecond: "call this shop?",
//                   elevatedButtonText: "Confirm",
//                   onPressedElevated: () async {
//                     if (log) {
//                       await FirebaseAnalytics.instance
//                           .logEvent(name: "Call_shop_confirm", parameters: {
//                         "id": CustomKeys.ref
//                             .read(userChangeProvider)
//                             .loggedInUser
//                             .value
//                             ?.id,
//                         "name": CustomKeys.ref
//                             .read(userChangeProvider)
//                             .loggedInUser
//                             .value
//                             ?.name,
//                         "phone": widget.requestedShopData.shop.phone
//                       });
//                     }
//                     Uri url = Uri(
//                         scheme: 'tel',
//                         path: widget.requestedShopData.shop.phone);
//                     if (await canLaunchUrl(url)) {
//                       await launchUrl(url);
//                     } else {
//                       snack.error("Phone call not supported");
//                     }
//                   });
//             });
//       },
//       child: Container(
//         child: Row(
//           children: [
//             Icon(
//               Icons.call,
//               size: 18.sr(),
//               color: Theme.of(context).primaryColor,
//             ),
//             SizedBox(
//               width: 3.sw(),
//             ),
//             Text(
//               widget.requestedShopData.shop.phone,
//               style: Theme.of(context).textTheme.bodyText2,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   int checkItemsLength(int length, bool expanded) {
//     if (length > 1 && !expanded) return 1;
//     return length;
//   }
// }