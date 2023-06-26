import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/home/components/trendingBox.dart/trendingBox.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/models/subCategoyProductList.dart';
import 'package:ezdeliver/screen/order/subcategoryproductbox.dart';

List<Widget> productsWithSubCategory(
    {required List<SubCategoyProduct>? productWithSubCategory,
    required BoxConstraints constraints,
    required WidgetRef ref}) {
  final leftPadding = 20.sw();
  int length = 4;

  final isLoadingMore =
      ref.watch(productCategoryServiceProvider).loadingMoreSubCategories;
  if (productWithSubCategory != null) {
    if (productWithSubCategory.isNotEmpty) {
      length = isLoadingMore
          ? productWithSubCategory.length + 1
          : productWithSubCategory.length;
    }
  }

  double height = ResponsiveLayout.isMobile
      ? constraints.maxHeight * 0.82
      : constraints.maxHeight * 0.82 / 2;

  return List.generate(length, (index) {
    return isLoadingMore && index == length - 1
        ? SliverToBoxAdapter(
            child: Center(
              child: Transform.scale(
                  scale: 0.8,
                  child: CircularProgressIndicator(
                    color: CustomTheme.primaryColor,
                  )),
            ),
          )
        : SliverToBoxAdapter(
            child: SizedBox(
              height: productWithSubCategory == null
                  ? height
                  : productWithSubCategory.isEmpty
                      ? height
                      : productWithSubCategory[index].products.length <= 2
                          ? constraints.maxHeight * 0.82 / 2
                          : height,
              child: LayoutBuilder(builder: (context, c) {
                // if()
                // SubCategoyProduct p = productWithSubCategory[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: leftPadding,
                        right: leftPadding,
                      ),
                      child: Row(
                        children: [
                          productWithSubCategory == null
                              ? customShimmer(
                                  width: 80.sw(),
                                  height: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .fontSize!
                                      .ssp())
                              : productWithSubCategory.isEmpty
                                  ? customShimmer(width: 80.sw())
                                  : Text(
                                      productWithSubCategory[index].name,
                                      style: responsiveTextStyle(
                                        Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              fontWeight:
                                                  UniversalPlatform.isAndroid
                                                      ? kTextStyleInterRegular
                                                          .fontWeight
                                                      : FontWeight.w500,
                                            ),
                                      ),
                                    ),
                          const Spacer(),
                          productWithSubCategory != null
                              ? productWithSubCategory.isEmpty
                                  ? customShimmer(width: 40.sw())
                                  : GestureDetector(
                                      onTap: () {
                                        var subCategory = SubCategory(
                                            id: productWithSubCategory[index]
                                                .id,
                                            name: productWithSubCategory[index]
                                                .name,
                                            image: productWithSubCategory[index]
                                                .image,
                                            category:
                                                productWithSubCategory[index]
                                                    .category,
                                            categoryId: "");
                                        CustomKeys.ref
                                            .read(
                                                productCategoryServiceProvider)
                                            .selectSubCategory(subCategory);
                                        if (!ResponsiveLayout.isMobile) {
                                          ref
                                                  .read(statelistProvider)
                                                  .holderwidget =
                                              SubCategoryProductScreen(
                                                  item: Category(
                                                      id: productWithSubCategory[
                                                              index]
                                                          .category,
                                                      name: productWithSubCategory[index].name,
                                                      image: "",
                                                      categoryId: ""),
                                                  subCategories: [subCategory]);
                                          return;
                                        }
                                        Utilities.pushPage(
                                            SubCategoryProductScreen(
                                                item: Category(
                                                    id: productWithSubCategory[
                                                            index]
                                                        .category,
                                                    name:
                                                        productWithSubCategory[
                                                                index]
                                                            .name,
                                                    image: "",
                                                    categoryId: ""),
                                                subCategories: [subCategory]),
                                            10);
                                      },
                                      child: Text(
                                        "View All",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                      ),
                                    )
                              : customShimmer(width: 40.sw()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomTrendingBoxList(
                          scroll: true,
                          loading: productWithSubCategory == null,
                          products: productWithSubCategory == null
                              ? null
                              : productWithSubCategory.isEmpty
                                  ? null
                                  : productWithSubCategory[index].products,
                          crossAxisCount: productWithSubCategory == null
                              ? ResponsiveLayout.isMobile
                                  ? 2
                                  : 1
                              : productWithSubCategory.isEmpty
                                  ? ResponsiveLayout.isMobile
                                      ? 2
                                      : 1
                                  : productWithSubCategory[index]
                                              .products
                                              .length <=
                                          2
                                      ? 1
                                      : ResponsiveLayout.isMobile
                                          ? 2
                                          : 1),
                    ),
                    SizedBox(
                      height: 20.sh(),
                    )
                  ],
                );
              }),
            ),
          );
  }).toList();
}
