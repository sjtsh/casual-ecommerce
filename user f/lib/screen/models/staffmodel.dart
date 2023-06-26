// To parse this JSON data, do
//
//     final staff = staffFromJson(jsonString);

import 'dart:convert';

Staff staffFromJson(String str) => Staff.fromJson(json.decode(str));

String staffToJson(Staff data) => json.encode(data.toJson());

class Staff {
  Staff({
    required this.id,
    required this.name,
    required this.phone,
    this.avgRating,
    this.rateCount,
    required this.ratingStar,
  });

  final String id;
  final String name;
  final String phone;
  double? avgRating;
  int? rateCount;
  final List<int> ratingStar;

  Staff copyWith({
    required String id,
    required String name,
    required String phone,
    required double avgRating,
    required int raterCount,
    required List<int> ratingStar,
  }) =>
      Staff(
        id: id,
        name: name,
        phone: phone,
        avgRating: avgRating,
        rateCount: rateCount,
        ratingStar: ratingStar,
      );

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        avgRating: json["avgRating"] + 0.0 ?? 0,
        rateCount: json["raterCount"] ?? 0,
        ratingStar: List<int>.from(json["ratingStar"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "avgRating": avgRating,
        "raterCount": rateCount,
        "ratingStar": List<dynamic>.from(ratingStar.map((x) => x)),
      };
}
