import 'package:ezdeliver/screen/component/helper/exporter.dart';

class Pasalko {
  static Future<String?> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // if (kDebugMode) {
    //   FlutterBackground.initialize()
    //       .then((value) => FlutterBackground.enableBackgroundExecution());
    // }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    UpdateService().checkForInAppUpdate();
    await GetStorage.init();
    // storage.erase();

    await cloudMessaging.initFirebase();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOs,
    );

    //when the app is in foreground state and you click on notification.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (data) {
      CustomLocalNotification.handleTapOrder(
        data.payload,
      );
    });

    String? payload;

    final NotificationAppLaunchDetails? notificationAppLaunchDetails;
    if (UniversalPlatform.isAndroid) {
      notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails != null) {
        if (notificationAppLaunchDetails.didNotificationLaunchApp) {
          if (notificationAppLaunchDetails.notificationResponse != null) {
            flutterLocalNotificationsPlugin.cancelAll();
            payload =
                notificationAppLaunchDetails.notificationResponse!.payload;
          }
        }
      }
    }

    // // ignore: prefer_const_constructors
    // var openedFromNotification =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // if (openedFromNotification != null) {
    //   print(payload);
    //   payload = openedFromNotification.data.toString();
    // }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // final remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.setConfigSettings(RemoteConfigSettings(
    //   fetchTimeout: const Duration(minutes: 1),
    //   minimumFetchInterval: const Duration(hours: 1),
    // ));

    // if (FirebaseRemoteConfig.instance.getBool("clearStorage")) {
    //   storage.erase();
    // }
    return payload;
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    // await Firebase.initializeApp();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOs = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOs,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPluginBg =
        FlutterLocalNotificationsPlugin();
    //when the app is in foreground state and you click on notification.
    await flutterLocalNotificationsPluginBg.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (data) {
      CustomLocalNotification.handleTapOrder(
        data.payload,
      );
    });

    // print(message.data);

    CustomLocalNotification.orderUpdate(
        getStatusDetail(message.data["isRequest"] == "true"
            ? getStatusForFeedback(int.parse(message.data["status"]))
            : getStatus(int.parse(message.data["status"]))),
        message.data["order_id"]);
  }
}
