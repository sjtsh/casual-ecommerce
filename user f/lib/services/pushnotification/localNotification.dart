import 'dart:math';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderdetail.dart';

class CustomLocalNotification {
  static orderUpdate(StatusClass data, String orderId) {
    notify(
        title: "Order ${data.label}",
        body: data.detail,
        payload: {"order_id": orderId});
  }

  static ratedbyshop(String shop, int rating) {
    notify(
      title: "Rating from $shop",
      body: rating == 0 ? "You got ⭐" : "You got $rating⭐",
    );
  }

  static otpShop(
      {required String staff, required int otp, required String orderId}) {
    notify(
        title: "Your Delivery guy $staff is here.",
        body: "OTP Code: $otp",
        payload: {"order_id": orderId});
  }

  static endDelivery(String orderId) {
    notify(
        title: "Order has arrived!", body: "", payload: {"order_id": orderId});
  }

  static handleTapOrder(String? payload, {BuildContext? context}) {
    if (payload != null) {
      try {
        var json = jsonDecode(payload);

        CustomKeys.ref
            .read(orderHistoryServiceProvider)
            .fetchOneOrder(id: json["order_id"]);

        Utilities.pushPage(const OrderDetail(), 200,
            context: context, id: json["order_id"]);
      } catch (e) {
        print("invalid json data");
      }
    }
  }

  static notify(
      {int? id,
      String title = '',
      String body = "",
      Map<String, String>? payload}) {
    const max = 1000000000;
    id ??= Random().nextInt(max);
    flutterLocalNotificationsPlugin.cancel(id);
    flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails("activity", "activity",
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              icon: "@drawable/ic_launcher",
              largeIcon:
                  const DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
              color: CustomTheme.primaryColor

              // sound: RawResourceAndroidNotificationSound('message_notification'),
              // fullScreenIntent: true,
              // actions: [
              //   AndroidNotificationAction(
              //       Random().nextInt(1000000000).toString(), 'Dismiss',
              //       titleColor: Colors.red,
              //       showsUserInterface: true,
              //       cancelNotification: true),
              //   AndroidNotificationAction(
              //       Random().nextInt(1000000000).toString(), 'Accept',
              //       // titleColor: primaryColor,
              //       showsUserInterface: true,
              //       cancelNotification: true)
              // ]
              ),
        ),
        payload: json.encode(payload));
  }
}
