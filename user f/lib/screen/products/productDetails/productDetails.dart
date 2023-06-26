import 'package:ezdeliver/screen/cart/components/cartItems.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/home/components/FeaturedBox.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/order/subcategoryproductbox.dart';
import 'package:ezdeliver/screen/products/productDetails/components/productImageSlider.dart';
import 'package:ezdeliver/services/favouriteAnimation.dart';

final productDetailVisibleProvider = StateProvider<bool>((ref) {
  return true;
});

class ProductDetails extends HookConsumerWidget {
  const ProductDetails({super.key, this.product, this.fromCart = false});
  final Product? product;
  final bool fromCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isVisible = ref.watch(productDetailVisibleProvider.state).state;
    final animation =
        useAnimationController(duration: widgetSwitchAnimationDuration);
    // print(product?.image);
    return SafeArea(
        child: Scaffold(
      appBar: ResponsiveLayout.isMobile
          ? simpleAppBar(
              context,
              title: product!.name,
              cart: true,
              fromCart: fromCart,
            )
          : null,
      body: Column(
        children: [
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          if (ResponsiveLayout.isMobile)
            Expanded(
              // height: MediaQuery.of(context).size.height / 3,
              child: Padding(
                padding: EdgeInsets.only(left: 22.sw(), right: 22.sw()),
                child: FavouriteAnimator(
                  animation: animation,
                  child: Consumer(builder: (context, ref, c) {
                    final user =
                        ref.watch(userChangeProvider).loggedInUser.value;
                    final favourites = user?.favourites;
                    final fav = favourites?.products.indexWhere(
                                (element) => element.id == product?.id) ==
                            -1
                        ? false
                        : true;

                    return GestureDetector(
                      onDoubleTap: () {
                        AnimationCollection.animateFavourite(fav,
                            animation: animation);
                        ref
                            .read(productCategoryServiceProvider)
                            .productToFavourite(product!, context,
                                favourite: fav);
                      },
                      child: Stack(
                        children: [
                          ProductImageSlider(
                              images:
                                  List.generate(1, (index) => product!.image)),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Builder(builder: (context) {
                              return AnimatedOpacity(
                                duration: widgetSwitchAnimationDuration,
                                opacity: fav ? 1 : 0,
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(productCategoryServiceProvider)
                                        .productToFavourite(product!, context);
                                  },
                                  child: FittedBox(
                                    child: Icon(
                                      fav
                                          ? Icons.favorite
                                          : Icons.favorite_border_outlined,
                                      size: 30.sr(),
                                      color: CustomTheme.primaryColor
                                          .withOpacity(0.65),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          // Center(
          //     child: CachedNetworkImage(
          //   imageUrl: product!.image,
          //   height: MediaQuery.of(context).size.height / 3,
          // )),
          SizedBox(
            height: 19.sh(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 22.sw(), right: 22.sw()),
            child: Builder(builder: (context) {
              final cartService = ref.watch(cartServiceProvider);
              final itemCOunt = cartService.checkItemIsInCart(product!);
              return ProductItems(
                  showImage: !ResponsiveLayout.isMobile,
                  item: OrderItem(itemCount: itemCOunt, product: product!));
            }),
          ),

          Divider(
            height: 25.sh(),
          ),

          Consumer(builder: (context, ref, child) {
            final products =
                ref.watch(productCategoryServiceProvider).selectedProducts;
            final subcate =
                ref.read(productCategoryServiceProvider).selectedSubCategory;

            List<Product>? finalProducts = products?.toList();
            if (finalProducts != null) {
              finalProducts.removeWhere((element) =>
                  element.id == product!.id ||
                  element.category !=
                      ref
                          .read(productCategoryServiceProvider)
                          .selectedSubCategory
                          ?.id);
            }
            // if (finalProducts.isEmpty) return Expanded(child: Container());
            return Expanded(
              child: SizedBox(
                  // height: constraints.maxHeight * .65,
                  child: ItemBox(
                      isLoading: finalProducts == null,
                      viewALl: SubCategoryProductScreen(
                        item: Category(
                            id: product!.category,
                            name: product!.name,
                            image: "",
                            categoryId: ""),
                        subCategories: [
                          SubCategory(
                              id: product!.category,
                              name: subcate!.name,
                              image: subcate.image,
                              category: subcate.category,
                              categoryId: subcate.categoryId)
                        ],
                      ),
                      clearPrevious: true,
                      favourite: "Similar Products",
                      items: finalProducts ?? [])),
            );
          })
          // Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text("About Product",
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline5!
          //               .copyWith(fontWeight: FontWeight.w500)),
          //       SizedBox(height: 22.sh()),
          //       Expanded(
          //         child: ListView(
          //           children: [
          //             Text(
          //               processString(
          //                 "Lorem Ipsum is simply dummy text of the printing and typesetting m Ipsum.",
          //               ),
          //               style:
          //                   Theme.of(context).textTheme.bodyText2!.copyWith(
          //                         color: CustomTheme.greyColor,
          //                         height: 1.8.ssp(),
          //                       ),
          //             ),
          //           ],
          //         ),
          //       )
          //     ],
          //   ),
          // ),

          // CustomElevatedButton(
          //   onPressedElevated: () {
          //     ref.read(cartServiceProvider).addItem(product!, inside: true);
          //   },
          //   elevatedButtonText: "Add to Cart",
          //   color: Theme.of(context).primaryColor,
          // )
        ],
      ),
    ));
  }

  String processString(String datat) {
    var dataList = datat.split('\r\n');
    for (var i = 0; i < dataList.length; i++) {
      dataList[i] = dataList[i];
    }

    return dataList.join("\r\n");
  }
}
