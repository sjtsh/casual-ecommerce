import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../StateManagement/SignInManagement.dart';
import '../UI/SignInScreen/SignInBuilder.dart';
import '../UI/SignInScreen/SignInScreen.dart';
import 'SplashScreen.dart';

class SessionInitialization extends StatefulWidget {
  @override
  State<SessionInitialization> createState() => _SessionInitializationState();
}

class _SessionInitializationState extends State<SessionInitialization> {
  Future<SharedPreferences>? function;

  @override
  void initState() {
    super.initState();
    function = SharedPreferences.getInstance().then((value) async {
      context.read<SignInManagement>().getFromPrefs(value);
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: function,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const SignInScreen();
          }
          if (snapshot.hasData) {
            return const SignInBuilder();
          }
          return SplashScreen();
        });
  }
}
