import 'dart:async';

import 'package:ezdeliver/screen/auth/login/forgetpassword.dart';
import 'package:ezdeliver/screen/auth/login/login.dart';
import 'package:ezdeliver/screen/auth/register/register.dart';
import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/category/category.dart';
import 'package:ezdeliver/screen/component/helper/animatedindexedstack.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/home/home.dart';
import 'package:ezdeliver/screen/orderHistory/orderhistory.dart';

import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

final indexProvider = StateProvider<int>((ref) {
  return 0;
});

class Holder extends StatefulHookConsumerWidget {
  const Holder({this.payload, this.log = false, Key? key}) : super(key: key);
  final String? payload;
  final bool log;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HolderState();
}

class _HolderState extends ConsumerState<Holder> {
  late StreamSubscription<Position> locationSubscription;
  init() async {
    try {
      ref.read(customSocketProvider).connect();
      ref.read(locationServiceProvider).init(context);
      // await CustomLocation.determinePosition();
      await Utilities.pushPage(const YourLocation(), 50);

      await ref.read(orderHistoryServiceProvider).fetchOrders();
      Utilities.futureDelayed(10, () async {
        await Utilities.loadall();
      });
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   if (widget.payload != null) {
      //     Navigator.push(context, MaterialPageRoute(
      //       builder: (context) {
      //         return Container();
      //       },
      //     ));
      //   }
      // });
      // locationSubscription = Geolocator.getPositionStream(
      //     locationSettings: const LocationSettings(
      //   accuracy: LocationAccuracy.high,
      //   distanceFilter: 100,
      // )).listen((event) {
      //   if (!event.isMocked) {
      //     // snack.success("${event.latitude} ${event.longitude}");
      //     ref.read(locationServiceProvider).setCurrentLocation(location: event);
      //   }
      // });

      if (widget.payload != null &&
          ref.read(userChangeProvider).loggedInUser.value != null) {
        CustomLocalNotification.handleTapOrder(widget.payload,
            context: context);
      }
    } catch (e, s) {
      print("$e $s");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    init();
    // scrollController = initScroll();
  }

  late final ScrollController scrollController = initScroll();

  ScrollController initScroll() {
    // var productFromSubCategories = ;
    // final skip = CustomKeys.ref.watch(productCategoryServiceProvider).skip;

    final controller = ScrollController();

    // if (productFromSubCategories != null) {
    //   productFromSubCategories = [];
    // }
    controller.addListener(() async {
      if (CustomKeys.ref
              .read(productCategoryServiceProvider)
              .productFromSubCategories !=
          null) {
        if (CustomKeys.ref
                .read(productCategoryServiceProvider)
                .productFromSubCategories!
                .length >
            CustomKeys.ref.read(productCategoryServiceProvider).skip + 9) {
          if (controller.position.extentAfter < 100) {
            await CustomKeys.ref
                .read(productCategoryServiceProvider)
                .loadingMoreSubCategoy();
          }
        }
      }
    });

    // }

    // ResponsiveLayout.holderScrollController = controller;
    return controller;
  }

  @override
  void dispose() {
    //TODO:: fix this

    // locationSubscription.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(indexProvider);
    CustomKeys.init(ref, context);
    // customSocket.connect();
    return SafeArea(
      child: withWill(
        ref,
        child: Stack(
          children: [
            Scaffold(
              key: CustomKeys.webScaffoldKey,
              endDrawer: SizedBox(
                  width: 450.sw(),
                  child: Builder(
                    builder: (_) {
                      final drawerWidget =
                          ref.watch(ResponsiveLayout.drawerWidgetProvider);
                      return drawerWidget;
                    },
                  )),
              resizeToAvoidBottomInset: false,
              floatingActionButton: Api.production
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // FloatingActionButton(
                        //   onPressed: () async {
                        //     try {
                        //       var data = await Api.get(endpoint: "product");
                        //       if (data != null) {
                        //         var products = productFromJson(data.body);
                        //         var count = 0;
                        //         await Future.forEach(products, (element) async {
                        //           // var element = products[0];
                        //           if (element.image != "") {
                        //             var imageData = await Api.get(
                        //                 url: element.image, endpoint: '');
                        //             if (imageData != null) {
                        //               var dataBytes = imageData.bodyBytes;

                        //               String dir =
                        //                   (await getExternalStorageDirectory())!
                        //                       .path;

                        //               File file = File('$dir/${element.id}.jpg');
                        //               await file.writeAsBytes(dataBytes);
                        //               count++;
                        //               print(count);

                        //               // var request = MultipartRequest(
                        //               //     "POST",
                        //               //     Uri.parse(
                        //               //         "http://localhost:8000/api/removebg"));
                        //               // // request.files.add(MultipartFile.fromBytes(
                        //               // //     "image_file", dataBytes));
                        //               // request.fields.addAll(
                        //               //     {"image_file": base64Encode(dataBytes)});
                        //               // request.headers.addAll(
                        //               //     {"Content-type": "multipart/form-data"});

                        //               // if (response.statusCode == 200) {
                        //               //   print("done");
                        //               // }

                        //               // var bgremoved = await client.post(
                        //               //   Uri.parse(
                        //               //       "http://localhost:8000/api/removebg"),
                        //               //   headers: {
                        //               //     "Content-Type": "multipart/form-data",
                        //               //     //  "application/x-www-form-urlencoded"
                        //               //     "x-api-key":
                        //               //         "5a41c24f5784c6686fe44f4881b2fb5498038be58d3adab3d41ea699ee6400d6"
                        //               //   },
                        //               // );
                        //               // if (bgremoved.statusCode == 200) {
                        //               //   print("done");
                        //               // }
                        //             }
                        //           }
                        //         });
                        //       }
                        //     } catch (e, s) {
                        //       print("$e $s");
                        //     }
                        //   },
                        //   child: const Icon(GroceliIcon.information),
                        // ),
                        SizedBox(
                          height: 20.sh(),
                        ),
                        FloatingActionButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(orderHistoryServiceProvider)
                                  .autoOrder();
                              snack.success("order posted");
                            } catch (e) {
                              snack.error(e.toString());
                            }
                            // Navigator.pop(context);
                          },
                          child: const Icon(GroceliIcon.my_order),
                        ),
                        SizedBox(
                          height: 20.sh(),
                        ),
                        // FloatingActionButton(
                        //   heroTag: "delete",
                        //   onPressed: () async {
                        //     try {
                        //       var status = await ref
                        //           .read(orderHistoryServiceProvider)
                        //           .deleteAllOrderData();
                        //       if (status) {
                        //         snack.success("Data wiped");
                        //       }
                        //     } catch (e) {
                        //       snack.error(e);
                        //     }
                        //   },
                        //   child: const Icon(Icons.delete_forever),
                        // )
                      ],
                    ),
              // appBar: index == 0
              //     ? PreferredSize(
              //         preferredSize: const Size(0, kBottomNavigationBarHeight),
              //         child: CustomAppBar(
              //           search: index != 2,
              //           isCart: index == 2,
              //           scrollController: scrollController,
              //         ))
              //     : null,
              body: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: ResponsiveLayout.margin()),
                child: Column(
                  children: [
                    if (!ResponsiveLayout.isMobile) const CustomAppBar(),
                    Expanded(
                      child: Builder(builder: (context) {
                        final defaultWidget = Builder(
                          builder: (context) {
                            final index = CustomKeys.ref.watch(indexProvider);
                            return AnimatedIndexedStack(
                                index: index,
                                children: [
                                  Home(
                                    scrollController: scrollController,
                                  ),
                                  const CategoryScreen(),
                                  if (ref
                                          .read(userChangeProvider)
                                          .loggedInUser
                                          .value !=
                                      null)
                                    const OrderHistory(),
                                  const Cart()
                                ]);
                          },
                        );

                        final widget = ref.watch(statelistProvider).holders;
                        return Stack(children: [
                          defaultWidget,
                          ...widget
                              .map((e) => Positioned.fill(child: e))
                              .toList()
                        ]);
                      }),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: ResponsiveLayout.isMobile
                  ? BottomNavigationBar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      selectedItemColor: Theme.of(context).primaryColor,
                      unselectedItemColor: CustomTheme.greyColor,
                      showUnselectedLabels: true,
                      currentIndex: index,
                      onTap: (value) async {
                        handleNavigationClick(context, value, scrollController);
                        if (widget.log) {
                          await FirebaseAnalytics.instance.logEvent(
                              name: "Bottom_nav_bar$value",
                              parameters: {
                                "id": ref
                                    .read(userChangeProvider)
                                    .loggedInUser
                                    .value
                                    ?.id,
                                "name": ref
                                    .read(userChangeProvider)
                                    .loggedInUser
                                    .value
                                    ?.name
                              });
                        }
                      },
                      items: [
                          BottomNavigationBarItem(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              label: 'Home',
                              icon: const Icon(GroceliIcon.home)),
                          BottomNavigationBarItem(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              label: 'Categories',
                              icon: const Icon(GroceliIcon.category)),
                          if (ref.read(userChangeProvider).loggedInUser.value !=
                              null)
                            BottomNavigationBarItem(
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                label: 'My Orders',
                                icon: const OrderBOttomNav()),
                          BottomNavigationBarItem(
                            backgroundColor: Theme.of(context).backgroundColor,
                            label: 'Cart',
                            icon: const CartBottomNav(
                              up: false,
                            ),
                          ),
                          // BottomNavigationBarItem(
                          //     backgroundColor: Theme.of(context).backgroundColor,
                          //     label: 'One Tap',
                          //     icon: Icon(Icons.report)),
                        ])
                  : null,
            ),
            if (ref.watch(shouldSignUp))
              Builder(builder: (context) {
                
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width < 600
                          ? 10
                          : MediaQuery.sizeOf(context).width / 3,
                      vertical: MediaQuery.sizeOf(context).height / 11),
                  child: Material(child: Consumer(builder: (context, ref, c) {
                    final auth = ref.watch(authProvider);

                    return Stack(
                      children: [
                        Container(
                          child: auth == Auth.login
                              ? Login(
                                  dialog: true,
                                )
                              : auth == Auth.signup
                                  ? RegisterScreen(
                                      dialog: true,
                                    )
                                  : const ForgotPassword(dialog: true),
                        ),
                        Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ))
                      ],
                    );
                  })),
                );
              })
          ],
        ),
      ),
    );
  }
}

Widget withWill(WidgetRef ref, {required Widget child}) =>
    ResponsiveLayout.isMobile
        ? child
        : WillPopScope(
            onWillPop: () {
              ref.read(statelistProvider).pop();
              return Future.value(false);
            },
            child: child);

handleNavigationClick(
    BuildContext context, int value, ScrollController? scrollController,
    {bool throughPop = false}) {
  ResponsiveLayout.setHolderWidget(null);
  if (!throughPop) CustomKeys.ref.read(statelistProvider).tabChanged(value);
  if (scrollController == null) {
    CustomKeys.ref.read(indexProvider.notifier).state = value;
    return;
  }
  if (value == 0 && CustomKeys.ref.read(indexProvider.notifier).state == 0) {
    // animatetotop();

    if (scrollController.offset < 10 &&
        !CustomKeys.ref.read(userChangeProvider).loadingAll) {
      Utilities.futureDelayed(10, () async {
        await Utilities.loadall(context: context);
      });
    } else {
      scrollController.animateTo(0,
          duration: widgetSwitchAnimationDuration, curve: Curves.easeInOut);
    }
  } else {
    CustomKeys.ref.read(indexProvider.notifier).state = value;
  }
}

class CartBottomNav extends HookConsumerWidget {
  const CartBottomNav(
      {this.colorCart, this.colorLabel, Key? key, this.up = false})
      : super(key: key);
  final bool up;
  final Color? colorCart, colorLabel;
  @override
  Widget build(BuildContext context, ref) {
    final animator = useAnimationController(
        lowerBound: -3.sh(),
        upperBound: 3.sh(),
        duration: const Duration(milliseconds: 50));

    return Consumer(
        // key: up ? null : CustomKeys.cartKey,
        builder: (context, ref, c) {
      final items = ref.watch(cartServiceProvider).cartItems;
      if (UniversalPlatform.isAndroid) {
        animator.reverse().whenComplete(() {
          animator.forward().whenComplete(() => animator.forward().whenComplete(
              () => animator.reverse().whenComplete(() => animator.forward())));
        });
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            GroceliIcon.cart,
            // size: 20.sr(),
            color: colorCart,
          ),
          if (items.isNotEmpty)
            AnimatedBuilder(
                animation: animator,
                builder: (context, w) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 30),
                    right: -5.sw(),
                    top: -5.sh() + animator.value,
                    child: Container(
                        width: 16.sr(),
                        height: 16.sr(),
                        decoration: BoxDecoration(
                            color: colorCart ?? Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              items.length.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: colorLabel ??
                                          (colorCart != null
                                              ? CustomTheme.primaryColor
                                              : CustomTheme.whiteColor)),
                            ),
                          ),
                        )),
                  );
                })
        ],
      );
    });
  }
}

class OrderBOttomNav extends HookConsumerWidget {
  const OrderBOttomNav(
      {this.colorCart, this.colorLabel, Key? key, this.up = false})
      : super(key: key);
  final bool up;
  final Color? colorCart, colorLabel;
  @override
  Widget build(BuildContext context, ref) {
    final animator = useAnimationController(
        lowerBound: -3.sh(),
        upperBound: 3.sh(),
        duration: const Duration(milliseconds: 50));

    return Consumer(builder: (context, ref, c) {
      final status = ref.watch(orderHistoryServiceProvider).statusOrder;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.local_mall_outlined,
            color: colorCart,
          ),
          if (status != 0)
            AnimatedBuilder(
                animation: animator,
                builder: (context, w) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 30),
                    right: -5.sw(),
                    top: -5.sh() + animator.value,
                    child: Container(
                        width: 16.sr(),
                        height: 16.sr(),
                        decoration: BoxDecoration(
                            color: colorCart ?? Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              status.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: colorLabel ??
                                          (colorCart != null
                                              ? CustomTheme.primaryColor
                                              : CustomTheme.whiteColor)),
                            ),
                          ),
                        )),
                  );
                })
        ],
      );
    });
  }
}
