import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Components/CustomTheme.dart';
import '../Components/keys.dart';
import 'MyApp.dart';

class WrapWithMaterialApp extends StatelessWidget {
  final Widget child;
  WrapWithMaterialApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: CustomKeys.messengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Faasto Partner',
        navigatorKey: MyApp.navigatorKey,
        themeMode: context.watch<CustomTheme>().themeMode,
        darkTheme: context.read<CustomTheme>().darkTheme,
        theme: context.read<CustomTheme>().lightTheme,
        home: child);
  }
}
