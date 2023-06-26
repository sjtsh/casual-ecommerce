import 'dart:convert';
import 'package:http/http.dart';

import '../ApiService.dart';

class ResetPasswordService {
  Future<bool> newPassword(String phone, String password, String uid) async {
    Response? res = await ApiService.put(
      withToken: false,
      "auth/password/shop",
      body: {'password': password, "phone": phone, "uid": uid},
    );
    if (res?.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkShopForgotPassword(
      {required String phone, String? pan}) async {
    Response? response =
        await ApiService.get("auth/shop/forgot/$phone", withToken: false);
    if (response == null) throw "unhandled";
    var decodedData = jsonDecode(response.body);
    return decodedData["newUser"];
  }

  Future<bool> checkShopSignUp({required String phone, String? pan}) async {
    Response? response = await ApiService.get(
        "auth/shop?phone=$phone${pan == null ? "" : "&pan=$pan"}",
        withToken: false);
    return response != null;
  }

  Future<bool> editPasswordFromProfile(
      {required String currentPassword, required String newPassword}) async {
    Response? response = await ApiService.put("staff/edit/shop/password/",
        body: {"currentPassword": currentPassword, "newPassword": newPassword});
    return response != null;
  }
}
