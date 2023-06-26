// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/ratingModel.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/models/staffmodel.dart';

import 'dart:convert';

import 'package:ezdeliver/screen/users/model/addressmodel.dart';

OrderHolderModel orderHolderModelFromJson(String str) =>
    OrderHolderModel.fromJson(json.decode(str));

String orderHolderModelToJson(OrderHolderModel data) =>
    json.encode(data.toJson());

class OrderHolderModel {
  OrderHolderModel({
    required this.today,
    required this.history,
  });

  final List<Order> today;
  final List<Order> history;

  OrderHolderModel copyWith({
    required List<Order> today,
    required List<Order> history,
  }) =>
      OrderHolderModel(
        today: today,
        history: history,
      );

  factory OrderHolderModel.fromJson(Map<String, dynamic> json) =>
      OrderHolderModel(
        today: List<Order>.from(json["today"].map((x) => Order.fromJson(x))),
        history:
            List<Order>.from(json["history"].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "today": List<dynamic>.from(today.map((x) => x.toJson())),
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

List<Order> orderFromJson(String str) =>
    List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(List<Order> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Order {
  Order(
      {this.id,
      required this.items,
      this.location,
      this.status = 0,
      this.updatedAt,
      this.total = 0,
      this.itemCount = 0,
      this.createdAt,
      this.verificationOTP,
      this.address,
      this.waitTime = 0,
      this.orderId,
      this.remarks,
      this.requestedShops = const [],
      this.fulfilled});

  String? id;
  String? remarks;
  final List<OrderItem> items;
  final Location? location;
  final AddressModel? address;
  bool? fulfilled;
  int status;
  int total;
  int itemCount;
  int waitTime;
  String? orderId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<RequestedShop> requestedShops;

  int? verificationOTP;

  Order copyWith({
    required String id,
    required List<OrderItem> items,
  }) =>
      Order(id: id, items: items, location: location);

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemCount = json["items"] is int ? json["items"] : 0;
    return Order(
      location:
          json["location"] != null ? Location.fromJson(json["location"]) : null,
      id: json["_id"],
      orderId: json["id"],
      waitTime: json["waitTime"] ?? 0,
      total: json["total"],
      remarks: json["remarks"],
      status: json["status"] ?? 0,
      fulfilled: json["fulfilled"] ?? true,
      address: json["address"] != null
          ? AddressModel.fromJson(json["address"])
          : null,
      verificationOTP:
          // ignore: prefer_if_null_operators
          json["verificationOTP"] != null ? json["verificationOTP"] : null,
      items: json["items"] is int
          ? []
          : List<OrderItem>.from(
              json["itemsAll"].map((x) => OrderItem.fromJson(x))),
      itemCount: itemCount,
      requestedShops: json["requestedShop"] == null
          ? []
          : List<RequestedShop>.from(
              json["requestedShop"].map((x) => RequestedShop.fromJson(x))),
      createdAt:
          DateTime.parse(json["createdAt"].toString().replaceAll("Z", ""))
              .add(const Duration(hours: 5, minutes: 45)),
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
    );
  }

  Map<String, dynamic> toJson({String? order}) => {
        // "_id": id,
        "order": order,
        "items": List<dynamic>.from(
          items.map((x) => x.toJson()),
        ),
        // "location": location!.toJson(),
        "address": address!.toJson(),
        "total": total,
        "remarks": remarks
      };
}

List<OrderItem> orderItemsFromJson(String str) =>
    List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromJson(x)));

String orderItemsToJson(List<OrderItem> data, {bool save = false}) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson(save: save))));

class OrderItem {
  OrderItem(
      {required this.itemCount,
      required this.product,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.itemId,
      this.total = 0});

  int itemCount;
  final Product product;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? itemId;
  int total;

  OrderItem copyWith({
    required int itemCount,
    required Product product,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int total = 0,
    int? itemId,
  }) =>
      OrderItem(
          itemCount: itemCount,
          product: product,
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          itemId: itemId,
          total: total);

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        itemCount: json["item_count"] is int ? json["item_count"] : 0,
        product: json["product"] is String
            ? empty(id: json["product"])
            : Product.fromJson(json["product"]),
        id: json["_id"],
        total: json["total"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        itemId: json["id"],
      );

  Map<String, dynamic> toJson({bool save = false}) => {
        "item_count": itemCount,
        "product": save ? product.toJson() : product.id,
        "total": total
        // "_id": id,
        // "createdAt": createdAt!.toIso8601String(),
        // "updatedAt": updatedAt!.toIso8601String(),
        // "id": itemId,
      };
  static Product empty({String id = ""}) {
    return Product(
      id: id,
      category: '',
      image: '',
      name: '',
      price: 0,
      weight: 0.toString(),
    );
  }
}

class RequestedShop {
  RequestedShop(
      {required this.id,
      required this.order,
      required this.shop,
      // required this.distance,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.v,
      required this.feedback,
      required this.staff,
      this.verficationOTP});

  final String id;
  final String order;
  final Shop shop;
  // final double distance;
  int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  int? verficationOTP;
  final Staff staff;
  final FeedbackModel feedback;

  RequestedShop copyWith({
    required String id,
    required String order,
    required Shop shop,
    // required double distance,
    required int status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int v,
    required FeedbackModel feedback,
    required Staff staff,
  }) =>
      RequestedShop(
        id: id,
        order: order,
        shop: shop,
        // distance: distance,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        v: v,
        feedback: feedback,
        staff: staff,
      );

  factory RequestedShop.fromJson(Map<String, dynamic> json) => RequestedShop(
        id: json["_id"],
        order: json["order"],
        shop: Shop.fromJson(json["shop"]),
        // distance: json["distance"].toDouble(),
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        verficationOTP: json["verificationOTP"],
        feedback: FeedbackModel.fromJson(json["feedback"]),
        staff: Staff.fromJson(json["staff"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "order": order,
        "shop": shop.toJson(),
        // "distance": distance,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "feedback": feedback.toJson(),
        "staff": staff.toJson(),
      };
}

class FeedbackModel {
  FeedbackModel(
      {required this.deliveryTime,
      required this.deliveryCharge,
      required this.itemsAllocated,
      required this.id,
      this.rating});

  final int deliveryTime;
  final int deliveryCharge;
  final List<OrderItem> itemsAllocated;
  final String id;
  RatingModel? rating;

  FeedbackModel copyWith({
    required int deliveryTime,
    required int deliveryCharge,
    required List<OrderItem> itemsAllocated,
    required String id,
  }) =>
      FeedbackModel(
          deliveryTime: deliveryTime,
          deliveryCharge: deliveryCharge,
          itemsAllocated: itemsAllocated,
          id: id);

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
      deliveryTime: json["deliveryTime"] ?? 0,
      deliveryCharge: json["deliveryCharge"] ?? 100,
      itemsAllocated: List<OrderItem>.from(
          json["itemsAllocated"].map((x) => OrderItem.fromJson(x))),
      id: json["_id"],
      rating:
          json["rating"] != null ? RatingModel.fromJson(json["rating"]) : null);

  Map<String, dynamic> toJson() => {
        "deliveryTime": deliveryTime,
        "deliveryCharge": deliveryCharge,
        "itemsAllocated":
            List<dynamic>.from(itemsAllocated.map((x) => x.toJson())),
        "_id": id,
      };
}
