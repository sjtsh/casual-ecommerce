import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

import '../ApiService.dart';
import '../Entities/ShopCategory.dart';

class SignUpService {
  Future<bool> signUp(
      String name,
      String ownerName,
      String phone,
      String imgUrl,
      String password,
      String pan,
      String address,
      Position position,
      List<ShopCategory> categories) async {
    Response? res = await ApiService.post("shop",
        body: {
          "name": name,
          "owner": ownerName,
          'phone': phone,
          'password': password,
          'pan': pan.isEmpty ? null : pan,
          'img': [imgUrl],
          'categories': categories.map((e) => e.id).toList(),
          'location': {
            "coordinates": [position.longitude, position.latitude]
          }
        },
        withToken: false);
    return res != null;
  }

  Future<bool> changeDeliveryRadius(double radius) async {
    Response? res = (await ApiService.get("shop/radius/$radius"));
    return res != null;
  }
}
