import 'dart:convert';
import 'package:ezdelivershop/BackEnd/ApiService.dart';
import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/Components/keys.dart';
import 'package:ezdelivershop/StateManagement/NotSearchingProductManagement.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:provider/provider.dart';
import '../Entities/Product.dart';
import 'package:http/http.dart';

import '../Enums/Approval.dart';

class ProductCrudService {
  String generateQueryWithFilter(
      {bool? activated, required List<Approval> verified}) {
    List<int>? filterApproved = generateListInt(verified);
    String url = "";
    if (activated != null) {
      activated ? url += "&activated=1" : url += "&activated=0";
    }
    if (filterApproved != null) url += "&approved=${filterApproved.join(".")}";
    return url;
  }

  String generateQueryWithFilterWithQuestion(
      { required List<Approval> verified}) {
    List<int>? filterApproved = generateListInt(verified);
    String url = "?shop=${ProductCrudService.shopId}";
    if (filterApproved != null) url += "&approved=${filterApproved.join(".")}";
    return url;
  }

  List<int>? generateListInt(List<Approval> filterApproved) {
    List<int> verified = filterApproved.map((e) => e.toInt()).toList();
    if (verified.isEmpty || verified.length == 3) return null;
    return verified;
  }

  Future<MapEntry<int, int>> getTabCounts(
      {required List<Approval> verified}) async {
    String url = "staff/product/count";
    url += generateQueryWithFilterWithQuestion(verified: verified);
    Response? res = await ApiService.get(url);
    if (res == null) throw "handled";
    Map<String, dynamic> parsable = jsonDecode(res.body);
    return MapEntry(parsable["activated"], parsable["deactivated"]);
  }

  Future<Product> getProduct(String id, {required String shopId}) async {
    Response? res = await ApiService.get("staff/product/$id?shop=$shopId");
    if (res == null) throw "handled";
    Map<String, dynamic> parsable = jsonDecode(res.body);

    return Product.fromJson(parsable);
  }

  Future<MyProduct> deactivateProd(bool deactivated, String productID,
      {String? remarks}) async {
    //remarks
    //reference
    Response? res = await ApiService.put(
        "staff/product/deactivate/$productID?deactivated=${deactivated ? 1 : 0}",
        body: {"remarks": remarks ?? "Product Available"});

    if (res == null) throw "handled";
    Map<String, dynamic> parsable = jsonDecode(res.body);
    return MyProduct.fromJson(parsable, parsable["master"], parsable["shop"]);
  }

  Future<MyProduct> updateProduct(
      {String? barcode,
      required MyProduct product,
      required String name,
      required double price,
      required int margin,
      double? SKU,
      double? weight,
      required String unit,
      String? image,
      required String subcategoryId,
      required int salesReturnPolicy,
      required String remarks,
      String? remarksUrl,
      List<String>? tags}) async {
    // print({"remarks": remarks, "reference": remarksUrl});
    Response? res = await ApiService.put("staff/product/${product.id}", body: {
      "barcode": barcode,
      "name": name,
      "price": price,
      "unit": unit,
      "margin": margin,
      "image": image,
      "sku": SKU,
      "category": subcategoryId,
      "return": salesReturnPolicy,
      "tags": tags,
      "weight": weight,
      "remarks": remarks,
      "reference": remarksUrl
    });
    if (res == null) throw "handled";
    Map<String, dynamic> parsable = jsonDecode(res.body);
    return MyProduct.fromJson(parsable, parsable["master"], parsable["shop"]);
  }

  Future<MyProduct> createProduct(
      {
      String? barcode,
      String? remarksUrl,
      required String name,
      required double price,
      required int margin,
      double? SKU,
      double? weight,
      required String unit,
      String? image,
      String? remarks,
      required String subcategoryId,
      required int salesReturnPolicy,
      List<String>? tags}) async {
    Response? res = await ApiService.post("staff/product?shop=$shopId", body: {
      "barcode": barcode,
      "name": name,
      "price": price,
      "unit": unit,
      "margin": margin,
      "image": image,
      "sku": SKU,
      "category": subcategoryId,
      "return": salesReturnPolicy,
      "tags": tags,
      "weight": weight,
      "remarks": remarks,
      "reference": remarksUrl
    });
    if (res == null) throw "handled";
    Map<String, dynamic> parsable = jsonDecode(res.body);
    return MyProduct.fromJson(parsable, parsable["master"], parsable["shop"]);
  }

  Future<List<SearchProduct>> getProductByLength(
      int length, int limit, String subID,
      {bool? activated,
      required List<Approval> verified}) async {
    try {
      String url =
          "staff/product/subs/$subID?skip=$length&limit=$limit&shop=$shopId";
      url += generateQueryWithFilter(activated: activated, verified: verified);
      Response? res = await ApiService.get(url);
      if (res != null) {
        List<dynamic> prod = jsonDecode(res.body);

        return prod.map((e) => SearchProduct.fromJson(e)).toList();
      } else {
        throw "response.reasonPhrase";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubCategory>> getSubProductsByLength(int length, int limit,
      {
      bool? activated,
      required List<Approval> verified}) async {
    try {
      String url = "staff/product/subs?skip=$length&limit=$limit&shop=$shopId";
      url += generateQueryWithFilter(activated: activated, verified: verified);
      Response? res = await ApiService.get(url);
      if (res != null) {
        List<dynamic> prod = jsonDecode(res.body);

        return prod.map((e) => SubCategory.fromJson(e)).toList();
      } else {
        throw "response.reasonPhrase";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MyProduct> createMyProduct(SearchProduct master,
      {String? barcode,
      String? remarksUrl,
      required String name,
      required double price,
      required int margin,
      double? SKU,
      double? weight,
      required String unit,
      String? image,
      String? remarks,
      required String subcategoryId,
      required int salesReturnPolicy,
      List<String>? tags}) async {
    try {
      Response? res =
          await ApiService.post("staff/product/${master.id}?shop=$shopId", body: {
        "barcode": barcode,
        "name": name,
        "price": price,
        "unit": unit,
        "margin": margin,
        "image": image,
        "sku": SKU,
        "category": subcategoryId,
        "return": salesReturnPolicy,
        "tags": tags,
        "weight": weight,
        "remarks": remarks,
        "reference": remarksUrl
      });
      if (res != null) {
        Map<String, dynamic> parsable = jsonDecode(res.body);
        return MyProduct.fromJson(parsable, master.id, parsable["shop"]);
      } else {
        throw "response.reasonPhrase";
      }
    } catch (e) {
      rethrow;
    }
  }

  static String get shopId =>
      CustomKeys.messengerKey.currentContext!
          .read<NotSearchingProductManagement>()
          .shopId ??
      CustomKeys.messengerKey.currentContext!
          .read<SignInManagement>()
          .loginData!
          .staff
          .shop!
          .first
          .id;
}
