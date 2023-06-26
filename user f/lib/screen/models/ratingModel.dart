// To parse this JSON data, do
//
//     final ratingModel = ratingModelFromJson(jsonString);

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/users/model/user.dart';

RatingModelWithStat ratingModelWithStat(String str) =>
    RatingModelWithStat.fromJson(json.decode(str));

class RatingModelWithStat {
  RatingModelWithStat({required this.ratings, required this.starCounts});
  final List<RatingModel> ratings;
  final List<int> starCounts;

  factory RatingModelWithStat.fromJson(Map<String, dynamic> json) =>
      RatingModelWithStat(
          ratings: List<RatingModel>.from(
              json["reviews"].map((x) => RatingModel.fromJson(x))),
          starCounts: List<int>.from(json["stats"]));
}

List<RatingModel> ratingModelFromJson(String str) => json.decode(str) == null
    ? []
    : List<RatingModel>.from(
        json.decode(str)!.map((x) => RatingModel.fromJson(x)));

String ratingModelToJson(List<RatingModel?>? data) => json.encode(
    data == null ? [] : List<dynamic>.from(data.map((x) => x!.toJson())));

class RatingModel {
  RatingModel({
    required this.id,
    this.ratingByUser,
    this.ratingByShop,
    this.reviewByUser,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final String id;
  final int? ratingByUser;
  final int? ratingByShop;
  final String? reviewByUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;

  RatingModel copyWith({
    required String id,
    int? ratingByUser,
    int? ratingByShop,
    String? reviewByUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) =>
      RatingModel(
        id: id,
        ratingByUser: ratingByUser ?? this.ratingByUser,
        ratingByShop: ratingByShop ?? this.ratingByShop,
        reviewByUser: reviewByUser ?? this.reviewByUser,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        user: user ?? this.user,
      );

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        id: json["_id"],
        ratingByUser: json["ratingByUser"],
        ratingByShop: json["ratingByShop"],
        reviewByUser: json["reviewByUser"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        user: json["user"] == null
            ? null
            : json["user"] is String
                ? User.fromJson({
                    "_id": json["user"],
                    "name": CustomKeys.ref
                        .read(userChangeProvider)
                        .loggedInUser
                        .value!
                        .name
                  })
                : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "ratingByUser": ratingByUser,
        "ratingByShop": ratingByShop,
        "reviewByUser": reviewByUser,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "user": user!.toJson(),
      };
}
