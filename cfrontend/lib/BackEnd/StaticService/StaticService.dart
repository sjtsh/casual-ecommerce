import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ezdelivershop/BackEnd/Enums/ServerService.dart';
import 'package:ezdelivershop/BackEnd/Services/UpdateService.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:ezdelivershop/Components/keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../StateManagement/SignInManagement.dart';
import '../../UI/Skeletons/LoadingImage.dart';
import '../Entities/DeviceModel.dart';

extension ElipsisAt on String {
  String at({int length = 30}) {
    return this.length > length ? "${substring(0, length)}..." : this;
  }
}

class StaticService {
  static final TextEditingController socketPort = TextEditingController();
  static final TextEditingController httpPort = TextEditingController();
  static final TextEditingController localhost = TextEditingController();
  static int appendCount = 20;
  static int initialCount = 20;
  static int ratingInitialCount = 10;
  static int ratingAppendCount = 10;
  static bool ringtone = true;
  static AppLifecycleState _lifeCycleState = AppLifecycleState.resumed;

  static set lifeCycleState(AppLifecycleState value) {
    if (value != _lifeCycleState) {
      BuildContext ctx = CustomKeys.context!;
      if (value == AppLifecycleState.resumed) {
        // ctx.read<LandingPageManagement>().changeIndex(0, false, false);
        // StaticService.initialPhase2(ctx);
      } else if (value == AppLifecycleState.paused) {
        // OrderSocket.socket?.close();
        // ctx.read<HiveManagement>().saveAll(ctx);
      }
    }
    _lifeCycleState = value;
  }

  static Future<void> initialPhase1(BuildContext context,
      {bool home = false}) async {
    SignInManagement read = context.read<SignInManagement>();
    // context.read<NewOrderManagement>().player.setReleaseMode(ReleaseMode.loop);
    await read.getShopData();
    read.passwordController.clear();
  }


  static String showTime(DateTime dateTime) {
    DateTime date = dateTime.add(const Duration(hours: 5, minutes: 45));
    return DateFormat(
            "${date.toString().substring(0, 10) != DateTime.now().toString().substring(0, 10) ? "MMM d, y  " : ""}hh:mm a")
        .format(date);
  }


  static beforeMain() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
    // await xiaomiFirstTime();
    if (kDebugMode) UpdateService().checkForInAppUpdate();
    // await CustomCloudMessaging.initFirebase();
    // onFCM(home: true);
    // if (kDebugMode) {
    //   FlutterBackground.initialize()
    //       .then((value) => FlutterBackground.enableBackgroundExecution());
    // }
    // if (!ApiService.serverService.isProduction) {
    //   initUrl();
    // }
  }

  // static Future<void> onFCM({bool home = false, bool? ringtone}) async {
  //   await NotificationController.changeNotification(home: true);
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // }

  static String changeDistance(double distance) {
    if (distance < 1000) {
      return "${distance.toStringAsFixed(2)} m";
    } else {
      return "${(distance / 1000).toStringAsFixed(2)} km";
    }
  }

  static showDialogBox(
      {required BuildContext context,
      required Widget child,
      bool canDismiss = false}) async {
    return await showDialog(
        barrierDismissible: canDismiss,
        context: context,
        builder: (BuildContext context) {
          return child;
        });
  }

  static showOnline({bool? condition}) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            condition! ? ColorPalette.successColor : ColorPalette.dividerColor,
      ),
    );
  }

  static Future<void> didChangeState(BuildContext context) async {
    // context.read<PeriodicRefreshManagement>().init();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        context.read<CustomTheme>().checkTheme();
      } catch (e) {}
    });
    return;
  }
  static initUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ServerService.socketPortLocal =
        prefs.getInt("socketPort") ?? ServerService.socketPortLocal;
    ServerService.apiPortLocal =
        prefs.getInt("httpPort") ?? ServerService.apiPortLocal;
    ServerService.localUrl =
        prefs.getString("localhost") ?? ServerService.localUrl;
    socketPort.text = ServerService.socketPortLocal.toString();
    httpPort.text = ServerService.apiPortLocal.toString();
    localhost.text = ServerService.localUrl.toString();
    socketPort.addListener(() {
      ServerService.socketPortLocal =
          int.tryParse(socketPort.text) ?? ServerService.socketPortLocal;
      prefs.setInt("socketPort", ServerService.socketPortLocal);
    });
    httpPort.addListener(() {
      ServerService.apiPortLocal =
          int.tryParse(httpPort.text) ?? ServerService.apiPortLocal;
      prefs.setInt("httpPort", ServerService.apiPortLocal);
    });
    localhost.addListener(() {
      ServerService.localUrl = localhost.text;
      prefs.setString("localhost", ServerService.localUrl);
    });
  }

  static String distanceBetween(
      {required double startLatitude,
      required double startLongitude,
      required double endLatitude,
      required double endLongitude}) {
    double distance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    if (distance < 1000) {
      return "${distance.toStringAsFixed(2)} m";
    } else {
      return "${(distance / 1000).toStringAsFixed(2)} km";
    }
  }

  static Future<Object?> pushPage(
      {required BuildContext context, required Widget route}) async {
    return await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => route));
  }

  static pushReplacement(
      {required BuildContext context, required Widget route}) async {
    await Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => route));
  }

  static Future<String> getFingerprint(DeviceInfoPlugin deviceInfo) async {
    List<String> fingerprint =
        (await deviceInfo.androidInfo).fingerprint.split(".");
    return fingerprint
        .sublist(0, fingerprint.length - 2)
        .join(".")
        .replaceAll("/", "_")
        .replaceAll(":", "_");
  }

  static Future<String> deviceIdOnly() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return await getFingerprint(deviceInfo);
    } else {
      return (await deviceInfo.iosInfo).utsname.version.toString();
    }
  }

  static Future<DeviceModel?> getDeviceInfo() async {
    var token = await FirebaseMessaging.instance.getToken();
    if (token == null) return null;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      String fingerPrint = await getFingerprint(deviceInfo);
      return DeviceModel(
          os: "android",
          deviceId: fingerPrint,
          fcmToken: token,
          notify: true,
          version: (await deviceInfo.androidInfo).version.sdkInt.toString());
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return DeviceModel(
          os: "ios",
          deviceId: iosInfo.utsname.version!,
          fcmToken: token,
          notify: true,
          version: iosInfo.systemVersion!);
    }
    return Future.value(null);

    // } else if (UniversalPlatform.isDesktop) {
    // } else if (UniversalPlatform.isWeb) {
    //   {}
    // }
  }

  static final Random rand = Random(256);

  static String getImage() {
    final int index = rand.nextInt(skeletons.length - 1);
    return skeletons[index];
  }

  static Widget cache(String? url, {BoxFit? fit, double? height}) {
    CachedNetworkImage skeleton = CachedNetworkImage(
        fit: BoxFit.contain,
        imageUrl: getImage(),
        height: height,
        width: height);
    if (url == null) return skeleton;
    return CachedNetworkImage(
      fit: fit,
      imageUrl: url.replaceAll("localhost", "192.168.1.75"),
      height: height,
      width: height,
      errorWidget: (_, __, ___) => skeleton,
      progressIndicatorBuilder: (BuildContext _, __, ___) => LoadingImage(),
    );
  }

  static void minimize(){
    const MethodChannel("flutter.native/helper").invokeMethod("sendToBackground");
  }

  static xiaomiFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? xiaomi = prefs.getBool("xiaomi");
    if (xiaomi != null) return;

    const platform = MethodChannel('flutter.native/helper');
    platform.invokeMethod("intentActivity");
    prefs.setBool("xiaomi", true);
  }

  static  List<String> skeletons = const [
    "Group",
    "Group-1",
    "Group-2",
    "Group-3",
    "Group-4",
    "Group-5",
    "Group-6",
    "Group-7",
    "Group-8",
    "Group-9",
    "Group-10",
    "Group-11",
  ].map((e) => 'https://hilifefoods.com.np/images/skeleton/$e.png').toList();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
// void _openScreenWhenClicked(NotificationResponse response) {
//   Future.delayed(Duration(seconds: 1)).then((value) =>
//       initial(CustomKeys.messengerKey.currentContext!, response: response));
// }

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await CustomCloudMessaging.notificationFromRemoteMessage(message, true);
}
