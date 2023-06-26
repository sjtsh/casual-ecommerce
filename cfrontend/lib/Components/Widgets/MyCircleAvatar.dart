import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BackEnd/StaticService/StaticService.dart';
import '../Constants/ColorPalette.dart';
import '../Constants/SpacePalette.dart';
import '../CustomTheme.dart';
import '../../StateManagement/DeliveryRadiusManagement.dart';
import '../../StateManagement/SignInManagement.dart';
import '../../UI/ProfileScreen/ProfileScreen.dart';

class MyCircleAvatar extends StatelessWidget {
  const MyCircleAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignInManagement watch = context.watch<SignInManagement>();
    return GestureDetector(
      onTap: () =>
          StaticService.pushPage(context: context, route: ProfileScreen()),
      child: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  // color: Colors.white,
                  border: Border.all(
                      color: context.watch<CustomTheme>().isDarkMode
                          ? ColorPalette.dividerColor
                          : Theme.of(context).dividerColor,
                      width: 2),
                  shape: BoxShape.circle,
                  image: watch.loginData?.user.image == null
                      ? null
                      : DecorationImage(
                          image: CachedNetworkImageProvider(
                            watch.loginData?.user.image ?? "",
                          ),
                          fit: BoxFit.cover)),
              child: watch.loginData?.user.image == null
                  ? Padding(
                      padding: SpacePalette.paddingMedium,
                      child: Text(
                          (watch.loginData?.user.name ?? "").isEmpty
                              ? "-"
                              : watch.loginData!.user.name[0],
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    )
                  : Container()),
          Builder(builder: (context) {
            SignInManagement watch = context.watch<SignInManagement>();
            DeliveryRadiusManagement watchOnline =
                context.watch<DeliveryRadiusManagement>();
            return Positioned(
              bottom: 7,
              right: 0,
              child: StaticService.showOnline(
                  condition: (watch.loginData?.staff.available ?? false) &&
                      watchOnline.online),
            );
          })
        ],
      ),
    );
  }
}
