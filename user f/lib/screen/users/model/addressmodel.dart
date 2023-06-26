// To parse this JSON data, do
//
//     final addressModel = addressModelFromJson(jsonString);

import 'package:ezdeliver/screen/models/shop.dart';
import 'dart:convert';

List<AddressModel> addressModelFromJson(String str) => List<AddressModel>.from(
    json.decode(str).map((x) => AddressModel.fromJson(x)));

String addressModelToJson(List<AddressModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddressModel {
  AddressModel({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.fullAddress,
    required this.label,
    required this.location,
    this.saved = false,
    this.id,
    this.current = true,
  });

  String fullName;
  String phone;
  String address;
  String fullAddress;
  String label;
  Location location;
  bool saved, current;
  String? id;

  AddressModel copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? fullAddress,
    String? label,
    Location? location,
    String? id,
    bool? saved,
    bool? current,
  }) =>
      AddressModel(
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        fullAddress: fullAddress ?? this.fullAddress,
        label: label ?? this.label,
        location: location ?? this.location,
        id: id ?? this.id,
        saved: saved ?? this.saved,
        current: current ?? this.current,
      );

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
      fullName: json["fullName"],
      phone: json["phone"],
      address: json["address"],
      fullAddress: json["fullAddress"],
      label: json["label"],
      location: Location.fromJson(json["location"]),
      id: json["_id"],
      saved: true);

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "phone": phone,
        "address": address,
        "fullAddress": fullAddress,
        "label": label,
        "location": location.toJson(),
        "_id": id,
      };
  static AddressModel empty() {
    return AddressModel(
        fullName: "",
        phone: "",
        address: "",
        fullAddress: "",
        label: "",
        location: Location(coordinates: []));
  }

  static bool checkValidAddress(AddressModel model) {
    if (model.fullName.isNotEmpty &&
        model.phone.isNotEmpty &&
        model.address.isNotEmpty &&
        model.label.isNotEmpty) return true;
    return false;
  }
}
