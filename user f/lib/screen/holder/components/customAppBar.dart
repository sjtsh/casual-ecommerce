import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/upper_section.dart';

import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/search/search.dart';
import 'package:ezdeliver/screen/settingsscreen/settingsscreen.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';
import 'package:flutter/foundation.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {this.search = true,
      this.isCart = false,
      this.log = false,
      super.key,
      this.scrollController});
  final bool search;
  final bool isCart;
  final bool log;
  final ScrollController? scrollController;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool showSearchBarOnly = false;

  double animationEnd = 10;
  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(() {
        // print(widget.scrollController!.position.pixels);
        if (widget.scrollController!.position.pixels >= animationEnd) {
          setState(() {
            showSearchBarOnly = true;
          });
        } else {
          setState(() {
            showSearchBarOnly = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile) {
      return Container(
          height: kBottomNavigationBarHeight + 10,
          // margin: EdgeInsets.only(top: 10.sh()),
          padding: EdgeInsets.symmetric(horizontal: 12.sw(), vertical: 13.sh()),
          // color: Theme.of(context).primaryColor,
          child: Stack(
            children: [
              Visibility(
                  visible: !showSearchBarOnly,
                  child: Align(
                    alignment: Alignment.center,
                    child: Animate(
                        effects: [
                          FadeEffect(
                              duration: 0.15.seconds, curve: Curves.slowMiddle),
                        ],

                        // : const [
                        //     SlideEffect(
                        //       begin: const Offset(0, 0),
                        //       end: const Offset(0, .3),
                        //     )
                        //     // duration: 1.seconds,
                        //   ],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Row(
                            //   children: [
                            //     Builder(builder: (context) {
                            //       final status = ref.watch(CustomSocket.socketStatusProvider);
                            //       return Padding(
                            //         padding: const EdgeInsets.all(3),
                            //         child: GestureDetector(
                            //           onTap: () async {
                            //             ref.read(customSocketProvider).connect();
                            //             if (log) {
                            //               await FirebaseAnalytics.instance
                            //                   .logEvent(name: "Green_dot", parameters: {
                            //                 "id": ref
                            //                     .read(userChangeProvider)
                            //                     .loggedInUser
                            //                     .value
                            //                     ?.id,
                            //                 "name": ref
                            //                     .read(userChangeProvider)
                            //                     .loggedInUser
                            //                     .value
                            //                     ?.name
                            //               });
                            //             }
                            //           },
                            //           child: Container(
                            //             width: 8.sr(),
                            //             height: 8.sr(),
                            //             decoration: BoxDecoration(
                            //                 color: status
                            //                     ? CustomTheme.successColor
                            //                     : CustomTheme.greyColor,
                            //                 shape: BoxShape.circle),
                            //           ),
                            //         ),
                            //       );
                            //     })
                            //   ],
                            // ),
                            // SizedBox(
                            //   width: 12.sw(),
                            // ),
                            const Expanded(
                              child: AddressInfoBox(),
                            ),
                            SizedBox(
                              width: 50.sw(),
                            ),
                            // if (!isCart)
                            //   GestureDetector(
                            //     onTap: () {
                            //       Navigator.push(context, MaterialPageRoute(builder: (_) {
                            //         return const Cart(
                            //           newScreen: true,
                            //         );
                            //       }));
                            //     },
                            //     child: const Center(
                            //       child: CartBottomNav(
                            //         up: true,
                            //       ),
                            //     ),
                            //   ),

                            if (widget.search) const CustomSearchButton(),
                            SizedBox(
                              width: 12.sw(),
                            ),
                            GestureDetector(
                              onTap: () {
                                Utilities.checkIfLoggedIn(
                                    context: context,
                                    doIfLoggedIN: () {
                                      Utilities.pushPage(SettingsScreen(), 15);
                                    });
                              },
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (widget.isCart) const EmptyCartWidget()
                          ],
                        )),
                  )),
              Visibility(
                visible: showSearchBarOnly,
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                        context: context, delegate: CustomSerachDelegate());
                  },
                  child: const CustomSearchField().animate().fadeIn().slide(
                      // begin: showSearchBarOnly ? 0.8 : 1,
                      // end: showSearchBarOnly ? 1 : 0.8,
                      duration: 0.2.seconds),
                ),
              )
            ],
          ));
    } else {
      return UpperSection(
        scrollController: widget.scrollController,
      );
    }
  }
}

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key, this.label = "Products"});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 10.sw()),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6.sr()),
            border: Border.all(color: CustomTheme.primaryColor)),
        child: Row(
            children: [
          const Icon(
            Icons.search,
            color: CustomTheme.greyColor,
          ),
          SizedBox(
            width: 10.sw(),
          ),
          Row(
            children: [
              Text(
                "Search ",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ]..animate(delay: 0.5.seconds).fade(duration: 0.3.seconds)));
  }
}

class EmptyCartWidget extends ConsumerWidget {
  const EmptyCartWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final itemCount = ref.watch(cartServiceProvider).cartItems.length;

    if (itemCount > 0) {
      return InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 1), () {
            return showDialog(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveLayout.margin(0.25)),
                    child: CustomDialog(
                        textSecond: 'empty cart?',
                        elevatedButtonText: 'Confirm',
                        onPressedElevated: () async {
                          ref.read(cartServiceProvider).clearCart();
                        }),
                  );
                });
          });
        },
        child: Center(
            child: Text(
          "Empty Cart ($itemCount)",
          style: Theme.of(context).textTheme.bodyText1,
        )),
      );
    }
    return Container();
  }
}

AppBar simpleAppBar(BuildContext context,
    {required String title,
    List<Widget> actions = const [],
    bool search = true,
    bool close = true,
    bool cart = false,
    bool setting = false,
    bool fromCart = false,
    Function? back,
    bool centerTitle = true}) {
  CustomKeys.cartKey = GlobalKey();
  if (!ResponsiveLayout.isMobile) {
    search = false;
    cart = false;
  }
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: CustomTheme.getBlackColor(),
    leading: close
        ? InkWell(
            onTap: () {
              if (back != null) {
                back();
              }

              if (ResponsiveLayout.isMobile) Navigator.pop(context);
            },
            child: Icon(
              GroceliIcon.back_butoon,
              color: CustomTheme.getBlackColor(),
            ))
        : Container(),
    title: Consumer(builder: (context, ref, c) {
      final dark = ref.watch(customThemeServiceProvider).isDarkMode;
      return Text(
        title,
        style: responsiveTextStyle(
            Theme.of(CustomKeys.context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: dark
                    ? ResponsiveLayout.isMobile
                        ? CustomTheme.darkBlackColor
                        : CustomTheme.primaryColor
                    : ResponsiveLayout.isMobile
                        ? CustomTheme.blackColor
                        : CustomTheme.primaryColor)),
      );
    }),
    centerTitle: centerTitle,
    actions: [
      // if (cart)
      //   GestureDetector(
      //     onTap: () {
      //       Navigator.push(context, MaterialPageRoute(builder: (_) {
      //         return const Cart(
      //           newScreen: true,
      //         );
      //       }));
      //     },
      //     child: const Center(
      //       child: CartBottomNav(
      //         up: true,
      //       ),
      //     ),
      //   ),
      if (search)
        Consumer(builder: (context, ref, c) {
          // final products = ref.watch(searchServiceProvider).searchProduct;
          return GestureDetector(
              child: Icon(
                Icons.search_rounded,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                showSearch(
                  context: context,
                  delegate: CustomSerachDelegate(),
                );
              });
        }),
      SizedBox(
        width: 12.sw(),
      ),
      if (cart) ...[
        GestureDetector(
            onTap: () {
              if (fromCart) {
                Navigator.pop(context);
              } else {
                Utilities.pushPage(
                    const Cart(
                      newScreen: true,
                    ),
                    15);
              }
            },
            child: Center(
              child: CartBottomNav(
                colorCart: CustomTheme.primaryColor,
                colorLabel: CustomTheme.whiteColor,
              ),
            )

            //  Icon(
            //   GroceliIcon.cart,
            //   color: Theme.of(context).primaryColor,
            // ),
            ),
        SizedBox(
          width: 12.sw(),
        ),
      ],
      ...actions,
      if (setting) ...[
        GestureDetector(
          onTap: () {
            Utilities.checkIfLoggedIn(
                context: context,
                doIfLoggedIN: () {
                  Utilities.pushPage(SettingsScreen(), 15);
                });
          },
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(
          width: 12.sw(),
        ),
      ],
    ],
  );
}

class AddressInfoBox extends StatelessWidget {
  const AddressInfoBox({
    this.log = false,
    this.color,
    Key? key,
  }) : super(key: key);
  final bool log;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, c) {
      final locationService = ref.watch(locationServiceProvider);
      final addressDetail = locationService.locationDetail;
      final selectedAddress = locationService.currentAddress;
      final permissions = locationService.permissionEnums;
      if (permissions != LocationPermissionEnums.always) {
        // showModalBottomSheet(
        //     context: context,
        //     builder: (context) {
        //       return Container();
        //     });
      }

      final textTheme = Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: color ?? CustomTheme.whiteColor,
          );
      return GestureDetector(
        onTap: () async {
          Utilities.pushPage(YourLocation(), 15);
          if (log) {
            await FirebaseAnalytics.instance.logEvent(
                name: "Location_Info_Tap",
                parameters: {
                  "id": ref.read(userChangeProvider).loggedInUser.value?.id
                });
          }
        },
        child: kIsWeb
            ? Container()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 3.sh()),
                decoration: BoxDecoration(
                    color: ResponsiveLayout.isMobile
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.sr())),
                child: permissions == LocationPermissionEnums.always ||
                        selectedAddress != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 3.sh(),
                            horizontal: ResponsiveLayout.isMobile ? 9.sw() : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (addressDetail != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    if (ResponsiveLayout.isMobile)
                                      Icon(
                                        Icons.my_location,
                                        color: CustomTheme.whiteColor,
                                        size: 16.sr(),
                                      ),
                                    SizedBox(
                                      width: 3.sh(),
                                    ),
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        var addresses = addressDetail
                                            .displayName
                                            .split(",");
                                        return Text(
                                          selectedAddress == null
                                              ? addresses.length > 1
                                                  ? addresses[1]
                                                  : addresses.first
                                              : "${selectedAddress.label} - ${selectedAddress.fullAddress.split(',').first}",
                                          overflow: TextOverflow.ellipsis,
                                          style: ResponsiveLayout.isMobile
                                              ? textTheme
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                        );
                                      }),
                                    ),
                                    SizedBox(
                                      width: 2.sw(),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18.sr(),
                                      color:
                                          color ?? CustomTheme.getBlackColor(),
                                      // size: 20.sr(),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 8.sr(),
                                      width: 8.sr(),
                                      child: CircularProgressIndicator(
                                        color: ResponsiveLayout.isMobile
                                            ? CustomTheme.whiteColor
                                            : CustomTheme.primaryColor,
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3.sw(),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Searching...',
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.copyWith(
                                            color: ResponsiveLayout.isMobile
                                                ? null
                                                : CustomTheme.getBlackColor()),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 3.sh(), horizontal: 9.sw()),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 16.sr(),
                            ),
                            SizedBox(
                              width: 3.sw(),
                            ),
                            Text(
                              "Location permissions",
                              style: textTheme,
                            ),
                          ],
                        ),
                      ),
              ),
      );
    });
  }
}
