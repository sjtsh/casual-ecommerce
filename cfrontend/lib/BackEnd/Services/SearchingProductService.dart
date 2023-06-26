import 'dart:convert';
import 'package:ezdelivershop/BackEnd/Services/ProductService.dart';
import 'package:http/http.dart';
import '../ApiService.dart';
import '../Entities/SearchProduct.dart';

class SearchingProductService {

  Future<List<SearchProduct>> searchProducts(String query, int length, int limit) async {
    print(ProductCrudService.shopId);
    Response? response =
        await ApiService.get("staff/product/search?s=$query&skip=$length&limit=$limit&shop=${ProductCrudService.shopId}");
    if (response != null) {
      List<dynamic> parsable = jsonDecode(response.body);
      List<SearchProduct> data =
          parsable.map((e) => SearchProduct.fromJson(e)).toList();
      return data;
    } else {
      throw "Some Error Occurred";
    }
  }
}
