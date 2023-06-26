// To parse this JSON data, do
//
//     final menuItems = menuItemsFromJson(jsonString);

import 'package:ezdeliver/screen/component/helper/exporter.dart';

List<MenuItems> menuItemsFromJson(String str) =>
    List<MenuItems>.from(json.decode(str).map((x) => MenuItems.fromJson(x)));

String menuItemsToJson(List<MenuItems> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MenuItems {
  MenuItems({
    required this.menuIcon,
    required this.menuName,
    required this.onPressed,
    required this.id,
  });

  final IconData menuIcon;
  final String menuName;
  final Function(BuildContext) onPressed;
  final String id;

  MenuItems copyWith({
    required IconData menuIcon,
    required String menuName,
    required Function(BuildContext) onPressed,
    required String id,
  }) =>
      MenuItems(
        menuIcon: menuIcon,
        menuName: menuName,
        onPressed: onPressed,
        id: id,
      );

  factory MenuItems.fromJson(Map<String, dynamic> json) => MenuItems(
        menuIcon: json["menuIcon"],
        menuName: json["menuName"],
        onPressed: json["onPressed"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "menuIcon": menuIcon,
        "menuName": menuName,
        "onPressed": onPressed,
        "id": id,
      };
}
