import '../../Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/snackbar/snackbarcontents.dart';
import 'package:flutter/material.dart';

import '../keys.dart';

class CustomSnackBar {
  static Map<String, bool> alive = {};

  success(dynamic message) {
    showSnackBar(
        color: ColorPalette.successSecondary,
        content: CustomSnackBarContent(
          icon: Icons.check_circle_outline,
          message: message.toString(),
          color: ColorPalette.successColor,
        ),
        message: message);
  }

  error(dynamic message) {
    showSnackBar(
        color: ColorPalette.dangerSecondary,
        content: CustomSnackBarContent(
          icon: Icons.cancel_outlined,
          message: message.toString(),
          color: ColorPalette.danger,
        ),
        message: message);
  }

  noInternet() {
    showSnackBar(
        message: "No Internet Connection!",
        color: Colors.red,
        content: const CustomSnackBarContent(
          color: Color(0xff1400FF),
          icon: Icons.info,
          message: "No Internet Connection!",
        ));
  }

  info(dynamic message) {
    showSnackBar(
        color: ColorPalette.primarySecondary,
        content: CustomSnackBarContent(
          color: ColorPalette.primaryColor,
          icon: Icons.info_outline,
          message: message.toString(),
        ),
        message: message);
  }

  Future showSnackBar({required Widget content,
    required Color color,
    required dynamic message}) async {
    // CustomKeys().ref!.read(snackVisibleProvider.state).state = true;
    var context = CustomKeys.messengerKey;
    if (!alive.containsKey(message.toString())) {
      alive[message.toString()] = true;
      await context.currentState!
          .showSnackBar(returnSnackBar(color, content))
          .closed;
      alive.remove(message.toString());
    }
  }


  static SnackBar returnSnackBar(Color color, Widget content) {
    return SnackBar(
      // behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      backgroundColor: color,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      duration: const Duration(milliseconds: 2000),
      content: content,
      onVisible: () {},
    );
  }
}
