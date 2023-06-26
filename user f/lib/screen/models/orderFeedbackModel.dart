// To parse this JSON data, do
//
//     final orderFeedback = orderFeedbackFromJson(jsonString);

import 'package:ezdeliver/screen/models/orderModel.dart';
import 'dart:convert';

Feedback orderFeedbackFromJson(String str) {
  Map<String, dynamic> parsable = json.decode(str);
  return Feedback.fromJson(parsable["feedback"], parsable["order_id"]);
}

String orderFeedbackToJson(Feedback data) => json.encode(data.toJson());

class Feedback {
  Feedback(
      {required this.shop,
      required this.status,
      required this.deliveryTime,
      required this.deliveryCharge,
      required this.items,
      required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.orderId,
      required this.distance,
      this.total = 0});

  final String shop;
  final int status;
  final int deliveryTime;
  final int deliveryCharge;
  final double distance;
  final List<OrderItem> items;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String orderId;
  double total;

  Feedback copyWith(
          {required String shop,
          required int status,
          required int deliveryTime,
          required int deliveryCharge,
          required double distance,
          required List<OrderItem> items,
          required String id,
          required DateTime createdAt,
          required DateTime updatedAt,
          required String orderId}) =>
      Feedback(
          shop: shop,
          status: status,
          deliveryTime: deliveryTime,
          deliveryCharge: deliveryCharge,
          distance: distance,
          items: items,
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          orderId: orderId);

  factory Feedback.fromJson(Map<String, dynamic> json, String orderId) {
    var total = 0;
    var feedback = Feedback(
        shop: json["shop"],
        status: json["status"],
        deliveryTime: json["deliveryTime"],
        deliveryCharge: json["deliveryCharge"],
        distance: json["distance"],
        items: List<OrderItem>.from(
            json["items"].map((x) => OrderItem.fromJson(x))),
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        orderId: orderId,
        total: 0.0);
    if (feedback.items.isNotEmpty) {
      for (var element in feedback.items) {
        total += element.total;
      }
    }
    feedback.total = total.toDouble();
    return feedback;
  }

  Map<String, dynamic> toJson() => {
        "shop": shop,
        "status": status,
        "deliveryTime": deliveryTime,
        "deliveryCharge": deliveryCharge,
        "distance": distance,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "_id": id,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "order_id": orderId,
      };
}
