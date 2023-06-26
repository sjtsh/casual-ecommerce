// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/models/shop.dart';
// // import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// final ratingProvider = StateProvider<double>((ref) {
//   return 0.0;
// });

// class ShopBox extends ConsumerWidget {
//   const ShopBox({super.key, required this.shop});
//   final Shop shop;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final rating = ref.watch(ratingProvider.state).state;

//     return

//         // ListTile(
//         //   leading: Image.network(
//         //       "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Shop.svg/542px-Shop.svg.png?20100805171502"),
//         //   title: Text(shop.name,
//         //       style: kTextStyleIbmSemiBold.copyWith(
//         //           color: blackColor, fontSize: 18.ssp())),
//         //   subtitle: Text('${((shop.distance!) / 1000).toInt().toString()} km'),
//         // );

//         Container(
//       decoration: BoxDecoration(
//         color: Colors.transparent,
//       ),
//       child: Column(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             // flex: ,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: PhysicalModel(
//                   color: blackColor.withOpacity(0.5),
//                   elevation: 5,
//                   child: Image.asset("assets/images/shop.png")),
//             ),
//           ),
//           SizedBox(
//             height: 8.sh(),
//           ),
//           Expanded(
//             // flex: 4,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Text(
//                     shop.name,
//                     style: kTextStyleIbmSemiBold.copyWith(
//                         color: blackColor, fontSize: 18.ssp()),
//                   ),
//                   Text('${((shop.distance!) / 1000).toInt().toString()} km'),
//                   // RatingBar(
//                   //     itemSize: 15,
//                   //     initialRating: rating,
//                   //     direction: Axis.horizontal,
//                   //     allowHalfRating: true,
//                   //     itemCount: 5,
//                   //     ratingWidget: RatingWidget(
//                   //         full: Icon(
//                   //           Icons.star,
//                   //           color: Colors.orange,
//                   //           size: 8.ssp(),
//                   //         ),
//                   //         half: Icon(
//                   //           Icons.star_half,
//                   //           color: Colors.orange,
//                   //           size: 8.ssp(),
//                   //         ),
//                   //         empty: Icon(
//                   //           Icons.star_outline,
//                   //           color: Colors.orange,
//                   //           size: 8.ssp(),
//                   //         )),
//                   //     onRatingUpdate: (value) {
//                   //       print(value);
//                   //       ref.read(ratingProvider.state).state = value;
//                   //     }),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
