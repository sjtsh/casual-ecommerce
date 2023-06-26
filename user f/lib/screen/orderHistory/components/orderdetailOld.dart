// import 'package:ezdeliver/screen/addressDetails/components/addressitemwidget.dart';
// import 'package:ezdeliver/screen/cart/components/cartItems.dart';
// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
// import 'package:ezdeliver/screen/models/orderModel.dart';
// import 'package:ezdeliver/screen/orderHistory/cancelorder/cancelorder.dart';
// import 'package:ezdeliver/screen/orderHistory/components/noProductPrice.dart';
// import 'package:ezdeliver/screen/orderHistory/components/orderListItem.dart';
// import 'package:ezdeliver/screen/orderHistory/components/singleShopFeedbackList.dart';

// class OrderDetail extends ConsumerWidget {
//   const OrderDetail({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final orderHistoryService = ref.read(orderHistoryServiceProvider);
//     final selectedOrder = ref.watch(orderHistoryServiceProvider).selectedOrder;
//     // print("object");

//     return WillPopScope(
//       onWillPop: () {
//         orderHistoryService.selectedOrder = null;
//         return Future.value(true);
//       },
//       child: SafeArea(
//           child: Scaffold(
//         appBar: simpleAppBar(context, title: "Order Details", search: false),
//         body: selectedOrder == null && Api.hasInternet
//             ? Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).primaryColor,
//                 ),
//               )
//             : !Api.hasInternet
//                 ? Center(
//                     child: InfoMessage.noInternet(),
//                   )
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 22.sw()),
//                         child: OrderListItem(
//                           // address: true,
//                           order: selectedOrder!,
//                           detail: false,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 12.sh(),
//                       ),
//                       Expanded(
//                         // flex: 13,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // if (selectedOrder.address != null)
//                             //   OrderShippingDetails(
//                             //       selectedOrder: selectedOrder),

//                             SizedBox(
//                               height: 16.sh(),
//                             ),
//                             orderListHeader(context, selectedOrder,
//                                 orderHistoryService, ref),
//                             SizedBox(
//                               height: 16.sh(),
//                             ),

//                             checkChanges(context, selectedOrder),
//                             if (selectedOrder.status < Status.confirmed.index ||
//                                 selectedOrder.requestedShops.isEmpty)
//                               normalOrderList(selectedOrder)
//                             else
//                               selectedOrder.requestedShops.isEmpty
//                                   ? Center(
//                                       child: Transform.scale(
//                                         scale: 0.5,
//                                         child: CircularProgressIndicator(
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                       ),
//                                     )
//                                   : Expanded(
//                                       child: ListView.separated(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 22.sr(),
//                                               vertical: 10.sh()),
//                                           separatorBuilder: (context, index) {
//                                             return SizedBox(
//                                               height: 12.sh(),
//                                             );
//                                           },
//                                           itemCount: selectedOrder
//                                               .requestedShops.length,
//                                           itemBuilder: (context, index) {
//                                             return SingleShopFeedback(
//                                                 index: index,
//                                                 requestedShopData: selectedOrder
//                                                     .requestedShops[index],
//                                                 order: selectedOrder);
//                                           }),
//                                     ),
//                             // SizedBox(
//                             //   height: 10.sr(),
//                             // ),
//                             grandTotal(context, selectedOrder),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//       )),
//     );
//   }

//   Widget checkChanges(BuildContext context, Order order) {
//     if (order.status != Status.confirmed.index &&
//         order.status != Status.ontheway.index &&
//         order.status != Status.completed.index) return Container();
//     {}
//     List<OrderItem> notAvailable = [], priceChanged = [];

//     for (var originalItem in order.items) {
//       for (var requestedShop in order.requestedShops) {
//         var index = requestedShop.feedback.itemsAllocated.indexWhere(
//             (element) => originalItem.product.id == element.product.id);

//         if (index == -1) {
//           notAvailable.add(originalItem);
//         } else {
//           if (requestedShop.feedback.itemsAllocated[index].total
//                   // /
//                   //         requestedShop.feedback.itemsAllocated[index].itemCount
//                   !=
//                   originalItem.product.price * originalItem.itemCount
//               // /
//               // originalItem.itemCount
//               ) {
//             priceChanged.add(originalItem
//               ..product.oldPrice =
//                   requestedShop.feedback.itemsAllocated[index].total
//               ..product.oldCount =
//                   requestedShop.feedback.itemsAllocated[index].itemCount);
//           }
//         }
//       }
//     }

//     if (notAvailable.isEmpty && priceChanged.isEmpty) return Container();
//     return GestureDetector(
//       onTap: () {
//         Utilities.pushPage(
//             NoProductPrice(
//               notAvailable: notAvailable,
//               priceChanged: priceChanged,
//             ),
//             10);
//       },
//       child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 22.sw(), vertical: 10.sh()),
//           padding: EdgeInsets.all(8.sr()),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5.sr()),
//               color: Theme.of(context).primaryColor.withAlpha(200)),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.info,
//                 color: Colors.white70,
//                 // size: 16.sr(),
//               ),
//               SizedBox(
//                 width: 10.sw(),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (notAvailable.isNotEmpty)
//                     Text(
//                       "Some products were not available.",
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .copyWith(color: Colors.white),
//                     ),
//                   if (priceChanged.isNotEmpty) ...[
//                     if (notAvailable.isNotEmpty)
//                       SizedBox(
//                         height: 5.sh(),
//                       ),
//                     Text(
//                       "Price/Qty has changed.",
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .copyWith(color: Colors.white),
//                     ),
//                   ]
//                 ],
//               ),

//               // SizedBox(
//               //   width: 5.sw(),
//               // ),
//               const Spacer(),
//               Text(
//                 "View All",
//                 style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                     color: Colors.white, decoration: TextDecoration.underline),
//               )
//             ],
//           )),
//     );
//   }

//   Container grandTotal(BuildContext context, Order selectedOrder) {
//     int total = 0;
//     if (selectedOrder.requestedShops.isNotEmpty && selectedOrder.status > 2) {
//       for (var element in selectedOrder.requestedShops) {
//         if (element.status > 0) {
//           total += element.feedback.deliveryCharge;
//           for (var e in element.feedback.itemsAllocated) {
//             total += e.total;
//           }
//         }
//       }
//     } else {
//       total = selectedOrder.total;
//     }

//     return Container(
//       padding: EdgeInsets.all(22.sr()),
//       child: Column(
//         children: [
//           const Divider(
//             thickness: 0.5,
//             color: CustomTheme.greyColor,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Grand Total: ",
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyText1!
//                     .copyWith(color: CustomTheme.greyColor),
//               ),
//               RichText(
//                 text: TextSpan(
//                   style: Theme.of(context).textTheme.bodyText2!.copyWith(),
//                   children: [
//                     TextSpan(
//                         text: "Rs.${total.toString()} ",
//                         style: kTextStyleInterSemiBold.copyWith(
//                             fontSize: 19.ssp(),
//                             color: Theme.of(context).primaryColor)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget orderListHeader(BuildContext context, Order selectedOrder,
//       OrderHistoryService orderHistoryService, WidgetRef ref) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 22.sr()),
//       child: Row(
//         children: [
//           Text(
//             "Your Orders",
//             style: Theme.of(context).textTheme.headline5!,
//           ),
//           const Spacer(),
//           if (selectedOrder.status == Status.confirmed.index ||
//               selectedOrder.status == Status.processing.index ||
//               selectedOrder.status == Status.pending.index)
//             GestureDetector(
//               onTap: () async {
//                 Utilities.pushPage(
//                     CancelOrder(
//                       selectedOrder: selectedOrder,
//                     ),
//                     15);
//                 orderHistoryService.cancelOrderPage = true;

//                 // showDialog(
//                 //     context: context,
//                 //     builder: (context) {
//                 //       return CustomDialog(
//                 //           elevatedButtonText: "Confirm",
//                 //           textSecond: "cancel this order?",
//                 //           onPressedElevated: () async {
//                 //             try {
//                 //               var status = await orderHistoryService
//                 //                   .cancelOrder(selectedOrder.id!);
//                 //               if (status) {
//                 //                 snack.success("Order cancelled sucessfully");
//                 //               }
//                 //             } catch (e) {
//                 //               print(e);
//                 //               snack.error(e);
//                 //             }
//                 //           });
//                 //     });
//               },
//               child: Container(
//                   color: Colors.transparent,
//                   child: Text(
//                     "Cancel Order",
//                     style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                         color: Theme.of(context).primaryColor,
//                         decoration: TextDecoration.underline),
//                   )),
//             ),
//           // if (selectedOrder.status == Status.ontheway.index)
//           //   RichText(
//           //     text: TextSpan(
//           //       style: Theme.of(context).textTheme.bodyText1!.copyWith(),
//           //       children: [
//           //         const TextSpan(
//           //           text: "Your OTP code is: ",
//           //         ),
//           //         TextSpan(
//           //           style: Theme.of(context).textTheme.bodyText1!.copyWith(),
//           //           text: selectedOrder.verificationOTP.toString(),
//           //         ),
//           //       ],
//           //     ),
//           //   ),

//           Builder(builder: (context) {
//             final status = getStatus(selectedOrder.status);

//             if (status == Status.failed ||
//                 status == Status.cancelledByMe ||
//                 status == Status.cancelledByShop ||
//                 status == Status.cancelledBySystem ||
//                 status == Status.completed) {
//               return Container(
//                   padding: EdgeInsets.all(5.sr()),
//                   decoration: BoxDecoration(
//                       // color: selectedOrder.status >= 2
//                       //     ? successColor.withAlpha(50)
//                       //     : CustomTheme.errorColorSecondary,
//                       borderRadius: BorderRadius.circular(5.sr())),
//                   child: GestureDetector(
//                     onTap: () {
//                       ref
//                           .read(orderHistoryServiceProvider)
//                           .reorder(selectedOrder.items);

//                       // showDialog(
//                       //     context: context,
//                       //     builder: (context) {
//                       //       return CustomDialog(
//                       //           textSecond: "re-order these items?",
//                       //           elevatedButtonText: "Yes",
//                       //           onPressedElevated: () async {
//                       //             // ref.watch(
//                       //             //     locationServiceProvider);

//                       //           });
//                       //     });
//                     },
//                     child: Text(
//                       "Reorder",
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .copyWith(color: CustomTheme.errorColor),
//                     ),
//                   ));
//             } else {
//               return Container();
//             }
//           }),
//         ],
//       ),
//     );
//   }
// }

// class OrderShippingDetails extends StatelessWidget {
//   const OrderShippingDetails({
//     super.key,
//     required this.selectedOrder,
//   });

//   final Order selectedOrder;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 22.sw()),
//       child: GestureDetector(
//         // onTap: () {
//         //   showModalBottomSheet(
//         //       context: context,
//         //       builder: (context) {
//         //         return Container();
//         //       });
//         // },
//         child: Container(
//           padding: EdgeInsets.all(15.sr()),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4.sr()),
//             color: Theme.of(context).scaffoldBackgroundColor,
//             boxShadow: [
//               BoxShadow(
//                   offset: const Offset(4, 4),
//                   blurRadius: 12,
//                   color: CustomTheme.blackColor.withOpacity(0.125))
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Ship & bill to ",
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyText2!
//                     .copyWith(color: Theme.of(context).primaryColor),
//               ),
//               SizedBox(
//                 height: 8.sh(),
//               ),
//               Row(
//                 children: [
//                   Text(selectedOrder.address!.fullName,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .copyWith(color: CustomTheme.getBlackColor())),
//                   const Spacer(),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 5.sr(),
//                         backgroundColor:
//                             selectedOrder.address!.label.toLowerCase() == "home"
//                                 ? CustomTheme.homeColor
//                                 : CustomTheme.workColor,
//                       ),
//                       SizedBox(
//                         width: 4.sw(),
//                       ),
//                       Text(selectedOrder.address!.label,
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyText2!
//                               .copyWith(color: CustomTheme.greyColor)),
//                     ],
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: 4.sh(),
//               ),
//               Text(selectedOrder.address!.phone,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyText1!
//                       .copyWith(color: CustomTheme.getBlackColor())),
//               SizedBox(
//                 height: 4.sh(),
//               ),
//               Text(selectedOrder.address!.fullAddress,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyText1!
//                       .copyWith(color: CustomTheme.getBlackColor())),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Expanded normalOrderList(Order selectedOrder, {int flex = 1}) {
//   return Expanded(
//     flex: flex,
//     child: ListView.separated(
//         padding: EdgeInsets.symmetric(horizontal: 22.sr()),
//         separatorBuilder: (context, index) {
//           return SizedBox(
//             height: 12.sh(),
//           );
//         },
//         itemCount: selectedOrder.items.length,
//         itemBuilder: (context, index) {
//           return ProductItems(
//             item: selectedOrder.items[index],
//             cart: false,
//             // order: selectedOrder,
//           );
//         }),
//   );
// }