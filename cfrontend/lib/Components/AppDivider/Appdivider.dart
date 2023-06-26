import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../CustomTheme.dart';

class AppDivider extends StatelessWidget {
  final double ? height;
  const AppDivider({this.height,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height:height?? 1,
        color: context
            .watch<CustomTheme>()
            .isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black
            .withOpacity(0.1)
    );
  }
}
