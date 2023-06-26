import 'package:ezdeliver/screen/addressDetails/components/addressitemwidget.dart';
import 'package:ezdeliver/screen/checkout/checkout.dart';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

class CartDetails extends ConsumerWidget {
  const CartDetails({
    this.showButton = true,
    this.promo = true,
    this.checkout = true,
    this.notifier,
    Key? key,
  }) : super(key: key);
  final bool showButton;
  final bool promo;
  final bool checkout;
  final ChangeNotifierProvider<CartService>? notifier;

  @override
  Widget build(BuildContext context, ref) {
    final cartService = ref.watch(notifier ?? cartServiceProvider);

    final currentAddress = ref.watch(locationServiceProvider).currentAddress;
    final locationDetail = ref.watch(locationServiceProvider).locationDetail;

    // if (locationDetail == null) {
    //   return Center(
    //     child: Transform.scale(
    //       scale: 0.5,
    //       child: CircularProgressIndicator(
    //         color: Theme.of(context).primaryColor,
    //       ),
    //     ),
    //   );
    // }
    // print(ref
    //     .read(notifier ?? cartServiceProvider)
    //     .selectedDeliveryAddress
    //     .value!
    //     .label);
    var finalAddress = currentAddress ??
        ref
            .read(notifier ?? cartServiceProvider)
            .selectedDeliveryAddress
            .value ??
        AddressModel(
            saved: false,
            fullName:
                (ref.read(userChangeProvider).loggedInUser.value?.name) ?? "",
            phone:
                (ref.read(userChangeProvider).loggedInUser.value?.phone) ?? "",
            address: (locationDetail?.displayName.split(",").first) ?? "",
            fullAddress: (locationDetail?.displayName) ?? "",
            label: 'Temp',
            location: Location(coordinates: [
              double.parse((locationDetail?.lon) ?? "27"),
              double.parse((locationDetail?.lat) ?? "85")
            ]));

    if (ref
            .read(notifier ?? cartServiceProvider)
            .selectedDeliveryAddress
            .value ==
        null) {
      Utilities.futureDelayed(10, () {
        cartService.selectedDeliveryAddress.value = finalAddress;
      });
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.sw()),
      child: Column(
        children: [
          if (promo) ...[
            SizedBox(
              height: 12.sh(),
            ),
            InputTextField(
                enabled: false,
                title: "Promo",
                isVisible: true,
                onChanged: (val) {}),
            SizedBox(
              height: 20.sh(),
            ),
          ],
          Column(
            children: [
              if (checkout) ...[
                InfoSpacedBox(
                    label: "Sub Total",
                    value: cartService.total().toStringAsFixed(0)),
                SizedBox(
                  height: 15.sh(),
                ),
                const InfoSpacedBox(
                  label: "Delivery Fee",
                  value: "Rs. 99",
                  showLabel: false,
                ),
                SizedBox(
                  height: 15.sh(),
                ),
                const InfoSpacedBox(label: "Discount", value: "0"),
                Divider(
                  height: 40.sh(),
                ),
              ] else
                SizedBox(
                  height: 10.sh(),
                ),
              InfoSpacedBox(
                  label: "Total",
                  value: (cartService.total() - 99.0).toStringAsFixed(0),
                  focused: true),
              if (!checkout)
                Divider(
                  height: 5.sh(),
                ),
            ],
          ),
          SizedBox(
            height: 20.sh(),
          ),
          if (!checkout &&
              ref.read(userChangeProvider).loggedInUser.value != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: kTextStyleInterMedium.copyWith(
                    fontSize: 15.ssp(),
                    color: CustomTheme.greyColor,
                  ),
                ),
                SizedBox(
                  height: 20.sh(),
                ),
                InkWell(
                  onTap: () {
                    Utilities.pushPage(const YourLocation(), 15);
                  },
                  child: Container(
                    // padding: EdgeInsets.all(5),
                    // margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(4, 4),
                            blurRadius: 14,
                            color: CustomTheme.blackColor.withOpacity(0.1))
                      ],
                    ),
                    child: AddressItemWidget(
                      isDetail: false,
                      item: finalAddress,
                      click: true,
                      showIcon: false,
                      transparent: false,
                      onSelected: () {
                        Utilities.pushPage(const YourLocation(), 15);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.sh(),
                ),
              ],
            ),
          if (showButton) ...[
            CustomElevatedButton(
                // color: Theme.of(context).primaryColor,
                // width: 250.sw(min: 200),
                onPressedElevated: () {
                  // print(condi);
                  Utilities.checkIfLoggedIn(
                      context: context,
                      doIfLoggedIN: () {
                        if (ref.read(notifier ?? cartServiceProvider).condi ==
                            ConditionsForNotAvail.allAvail) {
                          if (ResponsiveLayout.isMobile) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: ((context) {
                              return CheckOut(
                                finalAddress: finalAddress,
                                notifier: notifier,
                              );
                            })));
                          } else {
                            ResponsiveLayout.setWidget(CheckOut(
                              finalAddress: finalAddress,
                              notifier: notifier,
                            ));
                          }
                        } else if (ref
                                .read(notifier ?? cartServiceProvider)
                                .condi ==
                            ConditionsForNotAvail.allNotAvail) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text(
                                    "Products in your cart are currently unavailable. Go to Home page to add products.",
                                    textAlign: TextAlign.center,
                                    style: kTextStyleInterRegular.copyWith(
                                      fontSize: 16.ssp(),
                                      color: CustomTheme.greyColor,
                                    ),
                                  ),
                                  actions: [
                                    CustomElevatedButton(
                                        onPressedElevated: () {
                                          Navigator.pop(context);
                                        },
                                        elevatedButtonText: "OK")
                                  ],
                                );
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text(
                                    "Few products in your cart are currently unavailable. Order only available ones?",
                                    textAlign: TextAlign.center,
                                    style: kTextStyleInterRegular.copyWith(
                                      fontSize: 18.ssp(),
                                      color: CustomTheme.greyColor,
                                    ),
                                  ),
                                  actionsPadding: EdgeInsets.all(20.sr()),
                                  actions: [
                                    OutlinedElevatedButtonCombo(
                                      width: 150,
                                      outlinedButtonText: "Cancel   ",
                                      elevatedButtonText: "Continue",
                                      onPressedOutlined: () {
                                        Navigator.pop(context);
                                      },
                                      center: true,
                                      onPressedElevated: () {
                                        Navigator.pop(context);
                                        cartService.removeUnavailProducts();
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: ((context) {
                                          return CheckOut(
                                            finalAddress: finalAddress,
                                            notifier: notifier,
                                          );
                                        })));
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      });
                },
                elevatedButtonText: "Proceed"),
            SizedBox(
              height: 20.sh(),
            ),
          ]
        ],
      ),
    );
  }
}

class InfoSpacedBox extends StatelessWidget {
  const InfoSpacedBox(
      {super.key,
      this.focused = false,
      required this.value,
      required this.label,
      this.verticalPadding = 0,
      this.showLabel = true});
  final bool focused, showLabel;
  final String value, label;
  final double verticalPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding.sh()),
      child: Row(children: [
        Text(
          "$label:",
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: CustomTheme.greyColor),
        ),
        const Spacer(),
        Text("${showLabel ? "Rs. " : ""}$value",
            style: focused
                ? kTextStyleInterMedium.copyWith(
                    fontSize: 19.ssp(), color: Theme.of(context).primaryColor)
                : Theme.of(context).textTheme.bodyText1)
      ]),
    );
  }
}
