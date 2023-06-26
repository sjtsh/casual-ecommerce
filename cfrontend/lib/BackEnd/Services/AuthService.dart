import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/keys.dart';
import '../../Components/snackbar/customsnackbar.dart';
import '../../StateManagement/SignInManagement.dart';
import '../ApiService.dart';
import '../Entities/Detail.dart';
import '../Entities/DeviceModel.dart';
import '../StaticService/StaticService.dart';

class AuthService {
  Future<bool> isConnection() async {
    return (await Connectivity().checkConnectivity()) !=
        ConnectivityResult.none;
    // Response? success = (await ApiService.get("connection", withToken: false));
    // return success != null;
  }

  Future<void> refreshToken() async {
    Response res = await http.get(
        Uri.parse("${ApiService.baseUrl}auth/refresh"),
        headers: ApiService.getHeaders(true, withRefreshToken: true));
    if (res.statusCode != 200) return;
    Map<String, dynamic> authToken = jsonDecode(res.body);
    if (authToken["x-access-token"] != null) {
      ApiService.authToken = authToken["x-access-token"];
      CustomKeys.context?.read<SignInManagement>().authToken =
          authToken["x-access-token"];
      ApiService.authToken = authToken["x-access-token"];
      SharedPreferences.getInstance().then((value) => value.setString(
          "token", CustomKeys.context!.read<SignInManagement>().authToken!));
    }
  }

  Future<LoginData?> auth(
      String phone, String password, DeviceModel? deviceInfo, String countryCode) async {
    if (deviceInfo == null) {
      CustomSnackBar().error("Device could not be registered");
      return null;
    }

    Response? res = await ApiService.post("auth/login/staff",
        body: {
          'phone': phone,
          'password': password,
          'countryCode':countryCode,
          'device': deviceInfo.toJson()
        },
        withToken: false).timeout(const Duration(seconds: 15));
    if (res == null) throw "handled";
    Map<String, dynamic> userData = jsonDecode(res.body);
    LoginData loginData = LoginData.fromJson(userData);
    return loginData;
  }

  Future<bool> shopAvailability(bool isAvailable) async {
    Response? res = await ApiService.put("shop/available",
        body: {"available": isAvailable});
    return res != null;
  }

  Future<bool> logout() async {
    DeviceModel? deviceModel = await StaticService.getDeviceInfo();
    if (deviceModel == null) return false;
    Response? res = await ApiService.delete(
        "staff/logout/${deviceModel.deviceId}",
        handle: false);
    return res != null;
  }

  Future<LoginData> getShop() async {
    try {
      Response? res = await ApiService.get("staff/info");
      if (res == null) throw "handled";
      Map<String, dynamic> userData = jsonDecode(res.body);
      return LoginData.fromJson(userData);
    } catch (e, __) {
      print(__);
      rethrow;
    }
  }
}
