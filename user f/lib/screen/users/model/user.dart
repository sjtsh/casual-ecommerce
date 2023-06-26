// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

User userFromJson(String str, {bool server = true}) =>
    User.fromJson(json.decode(str), server: server);

String userToJson(User data) => json.encode(data.toJson());

class User {
  User(
      {required this.id,
      required this.name,
      required this.phone,
      this.createdAt,
      this.updatedAt,
      required this.userId,
      required this.v,
      required this.accessToken,
      required this.refreshToken,
      this.avgRating,
      this.rateCount,
      required this.address,
      required this.countryCode,
      required this.favourites});

  String id;
  String name;
  String phone;
  String countryCode;
  List<AddressModel> address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId;
  final int? v;
  String? accessToken;
  String? refreshToken;
  Favourites favourites;
  double? avgRating;
  int? rateCount;

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    List<AddressModel>? address,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    String? refreshToken,
    String? userId,
    double? avgRating,
    int? rateCount,
    int? v,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        address: address ?? this.address,
        createdAt: createdAt,
        updatedAt: updatedAt,
        userId: userId ?? this.userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        favourites: favourites,
        v: v ?? this.v,
      );

  factory User.fromJson(Map<String, dynamic> json, {bool server = true}) =>
      User(
          id: json["_id"],
          name: json["name"],
          phone: json["phone"] ?? "",
          countryCode: json["phone"] ?? "",
          address: json["address"] == null
              ? []
              : List<AddressModel>.from(
                  json["address"].map((x) => AddressModel.fromJson(x))),
          // ignore: unnecessary_null_in_if_null_operators

          createdAt: json["createdAt"] != null
              ? DateTime.parse(json["createdAt"])
              : null,
          updatedAt: json["updatedAt"] != null
              ? DateTime.parse(json["updatedAt"])
              : null,
          userId: json["id"].toString(),
          v: json["__v"],
          accessToken: json["accessToken"],
          refreshToken: json["refreshToken"],
          avgRating: json["avgRating"] != null
              ? double.parse(json["avgRating"].toString())
              : 0,
          rateCount: json["raterCount"],
          favourites: json["favourites"] != null
              ? Favourites.fromJson(json["favourites"], server: server)
              : Favourites.empty());

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "countryCode": countryCode,
        "address": List<dynamic>.from(address.map((x) => x.toJson())),
        "favourites": favourites.toJson(),
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "id": userId,
        "__v": v,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "avgRating": avgRating,
        "rateCount": rateCount
      };
}

class Favourites {
  Favourites({
    this.products = const [],
    this.categories = const [],
  });

  List<Product> products;
  List<Category> categories;

  // Favourites copyWith({
  //   List<Product> products =  [],
  //   List<Category> categories = const [],
  // }) =>
  //     Favourites(
  //       products: products,
  //       categories: categories,
  //     );

  factory Favourites.fromJson(Map<String, dynamic> json,
          {bool server = true}) =>
      Favourites(
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x, server: server))),
        categories: List<Category>.from(json["categories"]
            .map((x) => Category.fromJson(x, server: server))),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };

  static empty() {
    return Favourites(categories: [], products: []);
  }
}
