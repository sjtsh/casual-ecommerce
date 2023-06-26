import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../BackEnd/Enums/PermissionGrant.dart';

class ConfirmPermissionThen extends StatefulWidget {
  final bool permitted;
  final Widget child;
  final bool onlyNotification;

  const ConfirmPermissionThen(
      {super.key,
      required this.child,
      required this.permitted,
      this.onlyNotification = false});

  @override
  State<ConfirmPermissionThen> createState() => _ConfirmPermissionThenState();
}

class _ConfirmPermissionThenState extends State<ConfirmPermissionThen>
    with WidgetsBindingObserver {
  PermissionGrant? permitted;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if(mounted){
      if (!widget.permitted) initializeFunction();
    }

  }

  initializeFunction() async {
    if (!loading) {
      loading = true;
      // scheduleMicrotask(() async {
      permitted = await PermissionGrant.initializePermisssion(context,
          onlyNotification: widget.onlyNotification);
      // });
      setState(() => loading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) initializeFunction();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return buildGrantWidget(PermissionGrant.checking);
    }
    if (permitted == null) return widget.child;
    return buildGrantWidget(permitted!);
  }

  buildGrantWidget(PermissionGrant permitted) {
    MapEntry<String, String> errorMessage = permitted.errorMessage();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset(permitted.message),
          ),
          SpacePalette.spaceLargest,
          Center(
              child: Text(
            errorMessage.key,
            style: Theme.of(context).textTheme.headline2,
          )),
          SpacePalette.spaceMedium,
          Text(
            errorMessage.value,
            style: Theme.of(context).textTheme.headline5,
          ),
          Expanded(child: Container()),
          const AppButtonPrimary(
              width: 300,
              borderRadius: 30,
              onPressedFunction: openAppSettings,
              text: "GO TO SETTINGS"),
          SpacePalette.spaceExtraLarge,

          // GestureDetector(
          //     onTap: openAppSettings, child: const Text("Go to settings")),
          // GestureDetector(onTap: permitted.request, child: const Text("Request"))
        ],
      ),
    );
  }
}
