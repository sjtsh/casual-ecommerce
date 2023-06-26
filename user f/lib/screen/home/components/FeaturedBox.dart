import 'package:ezdeliver/screen/category/component/categoryBox.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/products/components/productbox.dart';

class ItemBox<T> extends StatelessWidget {
  ItemBox(
      {super.key,
      required this.items,
      this.trending = false,
      this.showText = true,
      this.isLoading = true,
      this.favourite,
      this.viewALl,
      this.clearPrevious = false});
  final List<T>? items;

  final bool trending;
  final bool showText;
  final bool isLoading;
  String? favourite;
  final Widget? viewALl;
  final bool clearPrevious;
  final ScrollController controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    bool isProduct = true;
    if (items!.isNotEmpty) {
      isProduct = items is List<Product>;
    }
    final leftPadding = 20.sw();

    // print(favourite);
    return Container(
      margin: EdgeInsets.only(top: 6.sh()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: leftPadding, right: leftPadding),
            child: Row(
              children: [
                if (showText)
                  Text(
                    favourite != null
                        ? favourite!
                        : ("${trending ? isProduct ? "Trending" : "" : "Featured"} ${isProduct ? "Products" : "Categories"}"),
                    style: responsiveTextStyle(
                        Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: UniversalPlatform.isAndroid
                                  ? kTextStyleInterRegular.fontWeight
                                  : FontWeight.w500,
                            )),
                  ),
                if (viewALl != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (ResponsiveLayout.isMobile) {
                        Utilities.pushPage(viewALl!, 10);
                      } else {
                        ResponsiveLayout.setHolderWidget(viewALl);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Text(
                        "View All",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
          SizedBox(
            height: 10.sh(),
          ),
          Expanded(
            child: !isLoading && items!.isEmpty
                ? Center(
                    child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 220.sh()),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: InfoMessage.noSimilarProducts(),
                    ),
                  ))
                : Builder(builder: (context) {
                    int length = 6;
                    if (!isLoading) {
                      length = items!.length;
                    }
                    return Stack(
                      children: [
                        GridView.builder(
                            // physics: !UniversalPlatform.isAndroid
                            //     ? const PageScrollPhysics()
                            //     : null,
                            controller: controller,
                            padding: EdgeInsets.only(
                                left: leftPadding,
                                right: leftPadding,
                                top: 15.sh(),
                                bottom: 20.sh()),
                            gridDelegate: trending
                                ? SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: ResponsiveLayout.isMobile
                                        ? isProduct
                                            ? 2
                                            : 3
                                        : favourite != null
                                            ? 3
                                            : 6,
                                    mainAxisSpacing: 20.sh(),
                                    crossAxisSpacing: 20.sw(),
                                    childAspectRatio: ResponsiveLayout.isMobile
                                        ? !isProduct
                                            ? 0.72
                                            : 0.75
                                        : 1)
                                : SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    // maxCrossAxisExtent:
                                    //     (MediaQuery.of(context).size.width - 20.sw()) /
                                    //         1.85,
                                    crossAxisSpacing: 20.sw(),
                                    mainAxisSpacing: 20.sw(),
                                    childAspectRatio: !isProduct ? 1 : 1.4),
                            scrollDirection:
                                trending ? Axis.vertical : Axis.horizontal,
                            itemBuilder: (context, index) {
                              if (!isProduct) {
                                return CategoryBox(
                                    isLoading: isLoading,
                                    small: ResponsiveLayout.isMobile
                                        ? favourite != null
                                            ? true
                                            : trending
                                        : false,
                                    item: items![index] as Category);
                              } else {
                                return LayoutBuilder(
                                    builder: (context, constraint) {
                                  return ProductBox(
                                    loading: isLoading,
                                    clearPrevious: clearPrevious,
                                    product: isLoading
                                        ? null
                                        : items![index] as Product,
                                  );
                                });
                              }
                            },
                            itemCount: length),
                        // IconButton(
                        //     onPressed: () {
                        //       // controller.
                        //     },
                        //     icon: Icon(Icons.arrow_back_ios))
                      ],
                    );
                  }),
          )
        ],
      ),
    );
  }
}
