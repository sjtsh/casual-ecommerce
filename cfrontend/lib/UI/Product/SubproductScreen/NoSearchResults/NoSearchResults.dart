import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/StateManagement/NotSearchingProductManagement.dart';
import 'package:ezdelivershop/StateManagement/SearchingProductManagement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../BackEnd/Entities/SearchProduct.dart';
import '../../../../BackEnd/Entities/ShopCategory.dart';
import '../../../../BackEnd/Enums/Approval.dart';
import '../../../../Components/Constants/SpacePalette.dart';
import '../../../../Components/CustomTheme.dart';
import '../../../../Components/UIWidgets/LazyLoadComponent.dart';
import '../../../../Components/Widgets/FilterChip.dart';
import '../../../Skeletons/NoSearchSkeleton.dart';
import '../../ProductScreen/ProductEdit/Widgets/SingularSubCategory.dart';

int lazyLoadSubCategoryInitialCount = 3;
int lazyLoadSubCategoryAppendCount = 3;

class NoSearchResults extends StatelessWidget {
 final  String shopId;
  NoSearchResults(this.shopId, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Builder(builder: (context) {
            MapEntry<int, int>? tabCount =
                context.watch<NotSearchingProductManagement>().tabCount;
            return Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                      onTap: () {
                        context.read<TabProduct>().page = 0;
                        context.read<TabProduct>().animateTo(0);
                      },
                      child: MyFilterChip(
                          tabCount == null
                              ? "Available"
                              : "Available (${tabCount.key})",
                          0,
                          context.watch<TabProduct>().page)),
                ),
              ),
              SpacePalette.spaceTiny,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                      onTap: () {
                        context.read<TabProduct>().page = 1;
                        context.read<TabProduct>().animateTo(1);
                      },
                      child: MyFilterChip(
                          tabCount == null
                              ? "Unavailable"
                              : "Unavailable (${tabCount.value})",
                          1,
                          context.watch<TabProduct>().page)),
                ),
              ),
            ]);
          }),
        ),
        SpacePalette.spaceTiny,
        buildFilters(context),
        SpacePalette.spaceTiny,
        Expanded(
          child: Builder(builder: (context) {
            NotSearchingProductManagement watch =
                context.watch<NotSearchingProductManagement>();
            return PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: context.read<TabProduct>().controller,
                children: [
                  buildSubProductList(context,
                      watch.subcategoryEntriesActivated?.toList(), true),
                  buildSubProductList(context,
                      watch.subcategoryEntriesDeactivated?.toList(), false)
                ]);
          }),
        ),
      ],
    );
  }

  Widget buildFilters(BuildContext context) {
    return Row(
        children: Approval.values.map((e) {
      bool cont = context
          .watch<NotSearchingProductManagement>()
          .filterApproved
          .contains(e);
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
            onTap: () {
              NotSearchingProductManagement read =
                  context.read<NotSearchingProductManagement>();
              if (cont) {
                if (read.filterApproved.length <= 1) return;
                read.filterApproved.remove(e);
              } else {
                read.filterApproved.add(e);
              }
              read.filterApproved = read.filterApproved;
            },
            child: Container(
                decoration: BoxDecoration(
                    color: cont
                        ? Theme.of(context).primaryColor
                        : (context.watch<CustomTheme>().isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(e.name.capitalize(),
                      style: TextStyle(
                          color: cont
                              ? (Colors.white)
                              : context.watch<CustomTheme>().isDarkMode
                                  ? Colors.white
                                  : Colors.black)),
                ))),
      );
    }).toList());
  }

  Widget buildSubProductList(
      BuildContext context,
      List<MapEntry<SubCategory, List<SearchProduct>?>>? subProductList,
      bool activated) {
    NotSearchingProductManagement read =
        context.read<NotSearchingProductManagement>();
    return
      subProductList != null
        ? (subProductList.isNotEmpty
            ? LazyLoadComponent<MapEntry<SubCategory, List<SearchProduct>?>>(
                children: subProductList,
                builder: (BuildContext _,
                    MapEntry<SubCategory, List<SearchProduct>?> pr) {
                  return SingularSubcategory(pr, activated: activated);
                },
                onListEnd: (
                    {required int appendCount, required int loaded}) async {
                  if (activated) {
                    await read.loadActivated(loaded, appendCount, shopId: shopId);
                  } else {
                    await read.loadDeactivated(loaded, appendCount, shopId: shopId);
                  }
                },
                appendCount: lazyLoadSubCategoryAppendCount,
                initialCount: lazyLoadSubCategoryInitialCount,
              ).refresh(
                () => context.read<NotSearchingProductManagement>().reset(0, 6,shopId: shopId))
            : Center(
                child: Padding(
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
                            .headline3
                            ?.copyWith(color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
              ))
        : NoSearchSkeleton();
  }
}
