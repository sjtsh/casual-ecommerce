import 'dart:convert';
import '../Enums/ServerService.dart';
import 'MyProduct.dart';

List<SearchProduct> productFromJson(String str) => List<SearchProduct>.from(
    json.decode(str).map((x) => SearchProduct.fromJson(x)));

String productToJson(List<SearchProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchProduct {
  final String id;
  final String name;
  final double price;
  final String? image;
  // final List<String> tags;
  final String? staff;
  final String category;
  final String? categoryName;
  final double? sku;
  final String? unit;
  final int? margin;
  final int? returnPolicy;
  final String? barcode;
  MyProduct? myProduct;
  final String displayId;

  SearchProduct(
      {
      required this.id,
      required this.name,
      required this.price,
      required this.category,
      this.image,
      this.staff,
      this.unit,
      this.margin,
      this.returnPolicy,
      this.barcode,
      // required this.tags,
      this.sku,
      this.myProduct,
      this.categoryName,
      required this.displayId});

  factory SearchProduct.fromJson(Map<String, dynamic> json,
      {bool server = false}) {
    List<dynamic> tags = json["tags"];
    Map<String, dynamic>? myPr;
    var prodParsable = json["product"];
    if (prodParsable is List) {
      myPr = (prodParsable.isEmpty ? null : prodParsable[0]);
    } else {
      myPr = prodParsable;
    }
    Map<String, dynamic>? categoryInfo = json["category_info"];
    return SearchProduct(
        id: json["_id"],
        name: json["name"],
        price: json["price"] +0.0,
        category: json["category"],
        image: json["image"] == null
            ? null
            : (json["image"].replaceAll("localhost", ServerService.localUrl)),
        // tags: tags.map((e) => e.toString()).toList(),
        sku: json["sku"] == null ? null : (json["sku"] + 0.0 as double),
        returnPolicy: json["return"],
        barcode: json["barcode"],
        unit: json["unit"],
        categoryName: categoryInfo?["name"],
        margin: json["margin"],
        staff: json["staff"],
        myProduct: myPr == null
            ? null
            : MyProduct.fromJson(myPr, json["_id"], myPr["shop"]),
        displayId: json["id"]);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "category": category,
        "image": image,
        "staff": staff,
        "unit": unit,
        "margin": margin,
        "return": returnPolicy,
        "barcode": barcode,
        // "tags": tags,
        "sku": sku,
      };
}
