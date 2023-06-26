// To parse this JSON data, do
//
//     final shop = shopFromJson(jsonString);

import 'dart:convert';

List<Shop> shopFromJson(String str) =>
    List<Shop>.from(json.decode(str).map((x) => Shop.fromJson(x)));

String shopToJson(List<Shop> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Shop {
  Shop({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
    this.location,
    this.available = false,
    this.distance,
    this.createdAt,
    this.updatedAt,
    this.shopId = 0,
    this.avgRating,
    this.rateCount,
    this.v,
  });

  final String id;
  final String name;
  final List<String> image;
  final double? distance;
  final String phone;
  final Location? location;
  final bool available;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int shopId;
  double? avgRating;
  int? rateCount;
  final int? v;

  Shop copyWith({
    required String id,
    required String name,
    required List<String> image,
    required String phone,
    Location? location,
    required bool available,
    double? distance,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int shopId,
    int? v,
  }) =>
      Shop(
        id: id,
        name: name,
        image: image,
        phone: phone,
        location: location ?? this.location,
        available: available,
        distance: distance ?? this.distance,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        shopId: shopId,
        v: v ?? this.v,
      );

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json["_id"],
        name: json["name"],
        image: json["img"] == null
            ? []
            : List<String>.from(json["img"].map((x) => x.toString())),
        phone: json["phone"],
        location: json["location"] != null
            ? Location.fromJson(json["location"])
            : null,
        available: json["available"] ?? false,
        distance: json["distance"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        shopId: json["id"] ?? 0,
        v: json["__v"],
        avgRating: json["avgRating"] != null
            ? double.parse(json["avgRating"].toString())
            : 0.0,
        rateCount: json["raterCount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "location": location!.toJson(),
        "available": available,
        "distance": distance,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "id": shopId,
        "__v": v,
        "avgRating": avgRating,
        "raterCount": rateCount
      };
}

class Location {
  Location({
    this.type = "Point",
    required this.coordinates,
  });

  final String type;
  final List<double> coordinates;

  Location copyWith({
    required String type,
    required List<double> coordinates,
  }) =>
      Location(
        type: type,
        coordinates: coordinates,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"] ?? "Point",
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}
