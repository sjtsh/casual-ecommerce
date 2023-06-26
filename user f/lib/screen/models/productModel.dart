// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

// To parse this JSON data, do
//
//     final trendingProductModel = trendingProductModelFromJson(jsonString);

List<TrendingProductModel> trendingProductModelFromJson(String str) =>
    List<TrendingProductModel>.from(
        json.decode(str).map((x) => TrendingProductModel.fromJson(x)));

String trendingProductModelToJson(List<TrendingProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TrendingProductModel {
  TrendingProductModel({
    required this.id,
    required this.count,
    required this.product,
  });

  final String id;
  final int count;
  final Product product;

  TrendingProductModel copyWith({
    required String id,
    required int count,
    required Product product,
  }) =>
      TrendingProductModel(
        id: id,
        count: count,
        product: product,
      );

  factory TrendingProductModel.fromJson(Map<String, dynamic> json) =>
      TrendingProductModel(
        id: json["_id"],
        count: json["count"],
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "count": count,
        "product": product.toJson(),
      };
}

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.weight,
      required this.category,
      required this.image,
      this.unit = "",
      this.sku = 0,
      this.limit = 20,
      this.oldPrice = 0,
      this.oldCount = 0,
      this.createdAt,
      this.updatedAt,
      this.productId,
      this.v,
      this.favourite = false,
      this.deactivated = false});

  final String id;
  final String name;
  final String unit;
  final int price;
  final int limit;
  final double sku;
  int oldPrice;
  final String weight;
  int oldCount;
  final String category;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? productId;
  final int? v;
  bool favourite;
  bool deactivated;
  Product copyWith({
    required String id,
    required String name,
    required String unit,
    required int price,
    required double sku,
    required int limit,
    required String weight,
    required String category,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String? productId,
    required favourite,
    int? v,
  }) =>
      Product(
        id: id,
        name: name,
        unit: unit,
        sku: sku,
        limit: limit,
        price: price,
        weight: weight,
        category: category,
        image: image,
        createdAt: createdAt,
        updatedAt: updatedAt,
        productId: productId,
        favourite: favourite,
        v: v ?? this.v,
      );

  factory Product.fromJson(Map<String, dynamic> json, {bool server = false}) {
    //// print(json);

    // String name = json["name"];
    // var list = name.split(" ");
    // final length = list.length;
    // String finalWeight = '';
    // List<String> items = [];
    // int? index;
    // // try {
    // //   for (int i = length - 1; i > length - 3; i--) {
    // //     if (list[i].startsWith(RegExp(r'[0-9]'))) {
    // //       index = i;
    // //       break;
    // //     }
    // //   }
    // //   if (index != null) {
    // //     for (int i = index; i < list.length; i++) {
    // //       items.add(list[i]);
    // //     }
    // //   }

    // //   if (items.isEmpty) {
    // //     finalWeight = "";
    // //   } else {
    // //     finalWeight = items.join(" ");
    // //   }
    // // } catch (e, s) {
    // //   print('$e $s');
    // // }
    return Product(
      id: json["_id"],
      name: json["name"],
      price: double.parse(json["price"].toString()).toInt(),
      // weight: json["weight"]??0,
      weight: '',
      category: json["category"] ?? "",
      unit: json["unit"] ?? "",
      sku: json["sku"] != null ? json["sku"] + 0.0 : 0.0,
      image: json["image"] ?? "",
      deactivated: json["deactivated"] ?? false,
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      productId: json["id"].toString(),
      favourite: server ? true : json["favourite"] ?? false,
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "unit": unit,
        "sku": sku,
        "price": price,
        "weight": weight,
        "image": image,
        "category": category,
        "favourite": favourite,
        "deactivated": deactivated,
        // "createdAt": createdAt!.toIso8601String(),
        // "updatedAt": updatedAt!.toIso8601String(),
        // "id": productId,
        "__v": v,
      };

  static Product empty() =>
      Product(id: "", name: "", price: 0, weight: "", category: "", image: "");
}
