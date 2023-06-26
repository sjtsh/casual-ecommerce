// import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
// import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
// import 'package:ezdelivershop/Components/Widgets/Button.dart';
// import 'package:ezdelivershop/StateManagement/OrderManagement.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../Components/CustomTheme.dart';
// import '../../Components/Widgets/ButtonOutline.dart';
//
// class StartDeliveryDialogBox extends StatelessWidget {
//   final String title;
//   final String checkBoxTitle;
//   final Function onPressedStart;
//   final Function() onPressed;
//   final bool onPressedPop;
//
//   StartDeliveryDialogBox(
//       {required this.title,
//       required this.checkBoxTitle,
//       required this.onPressed,
//       required this.onPressedStart,
//       this.onPressedPop = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: Container(
//           decoration: BoxDecoration(
//               color: context.watch<CustomTheme>().isDarkMode
//                   ? ColorPalette.darkContainerColor
//                   : Colors.white,
//               borderRadius: BorderRadius.circular(6)),
//           height: 200,
//           width: 400,
//           child: Padding(
//             padding:
//                 const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context)
//                       .textTheme
//                       .headline5
//                       ?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 SpacePalette.spaceLarge,
//                 checkBox(context),
//
//                 // Text(
//                 //     """Your feedback has been sent. Please wait for the confirmation from customer."""),,
//                 const Spacer(),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: AppButtonOutline(
//                           borderRadius: 4,
//                           height: 40,
//                           onPressedFunction: () {
//                             onPressed();
//                             if (onPressedPop) {
//                               Navigator.pop(context);
//                             }
//                           },
//                           text: "Cancel",
//                       ),
//                     ),
//                     SpacePalette.spaceMedium,
//                     Expanded(
//                         child: AppButtonPrimary(
//                       height: 40,
//                       text: "Start",
//                       onPressedFunction: onPressedStart,
//                     ))
//                   ],
//                 )
//               ],
//             ),
//           )),
//     );
//   }
//
//   Widget checkBox(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           height: 16,
//           width: 16,
//           child: Checkbox(
//               value: context.watch<OrderManagement>().showDirectionInMap,
//               onChanged: (value) {
//                 context.read<OrderManagement>().showDirectionInMap =
//                     value ?? context.read<OrderManagement>().showDirectionInMap;
//               }),
//         ),
//         SpacePalette.spaceMedium,
//         Text(
//           checkBoxTitle,
//           style: Theme.of(context).textTheme.bodyText1,
//         ),
//       ],
//     );
//   }
// }
