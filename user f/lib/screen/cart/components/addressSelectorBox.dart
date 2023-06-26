// import 'package:ezdeliver/screen/cart/services/cartService.dart';
// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/others/widgets.dart';
// import 'package:ezdeliver/services/location.dart';

// class AddressSelector extends ConsumerWidget {
//   const AddressSelector({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, ref) {
//     return Container(
//       decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15), topRight: Radius.circular(15))),
//       padding: EdgeInsets.all(12.sr()),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 10.sh(),
//           ),
//           GestureDetector(
//             onTap: () {},
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.location_on,
//                   color: danger,
//                 ),
//                 SizedBox(
//                   width: 10.sw(),
//                 ),
//                 const Text("Enter your delivery address"),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.sh()),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CustomElevatedButton(
//                   color: buttonColor,
//                   width: 250.sw(min: 200),
//                   onPressedElevated: () async {
//                     await Future.delayed(Duration(milliseconds: 800), () async {
//                       try {
//                         var position = await CustomLocation.determinePosition();
//                         ref.read(cartServiceProvider).position.value = position;
//                       } catch (e) {
//                         print(e);
//                       }
//                     });
//                   },
//                   elevatedButtonText: "ADD ADDRESS TO PROCCED"),
//             ],
//           ),
//           SizedBox(height: 10.sh())
//         ],
//       ),
//     );
//   }
// }
