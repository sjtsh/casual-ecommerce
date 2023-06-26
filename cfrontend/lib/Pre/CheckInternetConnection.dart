import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezdelivershop/Components/Issue/IssueScreen.dart';
import 'package:flutter/material.dart';
import 'SplashScreen.dart';

class CheckInternetConnection extends StatefulWidget {
  final Widget child;

  CheckInternetConnection({required this.child});

  @override
  State<CheckInternetConnection> createState() =>
      _CheckInternetConnectionState();
}

class _CheckInternetConnectionState extends State<CheckInternetConnection> {
  bool? connection;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((value) => c(value).then((value) {
          Connectivity()
              .onConnectivityChanged
              .listen((ConnectivityResult event) => c(event));
        }));
  }

  Future<void> c(ConnectivityResult event) async =>
      setState(() => connection = event != ConnectivityResult.none);

  @override
  Widget build(BuildContext context) {
    if (connection == null) {
      return SplashScreen();
    }
    if (connection!) return widget.child;
    return const IssueScreen(
        image: "assets/issue/no_internet.png",
        title: "Opps!",
        subTitle: "No internet connection");
  }
}
