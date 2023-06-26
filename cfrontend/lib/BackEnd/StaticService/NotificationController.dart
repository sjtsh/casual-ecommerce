//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:ezdelivershop/BackEnd/Enums/PermissionGrant.dart';
// import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Pre/MyApp.dart';
// class NotificationController {
//   static AwesomeNotifications awesomeNotification = AwesomeNotifications();
//
//   static Future<AwesomeNotifications> changeNotification(
//       {bool home = false}) async {
//     return await initializeLocalNotifications(home: home);
//   }
//
//   static Future<AwesomeNotifications> initializeLocalNotifications(
//       {bool home = false}) async {
//     awesomeNotification = AwesomeNotifications();
//     // await awesomeNotification.initialize(null, [...getNonSilentChannels(), ...getSilentChannels()]);
//     await awesomeNotification.initialize(null, [...getNonSilentChannels()]);
//     PermissionGrant.requestNotificationPermissions();
//     awesomeNotification.setListeners(
//         onActionReceivedMethod: onActionReceivedMethod);
//
//     return awesomeNotification;
//   }
//
//   @pragma('vm:entry-point')
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     // if (receivedAction.buttonKeyPressed == "Reject") {
//     //   if (receivedAction.payload!["order"] != null) {
//     //     SharedPreferences prefs = await SharedPreferences.getInstance();
//     //     await prefs.setBool("background_handler", false);
//     //     if (receivedAction.payload?["delivery"] == "true") {
//     //       await http.put(
//     //           Uri.parse(
//     //               "${ApiService.baseUrl}staff/delivery/reject/${receivedAction.payload!["order"]}"),
//     //           headers: {
//     //             "content-type": "application/json",
//     //             "x-access-token": prefs.getString("token") ?? ""
//     //           });
//     //     } else {
//     //       await http.put(
//     //           Uri.parse("${ApiService.baseUrl}staff/feedback/reject"),
//     //           body: jsonEncode({"order_id": receivedAction.payload!["order"]}),
//     //           headers: {
//     //             "content-type": "application/json",
//     //             "x-access-token": prefs.getString("token") ?? ""
//     //           });
//     //     }
//     //     return;
//     //   }
//     // }
//     if (receivedAction.payload!['title'] == "You have been rated.") {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool("rateIntent", true);
//       if (MyApp.navigatorKey.currentContext != null) {
//         while (Navigator.canPop(MyApp.navigatorKey.currentContext!)) {
//           Navigator.pop(MyApp.navigatorKey.currentContext!);
//         }
//       }
//       MyApp.navigatorKey.currentState
//           ?.push(MaterialPageRoute(builder: (_) => ShopRatingDetails()));
//     }
//   }
//
//   static List<NotificationChannel> getNonSilentChannels() {
//     NotificationChannel channel = NotificationChannel(
//         channelKey: 'activity',
//         channelName: 'activity',
//         channelDescription: 'Activity notifications',
//         playSound: true,
//         onlyAlertOnce: false,
//         enableVibration: true,
//         locked: true,
//         soundSource: 'resource://raw/res_ringtone',
//         defaultRingtoneType: DefaultRingtoneType.Ringtone,
//         groupAlertBehavior: GroupAlertBehavior.Children,
//         importance: NotificationImportance.High,
//         defaultColor: ColorPalette.primaryColor,
//         ledColor: Colors.red);
//     NotificationChannel channel2 = NotificationChannel(
//         channelKey: 'alerts',
//         channelName: 'alerts',
//         channelDescription: 'Activity alerts',
//         onlyAlertOnce: false,
//         enableVibration: true,
//         playSound: true,
//         defaultRingtoneType: DefaultRingtoneType.Notification,
//         groupAlertBehavior: GroupAlertBehavior.Children,
//         importance: NotificationImportance.High,
//         defaultColor: ColorPalette.primaryColor,
//         ledColor: Colors.red);
//     return [channel, channel2];
//   }
//
//   static List<NotificationChannel> getSilentChannels() {
//     NotificationChannel channel3 = NotificationChannel(
//         channelKey: 'silent_activity',
//         channelName: 'silent_activity',
//         channelDescription: 'Activity notifications',
//         playSound: false,
//         onlyAlertOnce: false,
//         enableVibration: true,
//         locked: true,
//         soundSource: 'resource://raw/res_ringtone',
//         defaultRingtoneType: DefaultRingtoneType.Ringtone,
//         groupAlertBehavior: GroupAlertBehavior.Children,
//         importance: NotificationImportance.High,
//         defaultColor: Colors.red,
//         ledColor: Colors.red);
//     NotificationChannel channel4 = NotificationChannel(
//         channelKey: 'silent_alerts',
//         channelName: 'silent_alerts',
//         channelDescription: 'Silent Activity alerts',
//         onlyAlertOnce: false,
//         enableVibration: true,
//         playSound: false,
//         defaultRingtoneType: DefaultRingtoneType.Notification,
//         groupAlertBehavior: GroupAlertBehavior.Children,
//         importance: NotificationImportance.High,
//         defaultColor: Colors.red,
//         ledColor: Colors.red);
//     return [channel3, channel4];
//   }
// }
