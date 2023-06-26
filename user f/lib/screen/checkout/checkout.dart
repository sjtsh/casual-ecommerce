import 'package:ezdeliver/screen/addressDetails/components/addressitemwidget.dart';
import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/cart/components/checkoutbox.dart';
import 'package:ezdeliver/screen/checkout/components/UserAdressDetail.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/holder/holder.dart';

// import 'package:ezdeliver/screen/users/component/userservice.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

class CheckOut extends ConsumerWidget {
  CheckOut({required this.finalAddress, super.key, this.notifier});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ChangeNotifierProvider<CartService>? notifier;
  String remarks = '';
  final AddressModel finalAddress;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartService = ref.watch(notifier ?? notifier ?? cartServiceProvider);
    final orderHistoryService = ref.read(orderHistoryServiceProvider);
    // final userService = ref.watch(userChangeProvider);
    return SafeArea(
      child: Scaffold(
        //change address
        //lat long
        //payment method
        //order status
        appBar:
            simpleAppBar(context, title: "Checkout", search: false, back: () {
          ResponsiveLayout.setWidget(const Cart(
            newScreen: true,
          ));
        }),
        body: Padding(
          padding: EdgeInsets.only(
              top: 8, bottom: 14, left: 20.sw(), right: 20.sw()),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Address',
                      style: kTextStyleInterMedium.copyWith(
                          fontSize: 15.ssp(), color: CustomTheme.greyColor),
                    ),
                    // IconButton(
                    //     onPressed: () {
                    //       Navigator.push(context,
                    //           MaterialPageRoute(builder: (context) {
                    //         return AddressForm();
                    //       }));
                    //     },
                    //     icon: Container(
                    //       // padding: EdgeInsets.all(4.sr()),
                    //       decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           color: Theme.of(context).primaryColor),
                    //       child: Center(
                    //         child: Icon(
                    //           GroceliIcon.add,
                    //           color: CustomTheme.whiteColor,
                    //           size: 18.sr(),
                    //         ),
                    //       ),
                    //     ))
                  ],
                ),
                SizedBox(
                  height: 20.sh(),
                ),
                Builder(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressItemWidget(
                        isDetail: false,
                        item: finalAddress,
                        click: false,
                      ),
                      const Divider(),
                      // Text(
                      //   "* You can change your address from home.",
                      //   style: Theme.of(context)
                      //       .textTheme
                      //       .bodyText2!
                      //       .copyWith(color: CustomTheme.errorColor),
                      // ),
                      // if (currentAddress == null) ...[
                      // SizedBox(
                      //   height: 10.sh(),
                      // ),
                      UserAddressDetailForm(
                        formKey: formKey,
                        address: finalAddress,
                      ),
                      // ]
                    ],
                  );
                }),
                InputTextField(
                    controller: orderHistoryService.remarksController,
                    title: "Remarks",
                    onChanged: (val) {
                      remarks = val;
                    }),
                // Expanded(
                //   child: address.isEmpty
                //       ? Center(
                //           child: Text(
                //           "Add Delivery Address",
                //           style: responsiveTextStyle(
                //               Theme.of(context).textTheme.bodyText2!),
                //         ))
                //       : ListView.separated(
                //           itemBuilder: (context, index) {
                //             return Row(
                //               children: [
                //                 Radio(
                //                     value: cartService
                //                             .selectedDeliveryAddress.value ==
                //                         address[index],
                //                     groupValue: true,
                //                     onChanged: (val) {
                //                       cartService.selectedDeliveryAddress.value =
                //                           address[index];
                //                     }),
                //                 Expanded(
                //                     child: AddressItemWidget(
                //                         isDetail: true,
                //                         showIcon: false,
                //                         onSelected: () {
                //                           cartService.selectedDeliveryAddress
                //                               .value = address[index];
                //                         },
                //                         click: true,
                //                         item: address[index]))
                //               ],
                //             );
                //           },
                //           separatorBuilder: (context, index) {
                //             return SizedBox(
                //               height: 20.sh(),
                //             );
                //           },
                //           itemCount: address.length),
                // ),
                SizedBox(
                  height: 20.sh(),
                ),
                Text(
                  'Payment Method',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 15.ssp(), color: CustomTheme.getBlackColor()),
                ),
                Column(
                  children: [
                    RadioListTile(
                      value: true,
                      groupValue: true,
                      toggleable: true,
                      onChanged: (val) {},
                      title: Text('Cash On Delivery',
                          style: kTextStyleInterMedium.copyWith(
                              color: CustomTheme.getBlackColor(),
                              fontSize: 13.ssp())),
                      subtitle:
                          cartService.selectedDeliveryAddress.value != null
                              ? Text(
                                  "${cartService.selectedDeliveryAddress.value!.fullAddress.split(",").first},${cartService.selectedDeliveryAddress.value!.fullAddress.split(",").last}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: CustomTheme.greyColor),
                                )
                              : null,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.sh(),
                ),
                // const Spacer(),
                CartDetails(
                  notifier: notifier,
                  showButton: false,
                  promo: false,
                ),
                Align(
                  alignment: Alignment.center,
                  child: CustomElevatedButton(
                    color: Theme.of(context).primaryColor,
                    // width: 250.sw(min: 200),
                    onPressedElevated: cartService
                                .selectedDeliveryAddress.value !=
                            null
                        ? () async {
                            var selectedAddress = ref
                                .read(notifier ?? cartServiceProvider)
                                .selectedDeliveryAddress
                                .value!;

                            if (!selectedAddress.saved &&
                                !AddressModel.checkValidAddress(
                                    selectedAddress) &&
                                !formKey.currentState!.validate()) {
                            } else {
                              // print(selectedAddress.toJson());
                              CustomDialogBox.loading(true);
                              try {
                                var status = await ref
                                    .read(orderHistoryServiceProvider)
                                    .punchOrder(
                                        await cartService.createOrder(
                                            selectedAddress, remarks),
                                        oldOrder: ref
                                                    .read(
                                                        orderHistoryServiceProvider)
                                                    .selectedOrder !=
                                                null
                                            ? ref
                                                .read(
                                                    orderHistoryServiceProvider)
                                                .selectedOrder!
                                                .id
                                            : null);
                                if (status) {
                                  CustomDialogBox.loading(false);
                                  orderHistoryService.remarksController.clear();
                                  Utilities.futureDelayed(15, () {
                                    showDialog(
                                        barrierColor: CustomTheme.blackColor
                                            .withOpacity(0.35),
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Theme.of(context)
                                                .backgroundColor,
                                            content: WillPopScope(
                                              onWillPop: () {
                                                return Future.value(false);
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InfoMessage.orderPlaced(),
                                                  SizedBox(
                                                    height: 30.sh(),
                                                  ),
                                                  CustomElevatedButton(
                                                    onPressedElevated: () {
                                                      ref
                                                          .read(
                                                              orderHistoryServiceProvider)
                                                          .selectedIndex = 0;
                                                      ref
                                                          .read(indexProvider
                                                              .state)
                                                          .state = 2;

                                                      Navigator.of(context)
                                                          .popUntil((route) {
                                                        // print(route.settings.name);
                                                        return route.settings
                                                                .name ==
                                                            "Holder";
                                                      });
                                                      CustomKeys.webScaffoldKey
                                                          .currentState!
                                                          .closeEndDrawer();

                                                      // Navigator.pop(context);
                                                    },
                                                    elevatedButtonText:
                                                        "Order Status",
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  });

                                  // ref
                                  //     .read(locationServiceProvider)
                                  //     .setCurrentLocation();
                                  // ref
                                  //     .read(locationServiceProvider)
                                  //     .currentAddress = null;

                                  Future.delayed(
                                      const Duration(milliseconds: 10), () {
                                    // Navigator.pop(context);

                                    ref
                                        .read(notifier ?? cartServiceProvider)
                                        .clearCart(showMsg: false);
                                    // cartService.selectedDeliveryAddress.value =
                                    //     null;

                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //   return const OrderHistory();
                                    // }));
                                  });
                                } else {
                                  CustomDialogBox.loading(false);
                                }
                              } catch (e) {
                                CustomDialogBox.loading(false);
                                snack.error(e);
                                // CustomDialogBox.loading(false);
                              }
                            }
                          }
                        : null,
                    elevatedButtonText: 'Checkout',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
