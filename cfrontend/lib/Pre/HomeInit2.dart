import 'package:ezdelivershop/Components/keys.dart';
import 'package:ezdelivershop/StateManagement/SplashScreenManagement.dart';
import 'package:ezdelivershop/UI/HomeScreen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../BackEnd/StaticService/StaticService.dart';
import '../SocketService/OrderRequestSocket.dart';
import 'SplashScreen.dart';

class HomeInit2 extends StatefulWidget {
  final Widget child;

  HomeInit2({required this.child});

  @override
  State<HomeInit2> createState() => _HomeInit2State();
}

class _HomeInit2State extends State<HomeInit2> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if(OrderSocket.socket == null){
    //     StaticService.initialPhase2(context).then((value) =>
    //         context.read<SplashScreenManagement>().phase2Completed = true);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SplashScreenManagement>();
    // if ((CustomKeys.context ?? context).watch<SplashScreenManagement>().phase2Completed) {
      return const HomeScreen();
    // }
    // return SplashScreen();
  }
}
