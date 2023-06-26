import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezdeliver/screen/cart/components/cartItems.dart';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/cartAnimation.dart';

import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';

import 'package:ezdeliver/screen/products/productDetails/productDetails.dart';
import 'package:ezdeliver/services/favouriteAnimation.dart';
import 'package:substring_highlight/substring_highlight.dart';

class ProductBox extends HookConsumerWidget {
  ProductBox(
      {super.key,
      required this.product,
      this.loading = false,
      this.onAddToCart,
      this.up = true,
      this.clearPrevious = false,
      this.query});
  final Product? product;
  final bool loading;
  final Function? onAddToCart;
  final bool up;
  final bool clearPrevious;
  final String? query;
  final hoverProvider = StateProvider<bool>((ref) {
    return false;
  });
  @override
  Widget build(BuildContext context, ref) {
    // final globalKey = GlobalKey();
    final animation =
        useAnimationController(duration: widgetSwitchAnimationDuration);
    // final addToCartAnimation = useAnimationController(
    //   duration: widgetSwitchAnimationDuration,
    //   initialValue: 1,
    //   lowerBound: 0.8,
    // );
    final isHovered = ref.watch(hoverProvider);
    return LayoutBuilder(builder: (context, constraint) {
      return MouseRegion(
        onExit: (event) {
          ref.read(hoverProvider.state).state = false;
        },
        onEnter: (event) {
          ref.read(hoverProvider.state).state = true;
        },
        child: Container(
          padding:
              EdgeInsets.only(bottom: 10.sr(), left: 10.sr(), right: 10.sr()),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.sr()),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                if (!loading)
                  BoxShadow(
                      offset: const Offset(4, 4),
                      blurRadius: 15,
                      spreadRadius: 8,
                      color: CustomTheme.getBlackColor().withOpacity(0.05))
              ]),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () async {
                    var favourite = product!.favourite;
                    await ref
                        .read(productCategoryServiceProvider)
                        .productToFavourite(product!, context);
                    AnimationCollection.animateFavourite(favourite,
                        animation: animation);
                  },
                  onTap: () {
                    if (!loading) {
                      try {
                        var subCategory = ref
                            .read(productCategoryServiceProvider)
                            .subCategory
                            .firstWhere(
                              (element) => element.id == product?.category,
                            );
                        ref
                            .read(productCategoryServiceProvider)
                            .selectSubCategory(subCategory);

                        if (!ResponsiveLayout.isMobile) {
                          ref.read(statelistProvider).holderwidget =
                              ProductDetails(
                            product: product,
                          );
                          return;
                        }

                        if (clearPrevious) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ProductDetails(
                                  product: product,
                                );
                              },
                            ),
                          );
                        } else {
                          FocusScope.of(context).unfocus();
                          Utilities.pushPage(
                              ProductDetails(
                                product: product,
                              ),
                              10,
                              id: product!.name);
                        }
                      } catch (e) {
                        //
                      }
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !loading
                          ? Expanded(
                              child: AnimatedContainer(
                                  // constraints: BoxConstraints(
                                  //   // minWidth: 250.sw(),
                                  //   // minHeight: 250.sh(),
                                  //   maxHeight: 300.sh(),
                                  //   // maxWidth: 300.sw()
                                  // ),
                                  duration: widgetSwitchAnimationDuration,
                                  // constraints:
                                  //     BoxConstraints(minHeight: 126.sh(), minWidth: 126.sw()),
                                  clipBehavior: Clip.hardEdge,
                                  padding: EdgeInsets.all(10.sr()),
                                  // width: 100.sw(),
                                  // height: 200.sh(),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(15.sr()),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    // boxShadow: [
                                    // if (!loading)
                                    //   BoxShadow(
                                    //       offset: const Offset(4, 4),
                                    //       blurRadius: 15,
                                    //       color: CustomTheme.getBlackColor()
                                    //           .withOpacity(isHovered ? 0.1 : 0.055))
                                    // ],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: FavouriteAnimator(
                                          animation: animation,
                                          child: Center(
                                              child: AnimatedScale(
                                                  duration:
                                                      widgetSwitchAnimationDuration,
                                                  scale: isHovered ? 1.1 : 0.9,
                                                  child: customCachedImage(
                                                      imageUrl: product!.image,
                                                      scale: 0.5))),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: AnimatedOpacity(
                                          duration:
                                              widgetSwitchAnimationDuration,
                                          opacity: product!.favourite ? 1 : 0,
                                          child: InkWell(
                                            onTap: () {
                                              ref
                                                  .read(
                                                      productCategoryServiceProvider)
                                                  .productToFavourite(
                                                      product!, context);
                                            },
                                            child: FittedBox(
                                              child: Icon(
                                                product!.favourite
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_outlined,
                                                size: 20.sr(),
                                                color: CustomTheme.primaryColor
                                                    .withOpacity(0.65),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: customShimmer(
                                  width: 100.sw(), height: 100.sh(),
                                  // shape: BoxShape.circle,
                                  // radius: 80.sr(),
                                ),
                              ),
                            ),
                      // SizedBox(height: 13.sh()),

                      !loading
                          ? Stack(
                              children: [
                                const Text("\n\n"),
                                Builder(builder: (context) {
                                  final style = kTextStyleInterMedium.copyWith(
                                      fontSize: 14.ssp(),
                                      fontWeight: isHovered
                                          ? FontWeight.w600
                                          : kTextStyleInterMedium.fontWeight,
                                      color: isHovered
                                          ? CustomTheme.primaryColor
                                          : CustomTheme.getBlackColor());
                                  // return Text("");
                                  return SubstringHighlight(
                                    text: product!.name,
                                    term: query ?? '',
                                    maxLines: 2,
                                    textStyle: style,
                                    textStyleHighlight: style.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.amber[900],
                                        fontWeight: FontWeight.w600),
                                  );
                                }),
                              ],
                            )
                          : Column(
                              children: [
                                const Text("\n"),
                                customShimmer(width: double.infinity),
                              ],
                            ),
                      // SizedBox(
                      //   height: 8.sh(),
                      // ),
                      // !loading
                      //     ? Text("${product!.weight}",
                      //         maxLines: 1,
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .bodyText2!
                      //             .copyWith(color: CustomTheme.greyColor))
                      //     : customShimmer(),
                      SizedBox(
                        height: 8.sh(),
                      ),
                      OverflowBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        spacing: 10.sw(),
                        overflowSpacing: 3.sh(),
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          !loading
                              ? Text(
                                  'Rs. ${product!.price}',
                                  maxLines: 1,
                                  style: kTextStyleInterMedium.copyWith(
                                      fontSize: 14.ssp(),
                                      color: CustomTheme.getBlackColor()),
                                )
                              : customShimmer(width: 50.sw()),
                          //Crossed Price
                          // !loading
                          //     ? Text(
                          //         'Rs. ${product!.price + 20}',
                          //         maxLines: 1,
                          //         style: kTextStyleInterMedium.copyWith(
                          //             decoration: TextDecoration.lineThrough,
                          //             fontSize: 11.ssp(),
                          //             color: CustomTheme.greyColor),
                          //       )
                          //     : customShimmer(width: 20.sw()),
                          // SizedBox(
                          //   width: 12.sw(),
                          // ),
                          // const Spacer(),ui
                          if (loading)
                            customShimmer(width: 20.sw())
                          else if (product!.sku != 0 &&
                              product!.unit.isNotEmpty)
                            Text(
                              '${product!.sku % 1 != 0 ? product!.sku : product!.sku.toInt()} ${product!.unit}',
                              maxLines: 1,
                              style: kTextStyleInterMedium.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.ssp(),
                                  color: CustomTheme.getBlackColor()),
                            )
                        ],
                      ),
                      if (loading) ...[
                        SizedBox(
                          height: 12.sh(),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: customShimmer(width: 50.sw()),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12.sh(),
              ),
              if (!loading)
                Builder(builder: (context) {
                  final subCategories =
                      ref.watch(productCategoryServiceProvider).subCategory;
                  var available = true;
                  if (subCategories.indexWhere(
                          (element) => element.id == product!.category) ==
                      -1) available = false;

                  return ItemQuantityWidget(
                      primary: false,
                      product: product!,
                      notAvailable:
                          available && !product!.deactivated ? null : true);
                })
            ],
          ),
        ),
      );
    });
  }

  Builder addSubtract(WidgetRef ref, GlobalKey<State<StatefulWidget>> globalKey,
      AnimationController addToCartAnimation, bool isHovered) {
    return Builder(builder: (context) {
      final subCategories =
          ref.watch(productCategoryServiceProvider).subCategory;
      var available = true;
      if (subCategories
              .indexWhere((element) => element.id == product!.category) ==
          -1) available = false;
      onTap() async {
        if (!up) {
          if (CustomKeys.cartKey.currentContext != null) {
            RenderBox cart = CustomKeys.cartKey.currentContext!
                .findRenderObject() as RenderBox;
            RenderBox item =
                globalKey.currentContext!.findRenderObject() as RenderBox;

            final Offset cartOffset = cart.localToGlobal(Offset.zero);
            final Offset itemOffset = item.localToGlobal(Offset.zero);
            await ref.read(cartAnimationProvider).addToCart(
                SizedBox(
                    height: item.size.height,
                    width: item.size.width,
                    child: CachedNetworkImage(
                      imageUrl: product!.image,
                    )),
                Offset(itemOffset.dx, itemOffset.dy - item.size.height / 2),
                Offset(cartOffset.dx, cartOffset.dy));
          }
        }
        AnimationCollection.animateAddToCart(controller: addToCartAnimation);
        ref.read(cartServiceProvider).addItem(product!);
      }

      // if (isHovered) {
      return Positioned(
        right: -14.sr(),
        bottom: 0,
        child: AnimatedOpacity(
          duration: widgetSwitchAnimationDuration,
          opacity: UniversalPlatform.isAndroid ||
                  UniversalPlatform.isIOS ||
                  !BreakPoint.isDesktop
              ? 1
              : isHovered
                  ? 1
                  : 0,
          child: AnimatedBuilder(
              animation: addToCartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: addToCartAnimation.value,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: !available
                        ? null
                        : () async {
                            onTap();
                          },
                    onDoubleTap: () {
                      if (available) onTap();
                    },
                    child: Container(
                      height: 45.sr(),
                      width: 45.sr(),
                      decoration: const BoxDecoration(
                          color: Colors.transparent, shape: BoxShape.circle),
                      // padding: EdgeInsets.all(10.sr()),
                      alignment: Alignment.center,
                      child: Container(
                        height: 22.sr(),
                        width: 22.sr(),
                        decoration: BoxDecoration(
                            color: available
                                ? Theme.of(context).primaryColor
                                : CustomTheme.greyColor,
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(4, 4),
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.1))
                            ]),
                        child: const FittedBox(
                          child: Icon(
                            GroceliIcon.add,
                            color: CustomTheme.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
      // }
      // else if (UniversalPlatform.isAndroid) {
      //   return Positioned(
      //     right: -14.sr(),
      //     bottom: 0,
      //     child: AnimatedBuilder(
      //         animation: addToCartAnimation,
      //         builder: (context, child) {
      //           return Transform.scale(
      //             scale: addToCartAnimation.value,
      //             child: GestureDetector(
      //               behavior: HitTestBehavior.opaque,
      //               onTap: !available
      //                   ? null
      //                   : () async {
      //                       onTap();
      //                     },
      //               onDoubleTap: () {
      //                 if (available) onTap();
      //               },
      //               child: Container(
      //                 height: 45.sr(),
      //                 width: 45.sr(),
      //                 decoration: const BoxDecoration(
      //                     color: Colors.transparent,
      //                     shape: BoxShape.circle),
      //                 // padding: EdgeInsets.all(10.sr()),
      //                 alignment: Alignment.center,
      //                 child: Container(
      //                   height: 22.sr(),
      //                   width: 22.sr(),
      //                   decoration: BoxDecoration(
      //                       color: available
      //                           ? Theme.of(context)
      //                               .primaryColor
      //                           : CustomTheme.greyColor,
      //                       boxShadow: [
      //                         BoxShadow(
      //                             offset: const Offset(
      //                                 4, 4),
      //                             blurRadius: 5,
      //                             color: Colors.black
      //                                 .withOpacity(0.1))
      //                       ]),
      //                   child: const FittedBox(
      //                     child: Icon(
      //                       GroceliIcon.add,
      //                       color:
      //                           CustomTheme.whiteColor,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           );
      //         }),
      //   );
      // }
    });
  }

  // Widget hilightedQuery(String query, {required String name}) {
  //   String originalString = name;
  //   int startIndex = originalString.indexOf(query);
  //   int endIndex = startIndex + query.length;
  //   String highlightedString = originalString.substring(startIndex, endIndex);

  //   return RichText(
  //     text: TextSpan(
  //       text: originalString,
  //       style: kTextStyleInterRegular,
  //       children: <TextSpan>[
  //         TextSpan(
  //           text: highlightedString,
  //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
