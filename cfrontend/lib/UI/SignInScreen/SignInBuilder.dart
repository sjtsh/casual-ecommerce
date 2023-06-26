import 'package:ezdelivershop/Pre/ConfirmPermissionThen.dart';
import 'package:ezdelivershop/Pre/HomeInit1.dart';
import 'package:ezdelivershop/UI/HomeScreen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Pre/HomeInit2.dart';
import '../../StateManagement/SignInManagement.dart';
import 'SignInScreen.dart';

class SignInBuilder extends StatelessWidget {
  const SignInBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.watch<SignInManagement>().authToken == null) {
      return const SignInScreen();
    }
    return ConfirmPermissionThen(
      permitted: false,
      onlyNotification: false,
      child: HomeInit1(child: HomeInit2(child: const HomeScreen())),
    );
  }
}
