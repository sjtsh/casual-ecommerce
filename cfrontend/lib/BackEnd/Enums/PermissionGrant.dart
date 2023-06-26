import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Components/snackbar/customsnackbar.dart';

enum PermissionGrant {
  location,
  camera,
  microphone,
  notification,
  checking;

  static bool isPermissionChecking = false;

  @override
  String toString() {
    switch (this) {
      case PermissionGrant.location:
        return "Location permissions are not provided";
      case PermissionGrant.camera:
        return "Camera permissions are not provided";
      case PermissionGrant.microphone:
        return "Microphone permissions are not provided";
      case PermissionGrant.checking:
        return "Checking permissions";
      case PermissionGrant.notification:
        return "Notification permissions are not provided";
    }
  }

  void request() async {
    switch (this) {
      case PermissionGrant.location:
        await Permission.locationWhenInUse.request();
        break;
      case PermissionGrant.camera:
        await Permission.camera.request();
        break;
      case PermissionGrant.microphone:
        await Permission.microphone.request();
        break;
      case PermissionGrant.checking:
        await Permission.locationWhenInUse.request();
        await Permission.camera.request();
        await Permission.microphone.request();
        break;
      case PermissionGrant.notification:
        await Permission.notification.request();
        break;
    }
  }

  MapEntry<String, String> errorMessage() {
    String permissionErrorHeader;
    String permissionErrorMessage;
    switch (this) {
      case PermissionGrant.location:
        permissionErrorMessage = "Please allow location access all the time";
        permissionErrorHeader = "Cannot Find You";
        break;
      case PermissionGrant.camera:
        permissionErrorMessage =
            "Please allow camera access for clicking photos";
        permissionErrorHeader = "Cannot access your camera";
        break;
      case PermissionGrant.microphone:
        permissionErrorMessage =
            "Please allow microphone access for clicking photos";
        permissionErrorHeader = "Cannot access your microphone";
        break;
      case PermissionGrant.checking:
        permissionErrorMessage = "Checking Permissions";
        permissionErrorHeader = "Please wait for a While";
        break;
      case PermissionGrant.notification:
        permissionErrorMessage = "Please allow us to send notifications";
        permissionErrorHeader = "Cannot send notifications";
        break;
    }
    return MapEntry(permissionErrorHeader, permissionErrorMessage);
  }

  String get message {
    switch (this) {
      case PermissionGrant.location:
        return "assets/issue/Allow Your Location.png";
      case PermissionGrant.camera:
        return "assets/issue/camera.png";
      case PermissionGrant.microphone:
        return "assets/issue/microphone.png";
      case PermissionGrant.checking:
        return "assets/issue/permission.png";
      case PermissionGrant.notification:
        return "assets/issue/permission.png";
    }
  }

  static Future<PermissionGrant?> checkPermissions(BuildContext context) async {
    PermissionGrant? permissionGranted;
    if (!isPermissionChecking) {
      isPermissionChecking = true;
      if (await Permission.locationWhenInUse.status !=
          PermissionStatus.granted) {
        permissionGranted = PermissionGrant.location;
      } else if (await Permission.camera.status != PermissionStatus.granted) {
        permissionGranted = PermissionGrant.camera;
      } else if (await Permission.microphone.status !=
          PermissionStatus.granted) {
        permissionGranted = PermissionGrant.microphone;
      } else {
        permissionGranted = null;
      }
      isPermissionChecking = false;
    }
    if (permissionGranted != null) {
      CustomSnackBar().info(permissionGranted.toString());
      return permissionGranted;
    }
    return null;
  }

  static Future<PermissionGrant?> initializePermisssion(BuildContext context,
      {bool onlyNotification = false}) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!onlyNotification) {
      await requestPermissions();
      return checkPermissions(context);
    }
    PermissionGrant? grant = await requestNotificationPermissions();
    bool given = await checkIfNotificationPermissionsProvided();
    if (!given) return PermissionGrant.notification;
    return null;
  }

  static Future<bool> checkIfNotificationPermissionsProvided() async {
    try {
      List<NotificationPermission> activityAllowed =
          await AwesomeNotifications().checkPermissionList(
              channelKey: "activity", permissions: notificationListActivity);
      List<NotificationPermission> alertAllowed = await AwesomeNotifications()
          .checkPermissionList(
              channelKey: "alerts", permissions: notificationListAlerts);
      return activityAllowed.length >= 4 && alertAllowed.length >= 2;
    } catch (e) {
      print(e);
      return true;
    }
  }

  static Future<PermissionGrant?> requestNotificationPermissions() async {
    try {
      // await CustomCloudMessaging.requestPermission();
      if (await AwesomeNotifications().requestPermissionToSendNotifications(
              channelKey: "activity", permissions: notificationListActivity) &&
          await AwesomeNotifications().requestPermissionToSendNotifications(
              channelKey: "alerts", permissions: notificationListAlerts)) {
        return null;
      }
      return PermissionGrant.notification;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static final List<NotificationPermission> notificationListActivity = [
    NotificationPermission.FullScreenIntent,
    NotificationPermission.Sound,
    NotificationPermission.Vibration,
    NotificationPermission.Alert
  ];

  static final List<NotificationPermission> notificationListAlerts = [
    NotificationPermission.Sound,
    NotificationPermission.Vibration,
    NotificationPermission.Alert
  ];

  static Future<void> requestPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.notification.request();
  }
}
