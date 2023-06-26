import '../Enums/Roles.dart';
import 'Shop.dart';
import 'User.dart';

class Staff {
  final String id;
  final bool available;
  final double avgRating;
  final int raterCount;
  final List<int> ratingStar;
  final List<Shop>? shop;
  final int? support;

  Staff(this.id, this.available, this.avgRating, this.raterCount,
      this.ratingStar, this.shop, this.support);

  factory Staff.fromJson(Map<String, dynamic> json) {
    List<dynamic> shopdata = json["shop"];
    return Staff(
        json["_id"],
        json["available"],
        json["avgRating"] + 0.0,
        json["raterCount"],
        List<int>.from(json["ratingStar"]),
        shopdata.map((e) => Shop.fromJson(e)).toList(),
        json["support"]);
  }
}

class LoginData {
  final User user;
  final Staff staff;
  final String? accessToken;
  final String? refreshToken;

  LoginData(this.user, this.staff, this.accessToken, this.refreshToken);

  factory LoginData.fromJson(Map<String, dynamic> json) {
    print(json);
    Map<String, dynamic> userData = json["user"];
    Map<String, dynamic> staff = json["detail"];
    Map<String, dynamic> role = staff["role"];
    Roles.setRoles(role["roles"]);

    return LoginData(User.fromJson(userData), Staff.fromJson(staff),
        json["accessToken"], json["refreshToken"]);
  }
}
