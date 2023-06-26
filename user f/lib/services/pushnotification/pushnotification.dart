import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:firebase_core/firebase_core.dart';

final CustomCloudMessaging cloudMessaging = CustomCloudMessaging._();

class CustomCloudMessaging {
  static late NotificationSettings settings;
  CustomCloudMessaging._();

  Future<bool> initFirebase() async {
    try {
      // if (UniversalPlatform.isDesktop) {
      //   await Firebase.initializeApp(
      //       options: const FirebaseOptions(
      //           apiKey: 'AIzaSyBuiodfpX3kQp8gnVQZdbD2w0mVFrilGJE',
      //           appId: '1:759501068226:android:f3205722747b213138e85b',
      //           messagingSenderId: '',
      //           projectId: 'inline-ae928'));
      //   return true;
      // } else
      {
        if (!UniversalPlatform.isWeb && !UniversalPlatform.isDesktop) {
          await Firebase.initializeApp();
          return true;
        } else {
          await Firebase.initializeApp(
            options: const FirebaseOptions(
                apiKey: "AIzaSyCnVAiK-L8VM_vA5qI_5xbOim525BYAs3Q",
                appId: "1:543501648377:web:3faf49752718b4e06bfd28",
                messagingSenderId: "543501648377",
                projectId: "ezdelivery-a538c"),
          );
          return true;
        }
      }
    } catch (e, s) {
      print("$e $s");
      return false;
    }
  }

  Future<bool> init() async {
    messaging = FirebaseMessaging.instance;
    var permission = await requestPermission();

    if (!permission) {
      print(permission);
      FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
    if (!UniversalPlatform.isDesktop) {
      try {
        var token = await messaging.getToken();
        if (token != null) {
          // print(token);
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            print("Foreground Message: ${message.data}");
          });
          return true;
        } else {
          return false;
        }
      } catch (e, s) {
        print("$e $s");
        return false;
      }
    }
    return false;
  }

  static Future<bool> requestPermission() async {
    settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    var status = settings.authorizationStatus == AuthorizationStatus.authorized;

    return status;
  }
}
