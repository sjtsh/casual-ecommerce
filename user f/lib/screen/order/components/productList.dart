import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/products/components/bannerSlider.dart';
import 'package:ezdeliver/screen/products/components/productbox.dart';

class ProductListDisplay extends ConsumerWidget {
  ProductListDisplay({Key? key}) : super(key: key);
  late final ScrollController scrollController = initScroll();

  ScrollController initScroll() {
    // final productFromSubCategories = ;

    final controller = ScrollController();
    // if (productFromSubCategories != null) {
    controller.addListener(() async {
      if (CustomKeys.ref
              .read(productCategoryServiceProvider)
              .selectedProducts !=
          null) {
        if (CustomKeys.ref
                .read(productCategoryServiceProvider)
                .selectedProducts!
                .length >
            CustomKeys.ref.read(productCategoryServiceProvider).skipOfProduct +
                9) {
          if (controller.position.extentAfter < 10) {
            await CustomKeys.ref
                .read(productCategoryServiceProvider)
                .loadingMoreSubCategoyProDucts();
          }
        }
      }
    });
    // }
    // }

    return controller;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productCategoryServiceProvider).selectedProducts;
    final selectedSubCategory =
        ref.watch(productCategoryServiceProvider).selectedSubCategory;
    final loading = products == null;
    // final padding = 12.sr();
    int length = 6;
    final isLoadingMore = ref
        .watch(productCategoryServiceProvider)
        .loadingMoreSubCategoriesProducts;
    if (products != null) {
      length = isLoadingMore ? products.length + 2 : products.length;
    }

    return LayoutBuilder(builder: (context, constraint) {
      return CustomScrollView(
        controller: scrollController,
        // physics: const BouncingScrollPhysics(),
        slivers: [
          if (selectedSubCategory != null)
            if (selectedSubCategory.banners.isNotEmpty)
              SliverToBoxAdapter(
                child: AspectRatio(
                  aspectRatio: 2,
                  child: BannerSlider(banners: selectedSubCategory.banners),
                ),
              ),
          SliverPadding(
            padding: EdgeInsets.all(10.sr()),
            sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    // crossAxisCount: 2,
                    maxCrossAxisExtent: 126.sw(),
                    mainAxisSpacing: 30.sh(),
                    crossAxisSpacing: 21.sw(),

                    // mainAxisExtent: 200,
                    childAspectRatio: 0.55),
                itemCount: length,
                itemBuilder: (context, index) {
                  return isLoadingMore &&
                          (index == length - 2 || index == length - 1)
                      ? Center(
                          child: Transform.scale(
                              scale: 0.8,
                              child: CircularProgressIndicator(
                                color: CustomTheme.primaryColor,
                              )),
                        )
                      : ProductBox(
                          product: loading ? null : products[index],
                          loading: loading,
                          up: true);
                }),
          )
        ],
      );
    });
  }
}
