import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/CustomTheme.dart';
import '../Components/keys.dart';

class WithTheme extends StatefulWidget {
  final Widget child;

  WithTheme({required this.child});

  @override
  State<WithTheme> createState() => _WithThemeState();
}

class _WithThemeState extends State<WithTheme> {
  Future<SharedPreferences>? function;

  @override
  void initState() {
    CustomKeys.context = context;
    super.initState();
    function = SharedPreferences.getInstance().then((value) async {
      context.read<CustomTheme>().initializeSelectedTheme(value);
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
        future: function,
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (!snapshot.hasData) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black);
          }
          return widget.child;
        });
  }
}
