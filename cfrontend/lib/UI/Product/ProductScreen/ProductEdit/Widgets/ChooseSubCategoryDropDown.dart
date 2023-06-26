import 'package:dropdown_search/dropdown_search.dart';
import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseSubCategoryDropdown extends StatelessWidget {
  final SearchProduct? product;

  ChooseSubCategoryDropdown({this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<EditProductManagement>().function,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            CustomSnackBar().error("Could not fetch data from server");
          }
          if (snapshot.hasData) {
            List<SubCategory> category = snapshot.data;
            if (product != null) {
              for (var element in category) {
                if (element.id == product!.category) {
                  context
                      .read<EditProductManagement>()
                      .setSelectedSubCategory(element);
                } else {}
              }
              context.read<EditProductManagement>().selectedSubCategory;
            }
            return Row(
              children: [
                Expanded(
                    child: DropdownSearch<SubCategory>(
                        enabled: product == null,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                        ),

                        items: category,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          baseStyle: product !=null ?  const TextStyle(color: Colors.grey) : null,
                          dropdownSearchDecoration: InputDecoration(
                              errorText: context
                                  .watch<EditProductManagement>()
                                  .subCategoryErrorText,
                              // labelText: "Choose Subcategory",

                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              // hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                              hintText: "Choose Subcategory",
                              suffixIconColor:Theme.of(context).primaryColor
                          ),
                        ),
                        onChanged: (SubCategory? value) {
                          context
                              .read<EditProductManagement>()
                              .selectedSubCategory = value;
                          context
                              .read<EditProductManagement>()
                              .subCategoryValidation();
                        },
                        selectedItem: context
                            .watch<EditProductManagement>()
                            .selectedSubCategory)),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                  child: DropdownSearch<String?>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                items: ["No data"],
                enabled: false,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                      // labelText: "Choose Subcategory",
                      // labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      hintText: "Choose Subcategory",
                      iconColor: Theme.of(context).primaryColor),
                ),
                onChanged: print,
                selectedItem: "No data",
              )),
            ],
          );
        });
  }
}
