import 'package:flutter/material.dart';
class CustomSafeArea extends StatelessWidget {
  const CustomSafeArea({Key? key, required this.child, this.color})
      : super(key: key);
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Container(color: color ?? Theme.of(context).scaffoldBackgroundColor, child: SafeArea(child: child));
}
