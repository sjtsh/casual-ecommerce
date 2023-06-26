import 'package:ezdeliver/screen/component/helper/exporter.dart';

import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/order/components/categoryList.dart';
import 'package:ezdeliver/screen/order/components/productList.dart';

class SubCategoryProductScreen extends ConsumerWidget {
  const SubCategoryProductScreen(
      {Key? key, required this.item, required this.subCategories})
      : super(key: key);
  final Category item;
  final List<SubCategory> subCategories;
  @override
  Widget build(BuildContext context, ref) {
    return SafeArea(
      child: Scaffold(
        appBar: simpleAppBar(context,
            title: item.name,
            search: true,
            cart: true,
            centerTitle: ResponsiveLayout.isMobile,
            close: ResponsiveLayout.isMobile),
        body: Builder(builder: (context) {
          final error = ref.watch(productCategoryServiceProvider).error.value;
          return error == null
              ? Row(
                  children: [
                    Expanded(
                        child: CategoryListDisplay(
                      subCategories: subCategories,
                    )),
                    if (!ResponsiveLayout.isMobile)
                      SizedBox(
                        width: ResponsiveLayout.isDesktop ? 50.sw() : 20.sw(),
                      ),
                    Expanded(flex: 3, child: ProductListDisplay())
                  ],
                )
              : Center(
                  child: Text(error),
                );
        }),
      ),
    );
  }
}
