import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../BackEnd/Entities/Shop.dart';
import '../../../Components/CustomTheme.dart';

class ShopImage extends StatelessWidget {
  final Shop shop;

  const ShopImage({required this.shop, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(
              color: context.watch<CustomTheme>().isDarkMode
                  ? ColorPalette.darkContainerColor
                  : Theme.of(context).dividerColor,
              width: 2),
          // shape: BoxShape.circle,
          image: shop.image == null
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(
                    shop.image!,
                  ),
                  fit: BoxFit.cover)),
      child: shop.image == null
          ? Center(
              child: Text(
                 shop.name[0],
                style: Theme.of(context).textTheme.headline5
              ),
            )
          : Container(),
    );
  }
}
