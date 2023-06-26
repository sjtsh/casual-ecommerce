import 'dart:convert';

import 'package:ezdeliver/screen/models/bannerModel.dart';

List<SubCategory> subCategoryFromJson(String str) => List<SubCategory>.from(
    json.decode(str).map((x) => SubCategory.fromJson(x)));

String subCategoryToJson(List<SubCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubCategory {
  SubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    this.createdAt,
    this.updatedAt,
    required this.categoryId,
    this.banners = const [],
    this.v,
  });

  final String id;
  final String name;
  final String category;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String categoryId;
  final int? v;
  final List<BannerModel> banners;

  SubCategory copyWith(
          {String? id,
          String? name,
          String? image,
          String? category,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? categoryId,
          int? v,
          List<BannerModel>? banners}) =>
      SubCategory(
          id: id ?? this.id,
          name: name ?? this.name,
          image: image ?? this.image,
          category: category ?? this.category,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          categoryId: categoryId ?? this.categoryId,
          v: v ?? this.v,
          banners: banners ?? this.banners);

  factory SubCategory.fromJson(Map<String, dynamic> json, {String? id}) {
    return SubCategory(
      id: json["_id"],
      name: json["name"],
      image: json["image"],
      banners: json["banners"] != null
          ? List.from(json["banners"].map((e) => BannerModel.fromJson(e)))
          : [],
      category: json["category"] ?? id ?? "",
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      categoryId: json["id"].toString(),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        "category": category,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "id": categoryId,
        "__v": v,
      };
}
