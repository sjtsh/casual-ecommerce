import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Components/snackbar/customsnackbar.dart';
import '../../UI/DialogBox/customdialogbox.dart';
import 'StaticService.dart';

class IntentService {
  static Future<void> makePhoneCall(
      BuildContext context, String phoneNumber) async {
    NavigatorState nav = Navigator.of(context);
    StaticService.showDialogBox(
        context: context,
        child: CustomDialog(
            textFirst: "Are you sure?",
            textSecond: "You are trying to call $phoneNumber.",
            elevatedButtonText: "Call",
            onPressedElevated: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: phoneNumber,
              );
              try {
                await launchUrl(launchUri);
              } catch (e) {
                print("cannot call $e");
                CustomSnackBar().error("Could not make phone call");
              }
              nav.pop();
            }));
  }

  // static Future<void> showDirection(BuildContext context, Order order) async {
  //   //Todo : show directions
  //   String homeLat = context.read<SignInManagement>().loginData!.staff.shop!.first.lat.toString();
  //   String homeLng = context.read<SignInManagement>().loginData!.staff.shop!.first.lng.toString();
  //   String desLat = order.lat.toString();
  //   String desLng = order.lng.toString();
  //   NavigatorState nav = Navigator.of(context);
  //   StaticService.showDialogBox(
  //       context: context,
  //       child: CustomDialog(
  //           textFirst: "Are you sure to open maps?",
  //           textSecond: "Open maps to see directions.",
  //           elevatedButtonText: "Open",
  //           onPressedElevated: () async {
  //             final String googleMapslocationUrl =
  //                 "http://maps.google.com/maps?saddr=$homeLat,$homeLng&daddr=$desLat,$desLng";
  //             final String googleMapslocationUrlFlipped =
  //                 "http://maps.google.com/maps?saddr=$homeLat,$homeLng&daddr=$desLng,$desLat";
  //             if (await canLaunchUrl(Uri.parse(googleMapslocationUrl))) {
  //               await launch(Uri.encodeFull(googleMapslocationUrl));
  //             } else if (await canLaunchUrl(
  //                 Uri.parse(googleMapslocationUrlFlipped))) {
  //               await launch(Uri.encodeFull(googleMapslocationUrlFlipped));
  //             } else {
  //               try {
  //                 await launch(Uri.encodeFull(googleMapslocationUrl));
  //               } catch (E) {
  //                 CustomSnackBar().error("Could not find the location");
  //                 throw 'Could not launch $E';
  //               }
  //             }
  //             nav.pop();
  //           }));
  // }

  // static Future<void> showDirectionFromStartDelivery(
  //     //Todo : show direction from delivery
  //     BuildContext context, Order order) async {
  //   String homeLat = context.read<SignInManagement>().loginData!.staff.shop!.first.lat.toString();
  //   String homeLng = context.read<SignInManagement>().loginData!.staff.shop!.first.lng.toString();
  //   String desLat = order.lat.toString();
  //   String desLng = order.lng.toString();
  //
  //   final String googleMapslocationUrl =
  //       "http://maps.google.com/maps?saddr=$homeLat,$homeLng&daddr=$desLat,$desLng";
  //   final String googleMapslocationUrlFlipped =
  //       "http://maps.google.com/maps?saddr=$homeLat,$homeLng&daddr=$desLng,$desLat";
  //   if (await canLaunchUrl(Uri.parse(googleMapslocationUrl))) {
  //     await launch(Uri.encodeFull(googleMapslocationUrl));
  //   } else if (await canLaunchUrl(Uri.parse(googleMapslocationUrlFlipped))) {
  //     await launch(Uri.encodeFull(googleMapslocationUrlFlipped));
  //   } else {
  //     try {
  //       await launch(Uri.encodeFull(googleMapslocationUrl));
  //     } catch (E) {
  //       CustomSnackBar().error("Could not find the location");
  //       throw 'Could not launch $E';
  //     }
  //   }
  // }
}
