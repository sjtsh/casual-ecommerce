
import 'package:flutter/material.dart';

class OverrideBack extends StatelessWidget {
  final Widget child;

  OverrideBack({required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // bool success = context.read<LandingPageManagement>().backPressed();
          // if (success) return Future.value(false);
          // DateTime? pressed =
          //     context.read<LandingPageManagement>().lastBackPressed;
          // int? difference =
          //     pressed?.difference(DateTime.now()).inMilliseconds.abs();
          // if ((difference ?? 1000) < 1000) {
          //   StaticService.minimize();
          // } else {
          //   context.read<LandingPageManagement>().lastBackPressed =
          //       DateTime.now();
          //   Fluttertoast.showToast(
          //       msg: "Press again to exit",
          //       toastLength: Toast.LENGTH_SHORT,
          //       gravity: ToastGravity.BOTTOM,
          //       textColor: Colors.white,
          //       fontSize: 10.0);
          // }
          return Future.value(false);
        },
        child: child);
  }
}
