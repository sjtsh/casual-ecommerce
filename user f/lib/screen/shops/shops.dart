// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/shops/components/shopbox.dart';
// import 'package:ezdeliver/screen/shops/service/shopservice.dart';

// class Shops extends ConsumerWidget {
//   const Shops({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final shopService = ref.read(shopServiceProvider);
//     final shops = ref.watch(shopServiceProvider).shops;

//     return Column(
//       children: [
//         Expanded(
//             child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.sw()),
//           child:

//               // ListView.separated(
//               //     itemBuilder: (context, index) {
//               //       return ShopBox(shop: shops[index]);
//               //     },
//               //     separatorBuilder: (context, index) {
//               //       return SizedBox(height: 20.sh());
//               //     },
//               //     itemCount: shops.length)

//               GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1,
//                       mainAxisSpacing: 15.sw(),
//                       crossAxisSpacing: 15.sw()),
//                   itemBuilder: (context, index) {
//                     return ShopBox(shop: (shops[index]));
//                   },
//                   itemCount: shops.length),
//         ))
//       ],
//     );
//   }
// }
