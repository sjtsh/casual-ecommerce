
// To parse this JSON data, do
//
//     final subCategoyProductList = subCategoyProductListFromJson(jsonString);

import 'package:ezdeliver/screen/models/productModel.dart';

import 'dart:convert';

List<SubCategoyProduct> subCategoyProductListFromJson(String str) =>
    List<SubCategoyProduct>.from(
        json.decode(str).map((x) => SubCategoyProduct.fromJson(x)));

String subCategoyProductListToJson(List<SubCategoyProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubCategoyProduct {
  SubCategoyProduct({
    required this.id,
    required this.category,
    required this.name,
    required this.image,
    required this.products,
  });

  final String id;
  final String category;
  final String name;
  final String image;
  final List<Product> products;

  SubCategoyProduct copyWith({
    required String id,
    required String category,
    required String name,
    required String image,
    required List<Product> products,
  }) =>
      SubCategoyProduct(
        id: id,
        category: category,
        name: name,
        image: image,
        products: products,
      );

  factory SubCategoyProduct.fromJson(Map<String, dynamic> json) =>
      SubCategoyProduct(
        id: json["_id"],
        category: json["category"],
        name: json["name"],
        image: json["image"],
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "category": category,
        "name": name,
        "image": image,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}
