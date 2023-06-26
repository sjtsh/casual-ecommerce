// import 'dart:io';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:ezdelivershop/BackEnd/Services/AuthService.dart';
// import 'package:ezdelivershop/Components/keys.dart';
// import 'package:ezdelivershop/StateManagement/DataManagement.dart';
// import 'package:ezdelivershop/StateManagement/PeriodicRefreshManagement.dart';
// import 'package:ezdelivershop/StateManagement/PermissionManagement.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:provider/provider.dart';
//
// import 'package:another_flushbar/flushbar.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:ezdelivershop/BackEnd/StaticService/OrderLogicStaticService.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class StaticService {
//   static final TextEditingController socketPort = TextEditingController();
//   static final TextEditingController httpPort = TextEditingController();
//   static final TextEditingController localhost = TextEditingController();
//
//   static initUrl() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     ApiService.socketPortLocal =
//         prefs.getInt("socketPort") ?? ApiService.socketPortLocal;
//     ApiService.apiPortLocal =
//         prefs.getInt("httpPort") ?? ApiService.apiPortLocal;
//     ApiService.localUrl = prefs.getString("localhost") ?? ApiService.localUrl;
//     socketPort.text = ApiService.socketPortLocal.toString();
//     httpPort.text = ApiService.apiPortLocal.toString();
//     localhost.text = ApiService.localUrl.toString();
//     socketPort.addListener(() {
//       ApiService.socketPortLocal =
//           int.tryParse(socketPort.text) ?? ApiService.socketPortLocal;
//       prefs.setInt("socketPort", ApiService.socketPortLocal);
//     });
//     httpPort.addListener(() {
//       ApiService.apiPortLocal =
//           int.tryParse(httpPort.text) ?? ApiService.apiPortLocal;
//       prefs.setInt("httpPort", ApiService.apiPortLocal);
//     });
//     localhost.addListener(() {
//       ApiService.localUrl = localhost.text;
//       prefs.setString("localhost", ApiService.localUrl);
//     });
//   }
//
//   static showTime(DateTime dateTime) {
//     return dateTime
//         .add(Duration(hours: 5, minutes: 45))
//         .toString()
//         .substring(11, 19);
//   }
//
//   static beforeMain() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     CustomCloudMessaging.initFirebase();
//     FlutterBackground.initialize()
//         .then((value) => FlutterBackground.enableBackgroundExecution());
//     await NotificationController.initializeLocalNotifications();
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // await notifications.initialize(
//     //     const InitializationSettings(
//     //         android: AndroidInitializationSettings('@mipmap/ic_launcher')),
//     //     onDidReceiveNotificationResponse: _openScreenWhenClicked);
//     // final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//     //     await notifications.getNotificationAppLaunchDetails();
//     // if (notificationAppLaunchDetails != null) {
//     //   // var data =
//     //   //     jsonDecode(notificationAppLaunchDetails.notificationResponse!.payload!);
//     //   // print(data);
//     //   if (notificationAppLaunchDetails.didNotificationLaunchApp) {
//     //     notifications.cancelAll();
//     //   }
//     // }
//     if (!ApiService.production) {
//       initUrl();
//     }
//   }
//
//   static String changeDistance(double distance) {
//     if (distance < 1000) {
//       return "${distance.toStringAsFixed(2)} m";
//     } else {
//       return "${(distance / 1000).toStringAsFixed(2)} km";
//     }
//   }
//
//   static showDialogBox(
//       {required BuildContext context, required Widget child}) async {
//     await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return child;
//         });
//   }
//
//   static void initial(BuildContext context, {bool home = false}) async {
//     CustomKeys.context = context;
//     context.read<SignInManagement>().getShopData();
//     OrderSocket.orderSocket(context);
//     context.read<SignInManagement>().passwordController.clear();
//     await Future.wait([
//       context.read<PermissionMananagement>().initializePermisssion(context),
//       ExceptionHandling.catchExceptions(function: () async {
//         context.read<DataManagement>().order = await OrderService().getOrders();
//       }),
//       didChangeState(context)
//     ]);
//   }
//
//   static Future<void> didChangeState(BuildContext context) async {
//     context.read<PeriodicRefreshManagement>().init();
//     context.read<NewOrderManagement>().newOrders =
//     await OrderService().getNewOrder();
//   }
//
//   static showInformation(
//       {required BuildContext context,
//         required String title,
//         required String message}) {
//     return Flushbar(
//       title: title,
//       message: message,
//       duration: const Duration(seconds: 3),
//       flushbarPosition: FlushbarPosition.TOP,
//       icon: const Icon(
//         Icons.icecream,
//         color: Colors.white,
//       ),
//       backgroundColor: ColorPalette.primaryColor,
//     ).show(context);
//   }
//
//   static pushPage(
//       {required BuildContext context, required Widget route}) async {
//     await Navigator.of(context)
//         .push(MaterialPageRoute(builder: (context) => route));
//   }
//
//   static Future<DeviceModel?> getDeviceInfo() async {
//     var token = await FirebaseMessaging.instance.getToken();
//     if (token == null) return null;
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       return DeviceModel(
//           os: "android",
//           deviceId: androidInfo.id,
//           fcmToken: token,
//           notify: true,
//           version: androidInfo.version.sdkInt.toString());
//     } else if (Platform.isIOS) {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       return DeviceModel(
//           os: "ios",
//           deviceId: iosInfo.utsname.version!,
//           fcmToken: token,
//           notify: true,
//           version: iosInfo.systemVersion!);
//     }
//     return Future.value(null);
//
//     // } else if (UniversalPlatform.isDesktop) {
//     // } else if (UniversalPlatform.isWeb) {
//     //   {}
//     // }
//   }
// }
//
// // void _openScreenWhenClicked(NotificationResponse response) {
// //   Future.delayed(Duration(seconds: 1)).then((value) =>
// //       initial(CustomKeys.messengerKey.currentContext!, response: response));
// // }
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await NotificationController.initializeLocalNotifications();
//   print("Handling a background message: ${message.data}");
//   await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         //       importance: Importance.max,
//         //       priority: Priority.high,
//         //       enableVibration: true,
//         //       timeoutAfter: 120000,
//           id: -1,
//           // importance: Importance.max,
//           // priority: Priority.high,
//           fullScreenIntent: true,
//           actionType: ActionType.KeepOnTop,
//           criticalAlert: true,
//           autoDismissible: false,
//           // -1 is replaced by a random number
//           wakeUpScreen: true,
//           locked: true,
//           // customSound: 'ringtone',
//           channelKey: 'alerts',
//           title: message.data['title'],
//           body: message.data['body'],
//           bigPicture:
//           'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//           largeIcon:
//           'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
//           //'asset://assets/images/balloons-in-sky.jpg',
//           notificationLayout: NotificationLayout.Default,
//           payload: {
//             'notificationId': '1234567890',
//             ...message.data,
//           }),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'Reject',
//           label: 'Reject',
//           actionType: ActionType.SilentBackgroundAction,
//           isDangerousOption: true,
//         ),
//         NotificationActionButton(
//           key: 'Accept',
//           label: 'Accept',
//           actionType: ActionType.Default,
//         )
//       ]);
// }
// import 'dart:convert';
//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../main.dart';
//
// class NotificationController {
//   static ReceivedAction? initialAction;
//
//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//         null, //'resource://drawable/res_app_icon',//
//         [
//           NotificationChannel(
//               channelKey: 'alerts',
//               channelName: 'Alerts',
//               channelDescription: 'Notification tests as alerts',
//               playSound: true,
//               onlyAlertOnce: true,
//               groupAlertBehavior: GroupAlertBehavior.Children,
//               importance: NotificationImportance.High,
//               defaultPrivacy: NotificationPrivacy.Private,
//               defaultColor: Colors.deepPurple,
//               ledColor: Colors.deepPurple)
//         ],
//         debug: true);
//     print("hello world level -0");
//     AwesomeNotifications()
//         .setListeners(onActionReceivedMethod: onActionReceivedMethod);
//     // Get initial notification action is optional
//     initialAction = await AwesomeNotifications()
//         .getInitialNotificationAction(removeFromActionEvents: false);
//   }
//
//   @pragma('vm:entry-point')
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     print("hello world level 1");
//     if (receivedAction.buttonKeyPressed == "Reject") {
//       print("hello world level 2");
//       // For background actions, you must hold the execution until the end
//       if (receivedAction.payload!["order"] != null) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         Response res = await http.put(
//             Uri.parse("http://hilifefoods.com.np:10000/order/status/reject"),
//             body: jsonEncode({"order_id": receivedAction.payload!["order"] }),
//             headers: {
//               "content-type": "application/json",
//               "x-access-token": prefs.getString("token") ?? ""
//             });
//       }
//     }
//   }
//
//   static Future<bool> displayNotificationRationale() async {
//     bool userAuthorized = false;
//     BuildContext context = MyApp.navigatorKey.currentContext!;
//     await showDialog(
//         context: context,
//         builder: (BuildContext ctx) {
//           return AlertDialog(
//             title: Text('Get Notified!',
//                 style: Theme.of(context).textTheme.titleLarge),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Image.asset(
//                         'assets/animated-bell.gif',
//                         height: MediaQuery.of(context).size.height * 0.3,
//                         fit: BoxFit.fitWidth,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                     'Allow Awesome Notifications to send you beautiful notifications!'),
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                   },
//                   child: Text(
//                     'Deny',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(color: Colors.red),
//                   )),
//               TextButton(
//                   onPressed: () async {
//                     userAuthorized = true;
//                     Navigator.of(ctx).pop();
//                   },
//                   child: Text(
//                     'Allow',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(color: Colors.deepPurple),
//                   )),
//             ],
//           );
//         });
//     return userAuthorized &&
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//   }
//
//
//   static Future<void> resetBadgeCounter() async {
//     await AwesomeNotifications().resetGlobalBadge();
//   }
//
//   static Future<void> cancelNotifications() async {
//     await AwesomeNotifications().cancelAll();
//   }
// }
