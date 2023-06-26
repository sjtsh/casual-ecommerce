import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../Components/CustomTheme.dart';
import '../../StateManagement/SignInManagement.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.watch<CustomTheme>().isDarkMode ? ColorPalette.darkContainerColor:Colors.grey.shade300,
      highlightColor:context.watch<CustomTheme>().isDarkMode ? ColorPalette.grey: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          Center(
            child: Stack(
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).splashColor,
                    border:
                    Border.all(color: Theme.of(context).dividerColor),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 6,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                        color: (context
                            .watch<
                            SignInManagement>()
                            .loginData?.staff
                            .available ??
                            false) ==
                            true
                            ? Colors.green
                            : Colors.transparent,
                        shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 14,
            width: 60,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 7,
          ),
          Container(
            height: 14,
            width: 60,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
