import 'package:flutter/material.dart';

class CheckWithCategoriesScreen extends StatelessWidget {
  final Widget child;

  CheckWithCategoriesScreen({required this.child});

  @override
  Widget build(BuildContext context) {
    // if (context.watch<SignInManagement>().shop?.categories.isEmpty ?? false) {
    //   return CategoriesScreenBuilder(
    //       context.watch<SignInManagement>().shop!.categories,
    //       isFromSignup: false, withoutPop: true);
    // }
    return child;
  }
}
