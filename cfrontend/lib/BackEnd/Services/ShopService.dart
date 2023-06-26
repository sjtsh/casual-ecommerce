import 'dart:convert';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/BackEnd/Services/EditProfileService/EditProfileService.dart';
import 'package:http/http.dart';
import '../ApiService.dart';

class ShopService {
  // Future<List<ShopCategory>> getShopCategory() async {
  //   Response? res = await ApiService.get("category", withToken: false);
  //   if (res == null) throw "handled";
  //   List<dynamic> categoryData = jsonDecode(res.body);
  //   return categoryData.map((e) => ShopCategory.fromJson(e)).toList();
  // }

  Future<List<SubCategory>> getSubCategory() async {
    Response? res = await ApiService.get("staff/product/subcategory",);
    if (res == null) throw "handled";
    List<dynamic> categoryData = jsonDecode(res.body);
    return categoryData.map((e) => SubCategory.fromJson(e)).toList();
  }

  Future<List<String>> getUnits() async {
    Response? res = await ApiService.get("staff/product/unit", );
    if (res == null) throw "handled";
    return List<String>.from(json.decode(res.body).map((x) => x)) ;
  }

  Future<bool> updateShopCategories(List<String> categories) async {
    return await EditProfileService().editProfile(categories: categories);
  }

  Future<bool> changeRingtone(bool ringtone) async {
    Response? res = await ApiService.get("shop/ringtone/$ringtone");
    return res != null;
  }

  Future<bool> getRingtone() async {
    Response? res = await ApiService.get("shop/getringtone");
    if (res == null) throw "handled";
    return jsonDecode(res.body) == "true";
  }

  Future<bool> changeShopImage(String img, String address) async {
    Response? res = await ApiService.put("staff/img",
    body: {
        "img":img,
      "address" :address
    });
    return res!=null;
  }

}
