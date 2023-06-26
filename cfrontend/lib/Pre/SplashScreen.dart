import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LayoutBuilder(builder: (context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/splash.png",
                    height: 70,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: constraints.maxWidth / 2.2,
                    child: LinearProgressIndicator(
                      backgroundColor: context.read<CustomTheme>().isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ]),
          );
        }));
  }
}
