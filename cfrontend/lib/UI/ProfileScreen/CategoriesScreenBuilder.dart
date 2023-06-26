// import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
// import 'package:flutter/material.dart';
// import '../../BackEnd/Entities/ShopCategory.dart';
// import '../../BackEnd/Services/ShopService.dart';
// import '../../Components/Widgets/CustomAppBar.dart';
// import '../Skeletons/CategoriesSkeleton.dart';
// import 'CategoriesScreen.dart';
//
// class CategoriesScreenBuilder extends StatefulWidget {
//   final List<ShopCategory> categories;
//   final bool isFromSignup;
//   final bool withoutPop;
//
//   CategoriesScreenBuilder(this.categories,
//       {required this.isFromSignup, this.withoutPop = false,});
//
//   @override
//   State<CategoriesScreenBuilder> createState() =>
//       _CategoriesScreenBuilderState();
// }
//
// class _CategoriesScreenBuilderState extends State<CategoriesScreenBuilder> {
//   List<ShopCategory>? categories;
//
//   @override
//   void initState() {
//     super.initState();
//     ShopService()
//         .getShopCategory()
//         .then((value) => setState(() => categories = value));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomSafeArea(
//       child: Scaffold(
//         body: Builder(builder: (context) {
//           if (categories != null) {
//             return CategoriesScreen(
//                 isFromSignup: widget.isFromSignup,
//                 categories!,
//                 widget.categories.map((e) => e.id).toSet(), widget.withoutPop);
//           }
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               CustomAppBar(
//                 title: "Categories",
//                 leftButton: true,
//               ),
//               CategoriesSkeleton(),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
