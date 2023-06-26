import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/component/snackbar/customsnackbar.dart';
// import 'package:ezdeliver/screen/others/customPhoenix.dart';
import 'package:http/http.dart' as http;

export 'dart:convert';

export 'package:ezdeliver/screen/component/dialogbox/customdialogbox.dart';
//

export 'package:ezdeliver/screen/component/helper/extention.dart';
export 'package:ezdeliver/screen/others/constant.dart';

//
export 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:flutter/services.dart';

export 'package:ezdeliver/services/api.dart';
export 'package:flutter/material.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:geolocator/geolocator.dart';
export 'package:get_storage/get_storage.dart';
export 'package:hooks_riverpod/hooks_riverpod.dart';
export 'package:latlng/latlng.dart';
export 'package:universal_platform/universal_platform.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:another_flushbar/flushbar.dart';
export 'package:another_flushbar/flushbar_helper.dart';
export 'package:ezdeliver/screen/others/widgets.dart';
export 'package:ezdeliver/screen/others/utilities.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:shared_preferences/shared_preferences.dart';
export "package:flutter_animate/flutter_animate.dart";
// export 'package:flutter/foundation.dart';

//

//utilities export
export 'package:ezdeliver/screen/others/groceli_icon_icons.dart';
export 'package:ezdeliver/screen/others/infoMessage.dart';
export 'package:ezdeliver/screen/component/helper/keys.dart';
export "package:ezdeliver/services/updateService/updateService.dart";
export 'package:ezdeliver/services/pushnotification/pushnotification.dart';
export 'package:ezdeliver/screen/component/helper/enums.dart';
export 'package:ezdeliver/screen/component/helper/layout.dart';
export 'package:ezdeliver/services/pushnotification/localNotification.dart';
export 'package:ezdeliver/screen/component/socket/socket.dart';
export 'package:ezdeliver/services/MainApp.dart';
export 'package:ezdeliver/screen/component/customsafearea.dart';
export "package:ezdeliver/screen/others/extension.dart";
export "package:ezdeliver/screen/others/assets.dart";
//

//Services export
export 'package:ezdeliver/services/location.dart';
export 'package:ezdeliver/screen/order/services/productCatService.dart';
export 'package:ezdeliver/screen/orderHistory/services/orderHistoryService.dart';
export 'package:ezdeliver/screen/users/component/userservice.dart';
export 'package:ezdeliver/screen/cart/services/cartService.dart';
export 'package:ezdeliver/screen/others/theme.dart';
export 'package:ezdeliver/services/deviceInfo.dart';

//

final client = http.Client();

const LatLng home = LatLng(26.4721557, 87.32396419999999);

final storage = GetStorage();

// final snackVisibleProvider = StateProvider<bool>((ref) {
//   return false;
// });
final CustomSnackBar snack = CustomSnackBar();

logout(context) async {
  await CustomKeys.ref.read(userChangeProvider).logoutFromServer();
}

final internetCheck = InternetConnectionCheckerPlus.createInstance(
    checkInterval: const Duration(seconds: 2));
FirebaseMessaging messaging = FirebaseMessaging.instance;
Map<String, String> header() {
  var user = CustomKeys.ref.read(userChangeProvider).loggedInUser.value;
  if (user != null) {
    return {
      "Content-Type": "application/json",
      "x-access-token": "${user.accessToken}"
    };
  } else {
    return {"Content-Type": "application/json"};
  }
}

TextStyle responsiveTextStyle(TextStyle style) {
  return style.copyWith(color: style.color, fontSize: style.fontSize?.ssp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const Duration widgetSwitchAnimationDuration = Duration(milliseconds: 300);
const ScrollPhysics scrollPhysics = BouncingScrollPhysics();

double clapRatinValue(double? rating) {
  if (rating == null) return 0;
  double frontDigit = rating.floorToDouble();
  double fraction = rating - frontDigit;
  final value = fraction <= 0.5 && fraction > 0.2
      ? frontDigit + 0.5
      : fraction > 0 && fraction < 0.2
          ? frontDigit
          : frontDigit + 1;

  return value;
}

int map(int x, int inMin, int inMax, int outMin, int outMax) {
  var calc =
      ((x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin).toInt();
  if (calc > outMax) {
    return outMax;
  } else if (calc < outMin) {
    return outMin;
  } else {
    return calc;
  }
}

double mapDouble(
    {required double x,
    // ignore: non_constant_identifier_names
    required double in_min,
    // ignore: non_constant_identifier_names
    required double in_max,
    // ignore: non_constant_identifier_names
    required double out_min,
    // ignore: non_constant_identifier_names
    required double out_max}) {
  var calc = ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
  if (calc > out_max) {
    return out_max;
  } else if (calc < out_min) {
    return out_min;
  } else {
    return calc;
  }
}
