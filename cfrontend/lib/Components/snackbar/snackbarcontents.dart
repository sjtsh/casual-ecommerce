import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Constants/TextStylePalette.dart';

import 'package:flutter/material.dart';

class CustomSnackBarContent extends StatelessWidget {
  const CustomSnackBarContent({
    Key? key,
    required this.message,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 345,
      child: Row(
        children: [
          SpacePalette.spaceTiny,
          Container(
            height: 26,
            width: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        SpacePalette.spaceMedium,
          Icon(
            icon,
            size: 26,
            color: color,
          ),
          SpacePalette.spaceMedium,
          Expanded(
            child: Text(
              message.toString(),
              maxLines: 2,
              style: TextStylePalette.kTextStyleInterMedium.copyWith(
                  fontSize: 15, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
