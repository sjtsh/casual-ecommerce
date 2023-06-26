import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Components/Constants/ColorPalette.dart';
import '../../Components/CustomTheme.dart';

class LoadingImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: context.watch<CustomTheme>().isDarkMode
            ? ColorPalette.darkContainerColor
            : Colors.grey.shade300,
        highlightColor: context.watch<CustomTheme>().isDarkMode
            ? ColorPalette.grey
            : Colors.white,
        child: CachedNetworkImage(
            fit: BoxFit.contain,
            imageUrl: StaticService.getImage(),
            height: 60,
            width: 60));
  }
}
