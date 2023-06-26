import 'package:ezdelivershop/BackEnd/Enums/Roles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../BackEnd/StaticService/StaticService.dart';
import '../../../../../Components/Widgets/Button.dart';
import '../../../../../StateManagement/EditProductManagement.dart';
import '../../../../StateManagement/SearchingProductManagement.dart';
import '../../ProductScreen/ProductEdit/ProductEditScreen.dart';

class CreateEditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Roles.getProductRoles().contains(ProductRoles.ORproductRolesCreate)
              ? createButton(context)
              : Container()
        ],
      ),
    );
  }

  Widget createButton(BuildContext context) {
    return Expanded(
      child: AppButtonPrimary(
        onPressedFunction: () {
          context.read<EditProductManagement>().switchToggle = true;
          StaticService.pushPage(
              context: context,
              route: ProductEditScreen(
                  query: context
                      .read<SearchingProductManagement>()
                      .controller
                      .text,
                  product:
                      context.read<EditProductManagement>().selectedProduct));
        },
        text: "Create New",
        borderRadius: 4,
      ),
    );
  }

  Widget updateButton(BuildContext context) {
    return Expanded(
        child: AppButtonPrimary(
      isdisable: context.watch<EditProductManagement>().selectedProduct == null,
      onPressedFunction: () async {
        context.read<SearchingProductManagement>().controller.clear();
          await StaticService.pushPage(
              context: context,
              route: ProductEditScreen(
                  product:
                      context.read<EditProductManagement>().selectedProduct));

      },
      text: (true) ? "Save" : "Update",
      borderRadius: 4,
    ));
  }
}
