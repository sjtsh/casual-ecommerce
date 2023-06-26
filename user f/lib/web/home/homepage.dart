import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/home/components/FeaturedBox.dart';
import 'package:ezdeliver/screen/home/components/trendingBox.dart/trendingBox.dart';
import 'package:ezdeliver/screen/home/home.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/web/template/web_page_template.dart';

// ignore: must_be_immutable
class HomePage extends WebPageTemplate {
  HomePage(
    Size size, {
    super.key,
  }) : super(size: size) {
    children = [
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Container(
            margin: margin,
            child: const AspectRatio(
                aspectRatio: 3,
                child: HomeBanner(
                  scale: 1,
                )),
          ),
        ),
      ),
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, child) {
              final categories =
                  ref.watch(productCategoryServiceProvider).category;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        (!BreakPoint.isMobile ? .225 : .3),
                    child: ItemBox(
                      viewALl: Container(),
                      favourite: "Browse by Category",
                      items: categories ?? [],
                      isLoading: categories == null,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Consumer(builder: (context, ref, c) {
            final products =
                ref.watch(productCategoryServiceProvider).trendingProducts;
            return Container(
              margin: margin,
              height: MediaQuery.of(context).size.height *
                  (!BreakPoint.isMobile ? .35 : .4),
              child: TrendingGrid(
                  crossAxisCount: 1,
                  loading: products == null,
                  products: products ??
                      List.generate(
                        30,
                        (index) => Product.empty(),
                      )),
            );
          }),
        ),
      ),
    ];
  }
}
