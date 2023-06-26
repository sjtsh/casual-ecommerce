// To parse this JSON data, do
//
//     final deviceModel = deviceModelFromJson(jsonString);

import 'dart:convert';

List<DeviceModel> deviceModelFromJson(String str) => List<DeviceModel>.from(
    json.decode(str).map((x) => DeviceModel.fromJson(x)));

String deviceModelToJson(List<DeviceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeviceModel {
  DeviceModel({
    this.id,
    required this.os,
    required this.deviceId,
    required this.fcmToken,
    required this.version,
    required this.notify,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String os;
  final String deviceId;
  final String fcmToken;
  final String version;
  final bool notify;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeviceModel copyWith({
    required String id,
    required String os,
    required String deviceId,
    required String fcmToken,
    required String version,
    required bool notify,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) =>
      DeviceModel(
        id: id,
        os: os,
        deviceId: deviceId,
        fcmToken: fcmToken,
        version: version,
        notify: notify,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json["_id"],
        os: json["os"],
        deviceId: json["deviceId"],
        fcmToken: json["fcmToken"],
        version: json["version"],
        notify: json["notify"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        // "_id": id,
        "os": os,
        "deviceId": deviceId,
        "fcmToken": fcmToken,
        "version": version,
        "notify": notify,
        // "createdAt": createdAt!.toIso8601String(),
        // "updatedAt": updatedAt!.toIso8601String(),
      };
}
