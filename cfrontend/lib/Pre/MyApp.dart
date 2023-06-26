import 'package:ezdelivershop/Pre/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'CheckInternetConnection.dart';
import 'OverrideBack.dart';
import 'SessionInitialization.dart';
import 'WithTheme.dart';
import 'WrapWithMaterialApp.dart';

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return withProvider(
      child: WrapWithMaterialApp(
        child: OverrideBack(
          child: Scaffold(
            backgroundColor: const Color(0xfff2f2f2),
            body: WithTheme(
              child: CheckInternetConnection(child: SessionInitialization()),
              // child: CheckVersion(child:  SessionInitialization())
            ),
          ),
        ),
      ),
    );
  }
}
