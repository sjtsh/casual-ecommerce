import 'dart:developer';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/favourite/favourite.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/home/components/FeaturedBox.dart';
import 'package:ezdeliver/screen/home/components/suggestProduct.dart';
import 'package:ezdeliver/screen/home/components/trendingBox.dart/trendingBox.dart';
import 'package:ezdeliver/screen/home/productswithsubcategory.dart';
import 'package:ezdeliver/screen/products/components/bannerSlider.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

class Home extends ConsumerWidget {
  const Home({super.key, required this.scrollController});

  final ScrollController scrollController;

  // animate() {
  //   scrollController.animateTo(0,
  //       duration: widgetSwitchAnimationDuration, curve: Curves.easeInOut);
  // }

  @override
  Widget build(BuildContext context, ref) {
    final categories = ref.watch(productCategoryServiceProvider).category;
    // categories = null;
    final productFromSubCategories =
        ref.watch(productCategoryServiceProvider).productFromSubCategories;

    final user = ref.watch(userChangeProvider).loggedInUser.value;

    final favourite = user?.favourites;
    const duration = 300;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            if (ResponsiveLayout.isMobile)
              CustomAppBar(
                scrollController: scrollController,
              ),
            Expanded(
              child: ref.watch(locationServiceProvider).currentAddress ==
                          null &&
                      ref.watch(locationServiceProvider).permissionEnums !=
                          LocationPermissionEnums.always
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: 15.sr(), right: 15.sr(), top: 15.sr()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InfoMessage.noLocation(),
                          SizedBox(
                            height: 10.sh(),
                          ),
                          CustomElevatedButton(
                              onPressedElevated: () {
                                Utilities.pushPage(const YourLocation(), 15);
                              },
                              elevatedButtonText:
                                  "Grant location or choose Address")
                        ],
                      ))
                  : LayoutBuilder(builder: (context, constraints) {
                      return RefreshIndicator(
                          color: Theme.of(context).primaryColor,
                          onRefresh: () async {
                            // ref.read(customSocketProvider).refreshAuth(
                            //     ref.read(userChangeProvider).loggedInUser.value!.accessToken!);

                            await ref
                                .read(productCategoryServiceProvider)
                                .fetchCategories();
                            await ref
                                .read(productCategoryServiceProvider)
                                .fetchTrendingProducts();
                            await ref
                                .read(productCategoryServiceProvider)
                                .fetchAllSubCategoriesWithProducts(clear: true);
                            await ref
                                .read(productCategoryServiceProvider)
                                .fetchHomeBanners();
                          },
                          child: AnimatedSwitcher(
                            duration: widgetSwitchAnimationDuration,
                            child: categories == null
                                ? AnimatedSwitcher(
                                    duration: widgetSwitchAnimationDuration,
                                    child: Api.hasInternet
                                        ? CustomScrollView(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            // mainAxisAlignment: MainAxisAlignment.center,
                                            slivers: [
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20.sw()),
                                                  child: const HomeBanner(),
                                                ),
                                              ),
                                              SliverToBoxAdapter(
                                                child: SizedBox(
                                                    height:
                                                        constraints.maxHeight *
                                                            0.8,
                                                    child: const TrendingGrid(
                                                        scroll: false,
                                                        loading: true,
                                                        products: [])

                                                    // CustomTrendingBoxList(
                                                    //   scroll: false,
                                                    //   products: null,
                                                    //   loading: true,
                                                    // ),
                                                    ),
                                              )
                                              // Expanded(
                                              //   flex: 2,
                                              //   child: Padding(
                                              //     padding: EdgeInsets.only(
                                              //         left: 40.sr(),
                                              //         right: 40.sr(),
                                              //         bottom: 60.sr()),
                                              //     child: customShimmer(
                                              //         width: double.infinity),
                                              //   ),
                                              // ),
                                              // // SizedBox(
                                              // //   height: 18.sh(),
                                              // // ),
                                              // Expanded(
                                              //   flex: 3,
                                              //   child: SizedBox(
                                              //     height: constraints.maxHeight * 0.82,
                                              //     child: TrendingGrid(
                                              //         crossAxisCount: 2,
                                              //         products: List.generate(6,
                                              //             (index) => Product.empty())),
                                              //   ),
                                              // )
                                            ],
                                          )
                                        : Center(
                                            child: InfoMessage.noInternet(),
                                          ),
                                  )
                                : categories.isEmpty
                                    ? ListView(
                                        children: [
                                          SizedBox(
                                            height: constraints.maxHeight / 3,
                                          ),
                                          Center(
                                            child:
                                                InfoMessage.outOfServiceArea(),
                                          ),
                                        ],
                                      )
                                    : CustomScrollView(
                                        controller: scrollController,
                                        slivers: [
                                          SliverToBoxAdapter(
                                            child: const HomeBanner(),
                                          ),
                                          // SliverToBoxAdapter(
                                          //   child: SizedBox(
                                          //     height: 12.sh(),
                                          //   ),
                                          // ),

                                          // SizedBox(
                                          //   height: constraints.maxHeight * .8,
                                          //   child: ItemBox(
                                          //     trending: true,
                                          //     items: products,
                                          //   ),
                                          // ),
                                          SliverToBoxAdapter(
                                            child: Builder(builder: (context) {
                                              final products = ref
                                                  .watch(
                                                      productCategoryServiceProvider)
                                                  .trendingProducts;
                                              // print(" here  ${products!.first.id}");

                                              if (products != null) {
                                                // print(products.length);
                                                if (products.isEmpty) {
                                                  return Container();
                                                }
                                              } else {
                                                return Container();
                                              }
                                              return SizedBox(
                                                  height: products.length <= 2
                                                      ? constraints.maxHeight *
                                                          0.90 /
                                                          2
                                                      : constraints.maxHeight *
                                                          0.82,
                                                  child: TrendingGrid(
                                                    crossAxisCount:
                                                        products.length <= 2
                                                            ? 1
                                                            : 2,
                                                    products: products,
                                                    loading: false,
                                                  ));
                                            }),
                                          ),
                                          // SliverToBoxAdapter(
                                          //   child: SizedBox(
                                          //     height: 30.sh(),
                                          //   ),
                                          // ),
                                          if (favourite != null)
                                            SliverToBoxAdapter(
                                              child: AnimatedSize(
                                                duration: const Duration(
                                                    milliseconds: duration),
                                                child: SizedBox(
                                                  height: favourite
                                                          .products.isEmpty
                                                      ? 0
                                                      : constraints.maxHeight *
                                                          .45,
                                                  child: ItemBox(
                                                    isLoading: false,
                                                    favourite:
                                                        "Favourite Products",
                                                    viewALl:
                                                        const FavouriteScreen(),
                                                    items: favourite.products,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SliverToBoxAdapter(
                                            child: SizedBox(
                                              height: 30.sh(),
                                            ),
                                          ),
                                          if (favourite != null)
                                            SliverToBoxAdapter(
                                              child: AnimatedSize(
                                                duration: const Duration(
                                                    milliseconds: duration),
                                                child: SizedBox(
                                                  height: favourite
                                                          .categories.isEmpty
                                                      ? 0
                                                      : favourite.products
                                                              .isNotEmpty
                                                          ? constraints
                                                                  .maxHeight *
                                                              0.32
                                                          : constraints
                                                                  .maxHeight *
                                                              0.32,
                                                  child: ItemBox(
                                                    trending: false,
                                                    isLoading: false,
                                                    favourite:

                                                        //  favourite.products.isNotEmpty
                                                        //     ? "Categories"
                                                        "Favourite Categories",
                                                    viewALl:
                                                        const FavouriteScreen(),
                                                    items: favourite.categories,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // List.generate(length, (index) => null),
                                          if (favourite != null)
                                            if (favourite.categories.isNotEmpty)
                                              SliverToBoxAdapter(
                                                child: SizedBox(
                                                  height: 30.sh(),
                                                ),
                                              ),

                                          ...productsWithSubCategory(
                                              constraints: constraints,
                                              productWithSubCategory:
                                                  productFromSubCategories,
                                              ref: ref),
                                          // productsWithSubCategory(
                                          //     constraints: constraints,
                                          //     productWithSubCategory:
                                          //         productFromSubCategories),
                                          // SliverToBoxAdapter(
                                          //   child: productFromSubCategories.isNotEmpty
                                          //       ? ProductsWithSubCategory(
                                          //           productWithSubCategory:
                                          //               productFromSubCategories,
                                          //         )
                                          //       : Container(),
                                          // ),
                                          SliverToBoxAdapter(
                                            child: SizedBox(
                                              height: 30.sh(),
                                            ),
                                          ),
                                          const SliverToBoxAdapter(
                                              child: SuggestProductInfo())
                                        ],
                                      ),
                          ));
                    }),
            )
          ],
        ));
  }
}

class HomeBanner extends ConsumerWidget {
  const HomeBanner({Key? key, this.log = false, this.scale}) : super(key: key);
  final bool log;
  final double? scale;
  @override
  Widget build(BuildContext context, ref) {
    final banners = ref.watch(productCategoryServiceProvider).homeBanners;
    // banners = null;
    if (banners != null) {
      if (banners.isEmpty) return Container();
    } else {
      return Container(
        padding: EdgeInsets.all(8.0.sr()),
        margin: EdgeInsets.only(bottom: 10.sh()),
        child: AspectRatio(
          aspectRatio: ResponsiveLayout.isMobile ? 2 : 4,
          child: customShimmer(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8.0.sr()),
      margin: EdgeInsets.only(bottom: 10.sh()),
      child: Transform.scale(
        scale: 1,
        // scale: scale ?? 0.88,
        // height: constraints.maxHeight * .3,
        child: GestureDetector(
          onTap: () async {
            if (log) {
              await FirebaseAnalytics.instance
                  .logEvent(name: "Front_banner", parameters: {
                "id": ref.read(userChangeProvider).loggedInUser.value?.id,
                "name": ref.read(userChangeProvider).loggedInUser.value?.name
              });
            }
          },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12.sr()),
              child: AspectRatio(
                aspectRatio: ResponsiveLayout.isMobile ? 2 : 4,
                child: BannerSlider(
                  autoScroll: true,
                  banners: banners,
                ),
              )),
        ),

        //  ItemBox(
        //   // trending: true,
        //   items: products,
        // ),
      ),
    );
  }
}
