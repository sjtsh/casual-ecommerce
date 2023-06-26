import 'package:http/http.dart';

import '../../ApiService.dart';

class EditProfileService {
  Future<bool> editProfile(
      {String? owner, String? phone, List<String>? categories}) async {
    Map<String, dynamic> json = {};
    if (owner != null) json["owner"] = owner;
    if (phone != null) json["phone"] = phone;
    if (categories != null) json["categories"] = categories;
    Response? res = await ApiService.put("edit/shop", body: json);
    return res != null;
  }

  Future<int?> checkEditValidity(String key) async {
    Response? res = await ApiService.get("edit/shop/$key");
    if (res == null) throw "unhandled";
    return int.tryParse(res.body);
  }

  Future<bool> changeProfilePassword(String password) async {
    Response? res = await ApiService.put("shop", body: {
      "password": password,
    });
    return res != null;
  }
}
