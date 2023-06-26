import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Enums/Approval.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/Constants/CardStylePalette.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Components/CustomTheme.dart';
import '../ProductEditScreen.dart';
import 'Checks.dart';

class SingularProduct extends StatelessWidget {
  final SearchProduct product;
  final bool gestureEdit;

  const SingularProduct(this.product, {super.key, this.gestureEdit = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        EditProductManagement readEdit = context.read<EditProductManagement>();
        readEdit.selectedProduct = product;
        await StaticService.pushPage(
            context: context,
            route: ProductEditScreen(product: readEdit.selectedProduct));
        readEdit.selectedProduct = null;
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: SpacePalette.paddingExtraLargeH
              .copyWith(top: 10, bottom: 10, left: 8, right: 8),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.watch<CustomTheme>().isDarkMode
                              ? ColorPalette.darkContainerColor
                              : Colors.white,
                          boxShadow: [CardStylePalette.kBoxShadow]),
                      child: StaticService.cache(product.image,
                          fit: BoxFit.contain, height: 60),
                    ),
                  )),
              // SpacePalette.spaceMedium,
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.myProduct?.name ?? product.name,
                            style:
                                Theme.of(context).textTheme.headline5?.copyWith(
                                    fontSize: 15,
                                    // color: Colors.black,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Text(product.categoryName ?? product.category,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: context.watch<CustomTheme>().isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5))),
                    Text(
                        "${product.myProduct?.sku ?? product.sku} ${product.myProduct?.unit ?? product.unit} • Rs. ${product.myProduct?.price ?? product.price}",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: context.watch<CustomTheme>().isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5))),
                    SpacePalette.spaceTiny,
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Checks(product.myProduct),
                  Builder(builder: (context) {
                    bool condition = product.myProduct != null;
                    if (!condition) return Container();
                    condition = product.myProduct!.deactivated;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        condition ? "Unavailable" : "Available",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: !condition ? Colors.green : Colors.red,
                            fontSize: 10),
                      ),
                    );
                  }),
                  SpacePalette.spaceTiny,
                  Builder(builder: (context) {
                    bool condition = product.myProduct != null;
                    if (!condition) return Container();
                    Approval a =
                        Approval.status(product.myProduct!.verificationAdmin);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        a.toString(),
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: condition
                                ? Theme.of(context).primaryColor
                                : (context.watch<CustomTheme>().isDarkMode
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5)),
                            fontSize: 10),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
