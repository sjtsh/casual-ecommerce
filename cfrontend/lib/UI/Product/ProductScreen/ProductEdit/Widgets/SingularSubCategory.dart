import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/Constants/CardStylePalette.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:ezdelivershop/UIWidgets/Components/LazyLoadCompnentForSingularProduct.dart';
import 'package:ezdelivershop/StateManagement/NotSearchingProductManagement.dart';
import 'package:ezdelivershop/UI/Product/ProductScreen/ProductEdit/ProductEditScreen.dart';
import 'package:ezdelivershop/UI/Product/ProductScreen/ProductEdit/Widgets/Checks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Components/CustomTheme.dart';
import '../../../../../StateManagement/EditProductManagement.dart';
import '../../../../Skeletons/NoSearchSkeleton.dart';

class SingularSubcategory extends StatefulWidget {
  final MapEntry<SubCategory, List<SearchProduct>?> productEntry;
  final String? query;
  final bool activated;

  const SingularSubcategory(this.productEntry,
      {this.query, required this.activated, super.key});

  @override
  State<SingularSubcategory> createState() => _SingularSubcategoryState();
}

class _SingularSubcategoryState extends State<SingularSubcategory> {
  bool progressive = false;

  late ScrollController controller = ScrollController(
      initialScrollOffset: widget.productEntry.key.offset ?? 0);
  late String ?shopId ;

  @override
  void initState() {
    super.initState();
shopId = context.read<SignInManagement>().loginData?.staff?.shop?.first?.id;
    if (widget.productEntry.value == null) {
      setState(() => progressive = true);
      context
          .read<NotSearchingProductManagement>()
          .getProds(0, 2, widget.productEntry.key, widget.activated, shopId!)
          .then((e) {
        if (mounted) setState(() => progressive = false);
      });
    }
    controller.addListener(() {
      widget.productEntry.key.offset = controller.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SpacePalette.paddingExtraLargeH.copyWith(top: 10, bottom: 10),
      child: Container(
          padding: SpacePalette.paddingMediumV,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.watch<CustomTheme>().isDarkMode
                  ? ColorPalette.darkContainerColor
                  : Colors.white,
              boxShadow: [CardStylePalette.kBoxShadow]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "${widget.productEntry.key.name} (${widget.productEntry.key.skuCount})",
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      fontSize: 15,
                      // color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SpacePalette.spaceTiny,
              Builder(builder: (BuildContext ctx) {
                if (progressive) return const ProductSkeleton();
                return SizedBox(
                  height: 300,
                  child: LazyLoadComponentForProduct<SearchProduct>(
                      controller: controller,
                      direction: Axis.horizontal,
                      onListEnd: (
                          {required int appendCount,
                          required int loaded}) async {
                        await context
                            .read<NotSearchingProductManagement>()
                            .getProds(loaded, appendCount,
                                widget.productEntry.key, widget.activated, shopId!);
                      },
                      children: widget.productEntry.value ?? [],
                      builder: (BuildContext context, SearchProduct pr) =>
                          SingularSubCategoryGrid(pr),
                      appendCount: 3,
                      initialCount: (widget.productEntry.value ?? []).length),
                );
              })
            ],
          )),
    );
  }
}

class SingularSubCategoryGrid extends StatefulWidget {
  final SearchProduct product;
  final String? query;
  final bool? activated;

  const SingularSubCategoryGrid(
    this.product, {
    this.query,
    this.activated,
    super.key,
  });

  @override
  State<SingularSubCategoryGrid> createState() =>
      _SingularSubCategoryGridState();
}

class _SingularSubCategoryGridState extends State<SingularSubCategoryGrid> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bool current = widget.product.myProduct != null &&
            !widget.product.myProduct!.deactivated;
        switchFunc(!current);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          width: 240,
          padding: SpacePalette.paddingMediumV,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.watch<CustomTheme>().isDarkMode
                  ? ColorPalette.darkContainerColor
                  : Colors.white,
              boxShadow: context.watch<CustomTheme>().isDarkMode
                  ? [CardStylePalette.kBoxShadowDark]
                  : [CardStylePalette.kBoxShadow]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(child: StaticService.cache(widget.product.image)),
                SpacePalette.spaceMedium,
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          widget.product.name,
                          style:
                              Theme.of(context).textTheme.headline5?.copyWith(
                                  fontSize: 12,
                                  // color: Colors.black,
                                  fontWeight: FontWeight.w500),
                        ),
                      ),
                      SpacePalette.spaceExtraLarge,
                      Checks(
                          widget.product.myProduct)
                    ],
                  ),
                ),
                SpacePalette.spaceMedium,
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${widget.product.sku} ${widget.product.unit}"),
                        SpacePalette.spaceTiny,
                        Text("Rs.${widget.product.price}"),
                      ],
                    )),
                    SizedBox(
                      height: 6,
                      width: 48,
                      child: Transform.scale(
                        scale: .8,
                        child: CupertinoSwitch(
                            value: widget.product.myProduct != null &&
                                !widget.product.myProduct!.deactivated,
                            onChanged: switchFunc),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  switchFunc(v) async {
    EditProductManagement readEdit = context.read<EditProductManagement>();
    readEdit.selectedProduct = widget.product;
    await StaticService.pushPage(
        context: context,
        route: ProductEditScreen(product: readEdit.selectedProduct));
    readEdit.selectedProduct = null;
    return;
  }

// activate(bool v){
//
// }
}
