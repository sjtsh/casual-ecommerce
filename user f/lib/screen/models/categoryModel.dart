// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

import 'package:ezdeliver/screen/models/subCategoryModel.dart';

List<Category> categoryFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Category(
      {required this.id,
      required this.name,
      required this.image,
      this.subcategories,
      this.createdAt,
      this.updatedAt,
      required this.categoryId,
      this.v,
      this.favourite = false});

  final String id;
  final String name;
  final String image;
  final List<SubCategory>? subcategories;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? categoryId;
  final int? v;
  bool favourite;

  Category copyWith({
    required String id,
    required String name,
    required String image,
    List<SubCategory>? subcategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String? categoryId,
    required favourite,
    int? v,
  }) =>
      Category(
        id: id,
        name: name,
        image: image,
        subcategories: subcategories,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        categoryId: categoryId,
        favourite: favourite,
        v: v ?? this.v,
      );

  factory Category.fromJson(Map<String, dynamic> json, {bool server = false}) =>
      Category(
          id: json["_id"],
          name: json["name"],
          image: json["image"] ?? "",
          subcategories: json["subcategories"] != null
              ? List<SubCategory>.from(json["subcategories"]
                  .map((x) => SubCategory.fromJson(x, id: json["_id"])))
              : [],
          createdAt: json["createdAt"] != null
              ? DateTime.parse(json["createdAt"])
              : null,
          updatedAt: json["updatedAt"] != null
              ? DateTime.parse(json["updatedAt"])
              : null,
          categoryId: json["id"].toString(),
          v: json["__v"],
          favourite: server ? true : json["favourite"] ?? false);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        // "subcategories":
        //     List<dynamic>.from(subcategories!.map((x) => x.toJson())),
        "createdAt": createdAt != null
            ? createdAt!.toIso8601String()
            : DateTime.now().toIso8601String(),
        "updatedAt": createdAt != null
            ? updatedAt!.toIso8601String()
            : DateTime.now().toIso8601String(),
        "id": categoryId,
        "favourite": favourite,
        "__v": v,
      };

  static empty() => Category(id: '', name: '', image: '', categoryId: "0");

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) {
  //     return true;
  //   }
  //   if (other.runtimeType != runtimeType) {
  //     return false;
  //   }
  //   return other is Category && other.id == id && other.name == name;
  // }

  // @override
  // int get hashCode => super.hashCode;
}
