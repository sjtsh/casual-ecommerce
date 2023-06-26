import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/AppDivider/Appdivider.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:flutter/material.dart';
import '../../../../BackEnd/Services/ShopService.dart';
import '../../../../Components/Constants/ColorPalette.dart';
class ProductDetails extends StatefulWidget {
  final SearchProduct product;

  ProductDetails(this.product);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  SubCategory? selectedSubCategory;

  late bool isMaster =
      widget.product.myProduct == null || widget.product.myProduct!.deactivated;

  @override
  void initState() {
    loadCat();
    super.initState();
  }

  loadCat() async {
    List<SubCategory> subcategory = await ShopService().getSubCategory();
    for (var element in subcategory) {
      if (widget.product.myProduct?.category != null) {
        if (element.id == widget.product.myProduct!.category) {
          selectedSubCategory = element;
        }
      } else {
        if (element.id == widget.product.category) {
          selectedSubCategory = element;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        // backgroundColor: Colors.black,
        // body: Column(
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.only(top: 0.0),
        //       child: Container(
        //         width: double.infinity,
        //         decoration: BoxDecoration(
        //           // boxShadow: const [
        //           //   BoxShadow(
        //           //       offset: Offset(1, 0),
        //           //       blurRadius: 10,
        //           //       color: Colors.grey),
        //           // ],
        //           // borderRadius: const BorderRadius.only(
        //           //   topLeft: Radius.circular(30),
        //           //   topRight: Radius.circular(30),
        //           // ),
        //           color: context.watch<CustomTheme>().isDarkMode
        //               ? ColorPalette.darkContainerColor
        //               : ColorPalette.whiteColor,
        //         ),
                body: Column(
                  children: [
                    CustomAppBar(title: "Product Details", leftButton: true),
                    Expanded(
                      child: Padding(
                        padding: SpacePalette.paddingLargeH,
                        child: ListView(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: widget.product.id,
                              child: Container(
                                  height: 250,
                                  // width: MediaQuery.of(context).size.width,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    // boxShadow: [
                                    //
                                    //   BoxShadow(
                                    //       offset: const Offset(0, 2),
                                    //       blurRadius: 20,
                                    //       color: Colors.black.withOpacity(0.2))
                                    // ],
                                    // shape: BoxShape.circle,
                                    // color: context.watch<CustomTheme>().isDarkMode
                                    //     ? ColorPalette.darkContainerColor
                                    //     : ColorPalette.whiteColor,
                                  ),
                                  child: StaticService.cache(
                                      !isMaster? widget.product.myProduct?.image: widget.product.image,
                                      fit: BoxFit.contain)),
                            ),
                            SpacePalette.spaceMedium,
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: !isMaster
                                          ? widget.product.myProduct!.name
                                          : widget.product.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4,
                                      // children: [
                                      // TextSpan(
                                      //   text:
                                      //   "\nRs.${product.price.toString()}",
                                      //   style: TextStyle(
                                      //       color: ColorPalette
                                      //           .primaryColor,
                                      //       fontSize: 18),
                                      // )
                                      // ]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SpacePalette.spaceMedium,
                            const AppDivider(
                              height: 2,
                            ),
                            SpacePalette.spaceExtraLarge,
                            productInfo(
                                context: context,
                                title: "Product Id:",
                                value: !isMaster
                                    ? widget.product.myProduct?.id
                                    : widget.product.id),
                            productInfo(
                                context: context,
                                title: "Category:",
                                value: selectedSubCategory?.name),
                            productInfo(
                                context: context,
                                title: "BarCode Id:",
                                value: !isMaster
                                    ? widget.product.myProduct?.barcode
                                    : widget.product.barcode),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Wrap(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // scrollDirection: Axis.horizontal,
                                children: [
                                  properties("Price",
                                      "${!isMaster ? widget.product.myProduct?.price : widget.product.price}"),
                                  SpacePalette.spaceMedium,
                                  properties(
                                      "SKU",
                                      !isMaster
                                          ? widget.product.myProduct?.sku
                                          : widget.product.sku),
                                  SpacePalette.spaceMedium,
                                  properties(
                                      "Unit",
                                      !isMaster
                                          ? widget.product.myProduct?.unit
                                          : widget.product.unit),
                                  SpacePalette.spaceMedium,
                                  properties(
                                      "Margin",
                                      !isMaster
                                          ? widget.product.myProduct?.margin
                                          : widget.product.margin),
                                  SpacePalette.spaceMedium,
                                  properties(
                                      "Return Days",
                                      !isMaster
                                          ? widget.product.myProduct
                                              ?.returnPolicy
                                          : widget.product.returnPolicy),
                                ],
                              ),
                            ),
                            // Expanded(child: Container()),
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 12.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                          // Container(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(
                          //       color: primaryColor,
                          //     ),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(10.0),
                          //     child: Center(
                          //       child: Icon(
                          //         Icons.favorite_border_outlined,
                          //         color: primaryColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          // AppButtonPrimary(
                          //   buttonColor: ColorPalette.primaryColor,
                          //   borderRadius: 12,
                          //   onPressedFunction: () {
                          //     Navigator.pop(context);
                          //   },
                          //   icon: Icons.arrow_back_outlined,
                          //   text: "GO BACK",
                          // )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ));
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget productInfo(
      {required BuildContext context, required String title, String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                title,
                textAlign: TextAlign.justify,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SpacePalette.spaceMedium,
              Text(
                value ?? "N/A",
                textAlign: TextAlign.justify,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget properties(
    String header,
    value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                header,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorPalette.notExactlyPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SpacePalette.spaceMedium,

              Container(
                height: 1,
                width: 55,
                color: Colors.grey.shade300,
              ),
              SpacePalette.spaceMedium,
              Text(
                value.toString == "null" ? "N/A" : (value ?? "N/A").toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Container(
              //   height: 1,
              //   width: 55,
              //   color: Colors.grey.shade300,
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Text(
              //   percentage,
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
