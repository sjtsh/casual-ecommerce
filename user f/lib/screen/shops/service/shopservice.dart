// import 'dart:collection';

// import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/models/shop.dart';
// import 'package:ezdeliver/services/location.dart';

// final shopServiceProvider = ChangeNotifierProvider<ShopService>((ref) {
//   return ShopService._();
// });

// class ShopService extends ChangeNotifier {
//   ShopService._() {
//     load();
//   }

//   final List<Shop> _shops = [];

//   List<Shop> get shops => UnmodifiableListView(_shops);

//   load() async {
//     try {
//       Position position = await CustomLocation.determinePosition();

//       var response = await client.get(
//         Uri.parse(
//             "${Api.baseUrl}shop/nearby?lat=${position.latitude}&lon=${position.longitude}&max_dist=10000000"),
//         headers: header(),
//       );
//       if (response.statusCode == 200) {
//         _shops.clear();
//         _shops.addAll(shopFromJson(response.body));
//         notifyListeners();
//       } else {
//         print(response.body);
//         throw 'Error';
//       }
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }
// }
