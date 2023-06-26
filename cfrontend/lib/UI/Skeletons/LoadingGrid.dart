import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Components/Constants/ColorPalette.dart';
import '../../Components/Constants/SpacePalette.dart';
import '../../Components/CustomTheme.dart';

class LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Shimmer.fromColors(
          baseColor: context.watch<CustomTheme>().isDarkMode
              ? ColorPalette.darkContainerColor
              : Colors.grey.shade300,
          highlightColor: context.watch<CustomTheme>().isDarkMode
              ? ColorPalette.grey
              : Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl:
                        "https://techwol.com/pasalko/images/alternate.png",
                    height: 60,
                    width: 60),
              ),
              SpacePalette.spaceMedium,
              SizedBox(
                height: 12,
                child: Container(
                  height: 6,
                  width: 100,
                  color: Colors.white,
                ),
              ),
            ],
          )),
    );
  }
}
