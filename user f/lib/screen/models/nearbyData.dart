import 'dart:convert';

import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';

NearbyData nearbyDataFromJson(String str) =>
    NearbyData.fromJson(json.decode(str));

String nearbyDataToJson(NearbyData data) => json.encode(data.toJson());

class NearbyData {
  NearbyData({
    required this.categories,
    required this.subcategories,
    required this.trending,
  });

  final List<Category> categories;
  final List<SubCategory> subcategories;
  final List<TrendingProductModel> trending;

  NearbyData copyWith({
    required List<Category> categories,
    required List<SubCategory> subcategories,
    required List<TrendingProductModel> trending,
  }) =>
      NearbyData(
          categories: categories,
          subcategories: subcategories,
          trending: trending);

  factory NearbyData.fromJson(Map<String, dynamic> json) => NearbyData(
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
        subcategories: List<SubCategory>.from(
            json["subcategories"].map((x) => SubCategory.fromJson(x))),
        trending: List<TrendingProductModel>.from(
            json["trending"].map((x) => TrendingProductModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "subcategories":
            List<dynamic>.from(subcategories.map((x) => x.toJson())),
      };
}
