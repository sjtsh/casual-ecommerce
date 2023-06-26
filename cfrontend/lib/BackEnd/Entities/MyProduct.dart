
import 'package:provider/provider.dart';
import '../../Components/keys.dart';
import '../../StateManagement/SignInManagement.dart';
import '../Enums/ServerService.dart';
import 'Detail.dart';

class RemarksModel {
  RemarksWithUserModel? remarksStaff;
  RemarksWithUserModel? remarksOutletAdmin;
  RemarksWithUserModel? remarksSuperAdmin;
  String? remarksStaffReferenceUrl;

  RemarksModel(
      {this.remarksStaff,
      this.remarksOutletAdmin,
      this.remarksSuperAdmin,
      this.remarksStaffReferenceUrl});

  factory RemarksModel.empty() {
    return RemarksModel(
        remarksStaff: RemarksWithUserModel(null, null, null, null, null));
  }

  factory RemarksModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? remarksStaff = json["remarksStaff"];
    Map<String, dynamic>? remarksOutletAdmin = json["remarksOutletAdmin"];
    Map<String, dynamic>? remarksSuperAdmin = json["remarksSuperAdmin"];
    return RemarksModel(
        remarksStaff: remarksStaff == null
            ? null
            : RemarksWithUserModel.fromJson(remarksStaff),
        remarksOutletAdmin: remarksOutletAdmin == null
            ? null
            : RemarksWithUserModel.fromJson(remarksOutletAdmin),
        remarksSuperAdmin: remarksSuperAdmin == null
            ? null
            : RemarksWithUserModel.fromJson(remarksSuperAdmin),
        remarksStaffReferenceUrl: json["remarksStaffReferenceUrl"]);
  }
}

class RemarksWithUserModel {
  final String? name;
  final String? phone;
  final String? by;
  final String? remarks;
  final DateTime? createdAt;

  RemarksWithUserModel(
      this.name, this.phone, this.by, this.remarks, this.createdAt);

  static RemarksWithUserModel fromRemarks(String? remarks) {
    LoginData data = CustomKeys.context!.read<SignInManagement>().loginData!;
    return RemarksWithUserModel(
        data.user.name, data.user.phone, data.user.id, remarks, DateTime.now().toUtc());
  }

  factory RemarksWithUserModel.fromJson(Map<String, dynamic> json) {
    // barcode: null => , price: 50 => 50, margin: 20 => 20
    return RemarksWithUserModel(
        json["name"],
        json["phone"],
        json["by"],
        json["remarks"] == null
            ? null
            : (json["remarks"].toString().split("\n").first),
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]));
  }
}

class MyProduct {
  MyProduct(
      {required this.verificationAdmin,
      required this.verificationOutlet,
      required this.id,
      required this.name,
      required this.price,
      // required this.weight,
      required this.category,
      this.image,
      this.staff,
      this.unit,
      this.margin,
      this.returnPolicy,
      this.barcode,
      required this.tags,
      required this.master,
      this.sku,
      required this.shop,
      required this.deactivated,
      this.remarks});

  final String id;
  final String name;
  final double price;

  // final double weight;
  final String? image;
  final List<String> tags;
  int verificationOutlet;
  int verificationAdmin;
  final String? staff;
  final String master;
  final String shop;
  final String category;
  final String? unit;
  final int? margin;
  final double? sku;
  final int? returnPolicy;
  final String? barcode;
  bool deactivated;
  RemarksModel? remarks;

  factory MyProduct.fromJson(
      Map<String, dynamic> json, String detail, String shop) {
    List<dynamic> tags = json["tags"];
    RemarksModel? remarks = json["remarks"] == null
        ? null
        : (json["remarks"] is Map<String, dynamic>
            ? RemarksModel.fromJson(json["remarks"])
            : RemarksModel(remarksStaff: json["remarks"]));

    return MyProduct(
        id: json["_id"],
        name: json["name"],
        price: json["price"] +0.0,
        // weight: json["weight"] +0.0,
        category: json["category"],
        image: json["image"] == null
            ? null
            : (json["image"].replaceAll("localhost", ServerService.localUrl)),
        staff: json["staff"],
        unit: json["unit"],
        margin: json["margin"],
        returnPolicy: json["return"],
        barcode: json["barcode"],
        tags: tags.map((e) => e.toString()).toList(),
        sku: json["sku"] +0.0,
        master: detail,
        shop: shop,
        verificationAdmin: json["verificationAdmin"] ?? 1,
        verificationOutlet: json["verificationOutlet"] ?? 1,
        deactivated: json["deactivated"],
        remarks: remarks);
  }

  // remarks: RemarksModel.fromJson()
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "category": category,
        "image": image,
        "staff": staff,
        "unit": unit,
        "margin": margin,
        "return": returnPolicy,
        "barcode": barcode,
        "tags": tags,
        "master": master,
        "sku": sku,
        "shop": shop,
        "verificationOutlet": verificationOutlet,
        "verificationAdmin": verificationAdmin
      };
}
