// import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
// import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../StateManagement/SignUpAndCameraManagement.dart';
// import '../ProfileScreen/CategoriesScreenBuilder.dart';
//
// class ChooseCategories extends StatelessWidget {
//   // final List<ShopCategory> categories;
//   //
//   // ChooseCategories(this.categories);
//
//   @override
//   Widget build(BuildContext context) {
//     SignUpAndCameraManagement read = context.read<SignUpAndCameraManagement>();
//     SignUpAndCameraManagement watch =
//         context.watch<SignUpAndCameraManagement>();
//     return GestureDetector(
//         onTap: () async {
//           StaticService.pushPage(
//               context: context,
//               route: CategoriesScreenBuilder(
//                   isFromSignup: true,
//                   context.read<SignUpAndCameraManagement>().selectedCategory));
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               width: double.infinity,
//               height: 50,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                       color: watch.isCategoryValidated
//                           ? ColorPalette.primaryColor.withOpacity(.3)
//                           : Colors.red,
//                       width: watch.isCategoryValidated ? 1 : 2),
//                   borderRadius: BorderRadius.circular(8)),
//               child: watch.selectedCategories.isEmpty
//                   ? Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Select Category",
//                         style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.grey),
//                       ))
//                   : ListView(scrollDirection: Axis.horizontal, children: [
//                       ...watch.selectedCategories.map((element) {
//                         return Container(
//                             margin: const EdgeInsets.only(right: 6),
//                             decoration: BoxDecoration(
//                                 color:
//                                     ColorPalette.primaryColor.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(2)),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     element.name,
//                                   ),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       read.removeSelectedCategory(element);
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.black.withOpacity(0.1)),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(2.0),
//                                         child: Center(
//                                             child: Icon(
//                                           Icons.close,
//                                           size: 12,
//                                           color: Colors.black.withOpacity(0.6),
//                                         )),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ));
//                       }).toList(),
//                     ]),
//             ),
//             watch.isCategoryValidated
//                 ? Container()
//                 : const Padding(
//                     padding: EdgeInsets.only(
//                       left: 18.0,
//                       top: 9.0,
//                     ),
//                     child: Text(
//                       "Choose category",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 12,
//                       ),
//                     ),
//                   )
//           ],
//         ));
//   }
// }
