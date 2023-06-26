import 'package:ezdelivershop/StateManagement/SplashScreenManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../BackEnd/StaticService/StaticService.dart';
import 'SplashScreen.dart';

class HomeInit1 extends StatefulWidget {
  final Widget child;

  HomeInit1({required this.child});

  @override
  State<HomeInit1> createState() => _HomeInit1State();
}

class _HomeInit1State extends State<HomeInit1> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // StaticService.intentFromNotification();
      StaticService.initialPhase1(context, home: true).then((value) {
        if(mounted){
          context.read<SplashScreenManagement>().phase1Completed = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<SplashScreenManagement>().phase1Completed) {
      return widget.child;
    }
    return SplashScreen();
  }
}
