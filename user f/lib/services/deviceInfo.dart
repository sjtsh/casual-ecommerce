import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/users/model/deviceModel.dart';
import 'package:firebase_core/firebase_core.dart';

class CustomDeviceInfo {
  CustomDeviceInfo._();

  static Future<DeviceModel?> getDeviceInfo() async {
    // try {
    String token = "temp";
    try {
      var tempToken = await FirebaseMessaging.instance.getToken();
      if (tempToken != null) {
        token = tempToken;
      }
    } catch (e) {}

    // if (token == null) {
    //   var test = await FirebaseMessaging.instance.getNotificationSettings();

    //   if (test.authorizationStatus == AuthorizationStatus.denied) {
    //     CustomDialogBox.alertMessage(() {},
    //         title: "Notification denied",
    //         message:
    //             "You must allow notification permission for this to work");
    //   }
    // }
    // throw "$token";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (UniversalPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return DeviceModel(
          os: "android",
          deviceId: androidInfo.id,
          fcmToken: token,
          notify: true,
          version: androidInfo.version.sdkInt.toString());
    } else if (UniversalPlatform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return DeviceModel(
          os: "ios",
          deviceId: iosInfo.identifierForVendor!,
          fcmToken: token,
          notify: true,
          version: iosInfo.systemVersion!);
    } else if (UniversalPlatform.isWeb || UniversalPlatform.isDesktop) {
      return DeviceModel(
          os: UniversalPlatform.isWeb ? "web" : "windows",
          deviceId: token,
          fcmToken: token,
          notify: true,
          version: "version");
    }
    return Future.value(null);
    // } catch (e) {
    //   // var test = await FirebaseMessaging.instance.getNotificationSettings();

    //   // if (test.authorizationStatus == AuthorizationStatus.denied) {
    //   //   // Navigator.pop(CustomKeys.context);
    //   //   await CustomDialogBox.alertMessage(() {},
    //   //       title: "Notification denied",
    //   //       message: "You must allow notification permission for this to work");
    //   // }
    //   // // print(e);
    //   // // if (e is FirebaseException) {
    //   // //   print(e);
    //   // // }
    //   return Future.value(null);
    //   // print(e)
    // }

    // } else if (UniversalPlatform.isDesktop) {
    // }
  }
}
