import 'dart:core';
import '../ApiService.dart';

class Shop {
  final String id;
  final String displayId;
  final String name;
  String phone;
  String address;
  String? image;
  final double lat;
  final double lng;
  final DateTime? openingTime;
  final DateTime? closingTime;

  @override
  String toString() {
    return name.toString();
  }

  Shop(this.id, this.displayId, this.name, this.phone, this.address, this.lat,
      this.lng,
      {this.image, this.openingTime, this.closingTime});

  // factory Shop.dummy() {
  //   return Shop("id", "displayId", "name", "phone", "address", 12, 12);
  // }

  factory Shop.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, dynamic> location = json["location"];
      List<dynamic> latLng = location["coordinates"];
      List<dynamic>? img = json['img'];
      Map<String, dynamic>? timing = json["timing"];
      String utc = DateTime.now().toUtc().toString();
      Duration dur = DateTime.parse(utc.substring(0, utc.length - 1))
          .difference(DateTime.now());
      int hrMin;
      if (dur >= const Duration(seconds: 1)) {
        hrMin = dur.inMinutes;
      } else {
        hrMin = dur.inMinutes * -1;
      }
      DateTime? openingTime;
      DateTime? closingTime;
      if (timing != null) {
        int openingHr = timing["start"]["hour"] + hrMin ~/ 60;
        int openingMin = timing["start"]["minute"] + hrMin % 60;

        int closingHr = timing["end"]["hour"] + hrMin ~/ 60;
        int closingMin = timing["end"]["minute"] + hrMin % 60;
        openingTime =
            DateTime.now().copyWith(hour: openingHr, minute: openingMin);
        closingTime =
            DateTime.now().copyWith(hour: closingHr, minute: closingMin);
      }
      return Shop(json["_id"], json["id"].toString(), json["name"],
          json["phone"], json["address"] ?? "", latLng[1], latLng[0],
          image: (img?.isEmpty ?? true)
              ? null
              : img!.first
                  .toString()
                  .replaceAll("http://localhost:10000/", ApiService.baseUrl),
          openingTime: openingTime,
          closingTime: closingTime);
    } catch (e) {
      rethrow;
    }
  }
}
