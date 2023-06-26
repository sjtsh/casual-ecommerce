import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/products/components/productbox.dart';

class TrendingGrid extends ConsumerWidget {
  const TrendingGrid(
      {required this.products,
      super.key,
      this.loading = true,
      this.scroll = true,
      this.crossAxisCount});
  final List<Product> products;
  final bool loading, scroll;
  final int? crossAxisCount;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftPadding = 20.sw();

    return LayoutBuilder(builder: (context, constraints) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(left: leftPadding),
          child: Row(
            children: [
              !loading
                  ? Text(
                      "Trending Near You",
                      style: responsiveTextStyle(
                        Theme.of(context).textTheme.headline3!.copyWith(
                              fontWeight: UniversalPlatform.isAndroid
                                  ? kTextStyleInterRegular.fontWeight
                                  : FontWeight.w500,
                            ),
                      ),
                    )
                  : customShimmer(width: 150.sw(), height: 20.sh())

              // if (viewALl != null) ...[
              //   const Spacer(),
              //   GestureDetector(
              //     onTap: () {
              //       Utilities.pushPage(viewALl!, 10);
              //     },
              //     child: Container(
              //       color: Colors.transparent,
              //       child: Text(
              //         "View All",
              //         style: Theme.of(context)
              //             .textTheme
              //             .bodyText2!
              //             .copyWith(decoration: TextDecoration.underline),
              //       ),
              //     ),
              //   )
              // ]
            ],
          ),
        ),
        Expanded(
          child: CustomTrendingBoxList(
            scroll: scroll,
            loading: loading,
            products: products,
            crossAxisCount: crossAxisCount,
          ),
        ),
        // SizedBox(
        //   height: 20.sh(),
        // )
      ]);
    });
  }
}

class CustomTrendingBoxList extends ConsumerWidget {
  const CustomTrendingBoxList({
    super.key,
    required this.products,
    required this.loading,
    this.crossAxisCount,
    this.scroll = true,
  });
  final int? crossAxisCount;

  final List<Product>? products;
  final bool loading, scroll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: scroll ? null : const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      slivers: [
        if (products != null)
          if (products!.isNotEmpty)
            SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: 22.sw(), vertical: 16.sh()),
                sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 22.sw(),
                        crossAxisSpacing: 20.sh(),
                        childAspectRatio: 1.35,
                        crossAxisCount: crossAxisCount ?? 2),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductBox(
                        product: loading
                            ? null
                            : products == null
                                ? null
                                : products![index],
                        loading: loading
                            ? loading
                            : products == null
                                ? true
                                : false,
                        up: true,
                      );
                    },
                        childCount: loading
                            ? 4
                            : products == null
                                ? 4
                                : products!.length))),
      ],
    );
  }
}
