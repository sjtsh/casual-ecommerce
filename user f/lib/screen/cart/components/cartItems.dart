import 'package:ezdeliver/screen/cart/components/itemQuantity.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/products/productDetails/productDetails.dart';

class CartItems extends ConsumerWidget {
  const CartItems({Key? key, this.notifier, this.cart = false})
      : super(key: key);
  final ChangeNotifierProvider<CartService>? notifier;
  final bool cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(notifier ?? notifier ?? cartServiceProvider).cartItems;

    final subcategories = ref.watch(productCategoryServiceProvider).subCategory;

    return AnimatedSwitcher(
        duration: widgetSwitchAnimationDuration,
        child: items.isEmpty
            ? Center(
                child: InfoMessage.emptyCart(),
              )
            : ListView.separated(
                padding: EdgeInsets.symmetric(
                    horizontal: 22.sw(), vertical: 10.sh()),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 30.sh(),
                  );
                },
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var availableFromSubCatgory = ref
                      .read(notifier ?? cartServiceProvider)
                      .checkItemsForAvail(
                        index: index,
                        items: items,
                        subcategories: subcategories,
                      );

                  return ProductItems(
                    cart: cart,
                    notAvailable: (availableFromSubCatgory == null &&
                            !items[index].product.deactivated)
                        ? null
                        : true,
                    item: items[index],
                    notifier: notifier,
                  );
                }));
  }
}

class ProductItems extends ConsumerWidget {
  const ProductItems({
    this.cart = false,
    Key? key,
    required this.item,
    this.showImage = true,
    this.feedBackItems,
    this.isOrderDetail = false,
    this.notAvailable,
    this.notifier,
  }) : super(key: key);

  final OrderItem item;

  final OrderItem? feedBackItems;

  final bool cart;
  final bool isOrderDetail;
  final bool? notAvailable;
  final bool showImage;
  final ChangeNotifierProvider<CartService>? notifier;

  @override
  Widget build(BuildContext context, ref) {
    // final globalKey = GlobalKey();

    return Row(
      children: [
        if (showImage) ...[
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                CustomKeys.ref
                    .read(productCategoryServiceProvider)
                    .selectSubCategory(SubCategory(
                        id: item.product.category,
                        name: "",
                        image: "",
                        category: "",
                        categoryId: ""));

                if (!ResponsiveLayout.isMobile) {
                  ref.read(statelistProvider).holderwidget = ProductDetails(
                    product: item.product,
                  );
                  return;
                }
                Utilities.pushPage(
                    ProductDetails(
                      fromCart: true,
                      product: item.product,
                    ),
                    15);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(4, 4),
                            blurRadius: 15,
                            color: CustomTheme.blackColor.withOpacity(0.125))
                      ],
                      borderRadius: BorderRadius.circular(15.sr())),
                  // color: Colors.red,
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: customCachedImage(imageUrl: item.product.image))
                  // CachedNetworkImage(
                  //   key: globalKey,
                  //   imageUrl: item.product.image,
                  // ),
                  ),
            ),
          ),
          SizedBox(
            width: 15.sw(),
          ),
        ],
        Expanded(
          flex: 3,
          child: Container(
            // color: Colors.red,
            padding: EdgeInsets.only(
                top: 3.sh(), left: ResponsiveLayout.isMobile ? 0 : 20.sw()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: kTextStyleInterMedium.copyWith(
                                  color: CustomTheme.getBlackColor(),
                                  fontSize: 15.ssp(),
                                )),
                          ),
                          // Container(
                          //     decoration: BoxDecoration(
                          //         color:
                          //             Theme.of(context).scaffoldBackgroundColor,
                          //         boxShadow: [
                          //           BoxShadow(
                          //               blurRadius: 2,
                          //               spreadRadius: 2,
                          //               color: Colors.black.withOpacity(0.3))
                          //         ],
                          //         shape: BoxShape.circle),
                          //     child: Icon(Icons.close_sharp))
                        ],
                      ),
                    ),
                    if (!isOrderDetail) ...[
                      SizedBox(
                        width: 10.sw(),
                      ),
                      Text(
                          '${item.product.sku % 1 != 0 ? "${item.product.sku.toInt()} ${item.product.unit}" : ""} ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: kTextStyleInterMedium.copyWith(
                            fontSize: 15.ssp(),
                            color: CustomTheme.primaryColor,
                          ))
                    ] else if (!cart) ...[
                      SizedBox(
                        width: 20.sw(),
                      ),
                      if (notAvailable != null)
                        notAvailable!
                            ? Text(
                                "Unavailable ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontSize: 13.ssp(),
                                        fontWeight: FontWeight.w600,
                                        color: CustomTheme.errorColor),
                              )
                            : Row(
                                children: [
                                  if (item.itemCount !=
                                      item.product.oldCount) ...[
                                    itemCount(context,
                                        value: item.itemCount, old: true),
                                    SizedBox(
                                      width: 10.sw(),
                                    ),
                                  ],
                                  itemCount(context,
                                      value: item.product.oldCount),
                                ],
                              )
                      else
                        itemCount(context,
                            value: feedBackItems != null
                                ? feedBackItems!.itemCount
                                : item.itemCount)
                    ]
                  ],
                ),
                SizedBox(
                  height: cart
                      ? showImage
                          ? 3.sh()
                          : 12.sh()
                      : 12.sh(),
                ),
                // if (isOrderDetail)
                if (!cart && notAvailable != null) ...[
                  if (!notAvailable!)
                    Builder(builder: (context) {
                      // final labelStyle = Theme.of(context)
                      //     .textTheme
                      //     .bodyText1!
                      //     .copyWith(color: CustomTheme.greyColor);
                      return Row(
                        children: [
                          const Spacer(),
                          // Text(
                          //   "Before: ",
                          //   style: labelStyle,
                          // ),
                          priceText(context,
                              value: item.product.price * item.itemCount,
                              old: true),
                          SizedBox(
                            width: 10.sw(),
                          ),
                          // Spacer(),
                          // Text(
                          //   "Updated: ",
                          //   style: labelStyle,
                          // ),
                          priceText(context, value: (item.product.oldPrice))
                        ],
                      );
                    }),
                ],
                if (isOrderDetail)
                  if (!cart && notAvailable == null)
                    Row(
                      children: [
                        // Text(
                        //   "${item.product.weight}",
                        //   style: kTextStyleInterMedium.copyWith(
                        //       fontSize: 13.ssp(), color: CustomTheme.greyColor),
                        // ),
                        const Spacer(),
                        priceText(context,
                            value: feedBackItems != null
                                ? (feedBackItems!.total ~/
                                    feedBackItems!.itemCount)
                                : item.product.price),
                      ],
                    ),
                SizedBox(
                  height: 0.sh(),
                ),
                if (!isOrderDetail) ...[
                  Row(
                    children: [
                      // Text("Rs. ${item.product.price}",
                      //     maxLines: 2,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: kTextStyleInterMedium.copyWith(
                      //       fontSize: 15.ssp(),
                      //     )),
                      Text("Rs. ${item.product.price}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: kTextStyleInterMedium.copyWith(
                            fontSize: 15.ssp(),
                            color: CustomTheme.primaryColor,
                          )),
                      const Spacer(
                        flex: 1,
                      ),
                      if (ResponsiveLayout.isMobile)
                        Expanded(
                          flex: 2,
                          child: ItemQuantityWidget(
                              cart: cart,
                              product: item.product,
                              notifier: notifier,
                              notAvailable: notAvailable),
                        )
                    ],
                  ),
                  if (!ResponsiveLayout.isMobile) ...[
                    SizedBox(
                      height: 20.sh(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ItemQuantityWidget(
                              cart: cart,
                              product: item.product,
                              notifier: notifier,
                              notAvailable: notAvailable),
                        ),
                        const Spacer()
                      ],
                    ),
                  ]
                ]
              ],
            ),
          ),
        ),

        // else ...[
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //     decoration: BoxDecoration(
        //       color: CustomTheme.whiteColor,
        //       borderRadius: BorderRadius.circular(8.sr()),
        //     ),
        //     child: Text(
        //       item.itemCount.toString(),
        //       style: Theme.of(context)
        //           .textTheme
        //           .bodyText2!
        //           .copyWith(fontSize: 14.ssp(), color: Colors.white),
        //     ),
        //   ),
        //   if (order != null && order!.feedback != null) ...[
        //     Text(" / "),
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //       decoration: BoxDecoration(
        //         color: CustomTheme.greyColor,
        //         borderRadius: BorderRadius.circular(8.sr()),
        //       ),
        //       child: Text(
        //         feedbackOrderItem.itemCount.toString(),
        //         style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //             fontSize: 14.ssp(),
        //             color: feedbackOrderItem.itemCount == 0
        //                 ? CustomTheme.errorColor
        //                 : Colors.white),
        //       ),
        //     ),
        //   ],
        //   Spacer(),
        // ],
        // Expanded(
        //   child: Column(
        //     children: [
        //       Text(
        //         "Rs. ${item.product.price + 20}",
        //         maxLines: 1,
        //         style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //             decoration: TextDecoration.lineThrough, fontSize: 12.ssp()),
        //       ),
        //       Text(
        //         "Rs. ${item.product.price}",
        //         maxLines: 1,
        //         style: Theme.of(context)
        //             .textTheme
        //             .bodyText2!
        //             .copyWith(fontSize: 12.ssp(), fontWeight: FontWeight.w600),
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }

  Text itemCount(BuildContext context, {required int value, bool old = false}) {
    return Text(
      value.toString(),
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
          color: old ? CustomTheme.greyColor : Theme.of(context).primaryColor,
          decoration: old ? TextDecoration.lineThrough : null,
          fontSize: 13.ssp(),
          fontWeight: FontWeight.w600),
    );
  }

  Text priceText(BuildContext context, {required int value, bool old = false}) {
    return Text("Rs.$value",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: kTextStyleInterMedium.copyWith(
            fontSize: 15.ssp(),
            decoration: old ? TextDecoration.lineThrough : null,
            color:
                old ? CustomTheme.greyColor : Theme.of(context).primaryColor));
  }
}

class ItemQuantityWidget extends ConsumerWidget {
  const ItemQuantityWidget(
      {super.key,
      required this.product,
      this.notifier,
      required this.notAvailable,
      this.primary = true,
      this.cart = false});

  final Product product;
  final ChangeNotifierProvider<CartService>? notifier;

  final bool? notAvailable;
  final bool primary;
  final bool cart;

  @override
  Widget build(BuildContext context, ref) {
    final cartService = ref.watch(notifier ?? cartServiceProvider);
    final itemCount = cartService.checkItemIsInCart(product);
    final item = OrderItem(itemCount: itemCount, product: product);
    int index = cartService.cartItems
        .indexWhere((element) => element.product.id == product.id);
    // print(itemCount);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: widgetSwitchAnimationDuration,
            opacity: notAvailable != null
                ? 0
                : item.itemCount > 0
                    ? 0
                    : 1,
            child: primary
                ? CustomElevatedButton(
                    onPressedElevated: () async {
                      ref
                          .read(notifier ?? cartServiceProvider)
                          .addItem(item.product, inside: true);
                    },
                    elevatedButtonText: "Add to Cart",
                    color: Theme.of(context).primaryColor,
                  )
                : Stack(
                    children: [
                      Opacity(
                        opacity: 0,
                        child: ItemQuantity(
                          cart: cart,
                          custom: primary,
                          cartService: notifier != null
                              ? ref.read(notifier!)
                              : cartService,
                          item: item,
                          index: index,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomOutlinedButton(
                          custom: true,
                          outlinedButtonText: "Add",
                          onPressedOutlined: () {
                            ref
                                .read(notifier ?? cartServiceProvider)
                                .addItem(item.product, inside: true);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (item.itemCount > 0)
          Positioned(
            child: Container(
              color: Colors.transparent,
              child: ItemQuantity(
                cart: cart,
                custom: primary,
                cartService:
                    notifier != null ? ref.read(notifier!) : cartService,
                item: item,
                index: index,
              ),
            ),
          ),
        if (notAvailable != null)
          Positioned.fill(
            child: Container(
              // transformAlignment: Alignment.centerRight,
              // color: Colors.blue,
              color: Theme.of(context).scaffoldBackgroundColor,
              // alignment: Alignment.center,

              // width: double.infinity,
              // height: double.infinity,
              child: Tooltip(
                showDuration: const Duration(seconds: 2),
                triggerMode: TooltipTriggerMode.tap,
                message: "This product is currently unavailable in your area.",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Unavailable ",
                        style: kTextStyleInterMedium.copyWith(
                          fontSize: 15.ssp(),
                          color: CustomTheme.greyColor,
                        )),
                    const Icon(
                      Icons.info,
                      color: CustomTheme.errorColor,
                      size: 16,
                    )
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
}
