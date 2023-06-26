import 'package:dropdown_search/dropdown_search.dart';
import 'package:ezdelivershop/BackEnd/Services/ShopService.dart';
import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnitDropDown extends StatelessWidget {
  final bool ?enabled;
  const UnitDropDown({this.enabled,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ShopService().getUnits(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            if (kDebugMode) {
              print(snapshot.error);
            }
          }
          if (snapshot.hasData) {
            List<String> units = snapshot.data;
            return Row(
              children: [
                Expanded(
                  child: DropdownSearch<String>(
                     enabled:  enabled ??true,
                      popupProps: const PopupProps.menu(
                        // showSearchBox: true,
                      ),
                      items: units,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        baseStyle: enabled==false ?  const TextStyle(color: Colors.grey) : null,
                        dropdownSearchDecoration: InputDecoration(
                          errorText: context.watch<EditProductManagement>().unitErrorText,
                            // labelText: "Choose Subcategory",
                            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                            hintText: "Unit",
                            // hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                            suffixIconColor: Theme.of(context).primaryColor

                        ),
                      ),
                      onChanged: ( String  ?value){
                        context.read<EditProductManagement>().selectedUnit =value;
                        context.read<EditProductManagement>().unitValidation();
                      },
                      selectedItem: context.read<EditProductManagement>().selectedUnit

                  ),
                )
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                  child:DropdownSearch<String?>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    enabled: false,
                    items: ["No data"],
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        // labelText: "Choose Subcategory",
                        // labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                          hintText: "Unit",
                          iconColor: Theme.of(context).primaryColor

                      ),
                    ),
                    onChanged: print,
                    selectedItem: "No data",
                  ) ),
            ],
          );
        });
  }
}
