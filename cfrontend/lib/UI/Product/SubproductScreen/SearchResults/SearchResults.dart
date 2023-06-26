import 'package:flutter/material.dart';

import '../../../../BackEnd/Entities/SearchProduct.dart';
import '../../../../BackEnd/Enums/Roles.dart';
import '../../../../Components/Constants/SpacePalette.dart';
import '../../ProductScreen/ProductEdit/Widgets/SingularProduct.dart';
import 'CreateEditButton.dart';

class SearchResults extends StatelessWidget {
  final List<SearchProduct> results;

  SearchResults(this.results);

  @override
  Widget build(BuildContext context) {
    List<ProductRoles> role = Roles.getProductRoles();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Builder(builder: (BuildContext context) {
              if (results.isNotEmpty) {
                return ListView(
                    children: results.map((pr) => SingularProduct(pr)).toList());
              }
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/issue/searched.png",
                      height: 150,
                    ),
                    SpacePalette.spaceMedium,
                    Text(
                      "No products",
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              );
            }),
          ),
          if (role.contains(ProductRoles.ORproductRolesCreate) ||
              role.contains(ProductRoles.ORproductRolesUpdate))
            CreateEditButton(),
        ],
      ),
    );
  }
}
