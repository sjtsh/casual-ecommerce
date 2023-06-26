import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/home/components/FeaturedBox.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final categories = ref.watch(productCategoryServiceProvider).category;

    final List<Category> dataList = categories != null
        ? categories.isNotEmpty
            ? categories.toList()
            : List.generate(10, (e) => Category.empty())
        : [];

    final isloading = categories == null;
    return Scaffold(
      appBar: ResponsiveLayout.isMobile
          ? simpleAppBar(context,
              title: "Categories", close: false, setting: true)
          : null,
      body: LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: () async {
            // ref.read(customSocketProvider).refreshAuth(
            //     ref.read(userChangeProvider).loggedInUser.value!.accessToken!);

            await ref.read(productCategoryServiceProvider).fetchCategories();
            await ref
                .read(productCategoryServiceProvider)
                .fetchTrendingProducts();
            await ref
                .read(productCategoryServiceProvider)
                .fetchAllSubCategoriesWithProducts(clear: true);
          },
          child: ref.watch(locationServiceProvider).currentAddress == null &&
                  ref.watch(locationServiceProvider).permissionEnums !=
                      LocationPermissionEnums.always
              ? Padding(
                  padding: EdgeInsets.only(
                      left: 15.sr(), right: 15.sr(), top: 15.sr()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InfoMessage.noLocation(),
                      SizedBox(
                        height: 10.sh(),
                      ),
                      CustomElevatedButton(
                          onPressedElevated: () {
                            Utilities.pushPage(const YourLocation(), 15);
                          },
                          elevatedButtonText:
                              "Grant location or choose Address")
                    ],
                  ))
              : categories != null && Api.hasInternet
                  ? categories.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: constraints.maxHeight / 3,
                            ),
                            Center(
                              child: InfoMessage.outOfServiceArea(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // if (ResponsiveLayout.isMobile) const CustomAppBar(),
                            // Expanded(
                            //   flex: 1,
                            //   child: ItemBox(
                            //     isLoading: isloading,
                            //     items: [dataList[0], dataList[1], dataList[2]],
                            //   ),
                            // ),
                            Expanded(
                              flex: 2,
                              child: ItemBox(
                                showText: false,
                                isLoading: isloading,
                                items: dataList,
                                trending: true,
                              ),
                            ),
                          ],
                        )
                  : Center(
                      child: InfoMessage.noInternet(),
                    ),
        );
      }),
    );
  }
}

// class CategoryItem extends ConsumerWidget {
//   const CategoryItem(
//       {super.key,
//       required this.item,
//       required this.index,
//       this.isLoading = true});
//   final Category item;
//   final int index;
//   final bool isLoading;
//   @override
//   Widget build(BuildContext context, ref) {
//     return InkWell(
//       onTap: () async {
//         if (!isLoading) {
//           ref.read(productCategoryServiceProvider).clear();

//           Future.delayed(const Duration(milliseconds: 200), () {
//             ref
//                 .read(productCategoryServiceProvider)
//                 .fetchSubCategories(item.id);
//             Navigator.push(context, MaterialPageRoute(builder: (context) {
//               return SubCategoryProductScreen(
//                 item: item,
//               );
//             }));
//           });
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.all(10.ssp()),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.sr()),
//             color:
//                 isLoading ? CustomTheme.whiteColor : CustomTheme.primaryColor),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             isLoading
//                 ? CustomShimmer()
//                 : Expanded(
//                     flex: 1,
//                     child: Text(
//                       item.name,
//                       maxLines: 2,
//                       textAlign: TextAlign.center,
//                       overflow: TextOverflow.ellipsis,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText2!
//                           .copyWith(color: Theme.of(context).primaryColor),
//                     ),
//                   ),
//             SizedBox(
//               height: 10.sh(),
//             ),
//             isLoading
//                 ? Expanded(child: CustomShimmer(shape: BoxShape.circle))
//                 : Expanded(
//                     flex: 2,
//                     child: CachedNetworkImage(
//                       imageUrl: item.image,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
