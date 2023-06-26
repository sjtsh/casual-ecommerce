// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

import 'package:ezdeliver/screen/component/helper/exporter.dart';

class BannerModel {
  BannerModel({
    required this.id,
    required this.bannerModelId,
    required this.offsetX,
    required this.offsetY,
    required this.gridSpace,
    this.img,
    required this.redirectUrl,
    required this.detail,
    required this.title,
    required this.colors,
    required this.foreign,
    this.updatedAt,
    this.createdAt,
    required this.titleColor,
    required this.orientation,
    required this.group,
    this.deactivated = false,
    this.onlyImage = false,
  });

  final String id;
  final String bannerModelId;
  final int offsetX;
  final int offsetY;
  final int gridSpace;
  final String? img;
  final String redirectUrl;
  final String detail;
  final String title;
  final List<BannerColor> colors;
  final String? foreign;
  final String group;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final bool deactivated;
  final bool orientation;
  final bool onlyImage;
  final BannerColor titleColor;

  BannerModel copyWith(
          {String? id,
          String? bannerModelId,
          int? offsetX,
          int? offsetY,
          int? gridSpace,
          String? img,
          String? redirectUrl,
          String? detail,
          String? title,
          List<BannerColor>? colors,
          String? foreign,
          BannerColor? titleColor,
          bool? orientation,
          String? group,
          bool? onlyImage}) =>
      BannerModel(
          id: id ?? this.id,
          bannerModelId: bannerModelId ?? this.bannerModelId,
          offsetX: offsetX ?? this.offsetX,
          offsetY: offsetY ?? this.offsetY,
          gridSpace: gridSpace ?? this.gridSpace,
          img: img ?? this.img,
          redirectUrl: redirectUrl ?? this.redirectUrl,
          detail: detail ?? this.detail,
          title: title ?? this.title,
          colors: colors ?? this.colors,
          foreign: foreign ?? this.foreign,
          titleColor: titleColor ?? this.titleColor,
          orientation: orientation ?? this.orientation,
          group: group ?? this.group,
          onlyImage: onlyImage ?? this.onlyImage);

  factory BannerModel.fromRawJson(String str) =>
      BannerModel.fromJson(json.decode(str));

  copyWithFromJson(Map<String, dynamic> json) {
    var newBanner = toJson();
    for (var element in json.entries) {
      if (newBanner.containsKey(element.key)) {
        newBanner.update(element.key, (value) => element.value);
      }
    }
    return BannerModel.fromJson(newBanner);
  }

  String toRawJson() => json.encode(toJson());

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    List<BannerColor> colors = [];
    colors = List<BannerColor>.from(
        json["colors"].map((x) => BannerColor.fromJson(x)));

    if (colors.isEmpty) {
      colors = List.generate(
          2,
          (index) => BannerColor(
              color: index == 0
                  ? CustomTheme.primaryColor
                  : CustomTheme.getFilledPrimaryColor(),
              transparency: index == 0 ? 0.2 : 0.8,
              id: ""));
    }
    return BannerModel(
      id: json["_id"],
      titleColor: BannerColor.fromJson(json["titleColor"]),
      orientation: json["orientation"],
      bannerModelId: json["id"],
      offsetX: json["offsetX"],
      offsetY: json["offsetY"],
      gridSpace: json["gridSpace"],
      img: json["img"],
      redirectUrl: json["redirectUrl"] ?? "",
      detail: json["detail"] ?? "",
      title: json["title"],
      colors: colors,
      foreign: json["foreign"],
      group: json["group"],
      onlyImage: json["onlyImage"],
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "id": bannerModelId,
        "offsetX": offsetX,
        "offsetY": offsetY,
        "gridSpace": gridSpace,
        "img": img,
        "redirectUrl": redirectUrl,
        "detail": detail,
        "group": group,
        "title": title,
        "colors": List<dynamic>.from(colors.map((x) => x.toJson())),
        "foreign": foreign,
        "titleColor": titleColor.toJson(),
        "orientation": orientation,
        "onlyImage": onlyImage
      };
}

class BannerColor {
  BannerColor({
    required this.color,
    required this.transparency,
    required this.id,
  });

  final Color color;
  final double transparency;
  final String id;

  BannerColor copyWith({
    Color? color,
    double? transparency,
    String? id,
  }) =>
      BannerColor(
        color: color ?? this.color,
        transparency: transparency ?? this.transparency,
        id: id ?? this.id,
      );

  factory BannerColor.fromRawJson(String str) =>
      BannerColor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BannerColor.fromJson(Map<String, dynamic> json) => BannerColor(
        color: (hexStringToColor(json["color"])) ?? CustomTheme.primaryColor,
        transparency: json["transparency"].toDouble(),
        id: json["_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "color": colorToHexString(color),
        "transparency": transparency.toDouble(),
        "_id": id,
      };

  static Color? hexStringToColor(String? hexColor) {
    if (hexColor == null) return null;
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    return Color(
        int.tryParse(hexColor, radix: 16) ?? CustomTheme.primaryColor.value);
  }

  static String colorToHexString(Color color, {bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}${color.alpha.toRadixString(16).padLeft(2, '0')}${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}
