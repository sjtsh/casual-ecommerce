// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// import '../../BackEnd/Services/SearchingProductService.dart';
// import '../../BackEnd/StaticService/StaticService.dart';
// import '../../Components/CustomTheme.dart';
// import '../../StateManagement/NotSearchingProductManagement.dart';
// import '../../StateManagement/SearchingProductManagement.dart';
// import 'ProductScreen/ProductEdit/BarCodeScanner.dart';
// import 'SearchResults/SearchResults.dart';
//
// class ProductSearchTextField extends StatefulWidget {
//   @override
//   State<ProductSearchTextField> createState() => _ProductSearchTextFieldState();
// }
//
// class _ProductSearchTextFieldState extends State<ProductSearchTextField> {
//   String _query = '';
//   String qInstance = "";
//
//   String get query => _query;
//
//   set query(String value) {
//     _query = value;
//     setState(() {});
//     if (query.trim() != "") {
//       context.read<SearchingProductManagement>().ref();
//     } else {
//       context.read<TabProduct>().page = 0;
//       context.read<NotSearchingProductManagement>().filterApproved = [
//         "approved",
//         "unapproved"
//       ];
//       context.read<SearchingProductManagement>().searchResult = null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//         data: buildTheme(context),
//         child: TextField(
//           controller:context.read<SearchingProductManagement>(). controller,
//           onChanged: (String? s) {
//             if (s == null) return;
//             qInstance = s;
//             Future.delayed(const Duration(milliseconds: 200)).then((value) {
//               if (qInstance == s) query = s;
//             });
//           },
//           decoration: InputDecoration(
//             hintText: "Search Product",
//             suffixIcon: buildSuffix(context),
//           ),
//         ));
//   }
//
//   Widget buildSuffix(BuildContext context) {
//     if (query != "") {
//       return IconButton(
//         onPressed: () {
//           query = '';
//           context.read<SearchingProductManagement>().controller.clear();
//         },
//         icon: Icon(
//           Icons.clear,
//           color: context.watch<CustomTheme>().isDarkMode
//               ? Colors.white70
//               : Colors.black,
//         ),
//       );
//     }
//     return GestureDetector(
//       onTap: () async {
//         Barcode? access = (await StaticService.pushPage(
//             context: context, route: const BarScannerView()) as Barcode?);
//         if (access != null) query = access.code.toString();
//         context.read<SearchingProductManagement>().controller.text = query;
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(right: 8.0),
//         child: Icon(
//           Icons.barcode_reader,
//           color: Theme.of(context).primaryColor,
//           size: 32,
//         ),
//       ),
//     );
//   }
//
//   ThemeData buildTheme(BuildContext context) {
//     final theme = Theme.of(context).copyWith(
//       inputDecorationTheme: const InputDecorationTheme().copyWith(
//         contentPadding: EdgeInsets.zero.copyWith(left: 12),
//         outlineBorder: BorderSide(
//             width: 1, color: Theme.of(context).primaryColor.withOpacity(.35)),
//         enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 width: 1,
//                 color: Theme.of(context).primaryColor.withOpacity(.35))),
//         focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 width: 1,
//                 color: Theme.of(context).primaryColor.withOpacity(.35))),
//         errorBorder: InputBorder.none,
//         focusedErrorBorder: InputBorder.none,
//       ),
//       brightness: Brightness.dark,
//       textSelectionTheme: TextSelectionThemeData(
//         cursorColor: Theme.of(context).primaryColor,
//       ),
//       hintColor: context.watch<CustomTheme>().isDarkMode
//           ? Colors.white70
//           : CustomTheme.greyColor,
//       appBarTheme: AppBarTheme(
//           elevation: 0,
//           iconTheme: IconThemeData(color: CustomTheme().getBlackColor()),
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor),
//     );
//
//     return theme;
//   }
// }
