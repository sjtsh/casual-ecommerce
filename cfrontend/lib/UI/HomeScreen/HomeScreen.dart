import 'dart:async';

import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/keys.dart';
import 'package:flutter/material.dart';

import '../../BackEnd/Enums/Roles.dart';
import '../Product/SubproductScreen/SubProductScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PeriodicRefreshManagement.startLogoutTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BuildContext ctx = (CustomKeys.context ?? context);
    StaticService.lifeCycleState = state;
    if (state == AppLifecycleState.resumed) {
      // ctx.read<LandingPageManagement>().changeIndex(0, false, false);
      // StaticService.initialPhase2(ctx);
    } else if (state == AppLifecycleState.paused) {
      // OrderSocket.socket?.close();
      // if (mounted) {
      //   ctx.read<HiveManagement>().saveAll(ctx);
      // }
    }
    StaticService.lifeCycleState = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // OrderSocket.socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // if (Roles.getOrderRoles().isEmpty && Roles.getDeliveryRoles().isEmpty) {
      return const SubProductScreen(
        onlyProduct: true,
      );

  }
}
