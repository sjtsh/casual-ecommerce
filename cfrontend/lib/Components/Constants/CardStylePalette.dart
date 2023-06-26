import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:flutter/material.dart';

class CardStylePalette {
  static BoxShadow get kBoxShadow => BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 5,
      color: Colors.black.withOpacity(0.1));
  static BoxShadow get kBoxShadowDark => BoxShadow(
      offset: const Offset(1, 1),
      blurRadius: 5,
      color: Colors.black.withOpacity(0.3));

  static BoxDecoration get kCardDecoration => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [kBoxShadow]);

  static BoxDecoration get kCardDecorationDark => BoxDecoration(
      color: ColorPalette.darkContainerColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [kBoxShadow]);

  static BoxDecoration get kBottomSheetCardDecorationDark => BoxDecoration(
        color: ColorPalette.darkBottomSheetContainerColor,
        borderRadius: BorderRadius.circular(8),
      );
  static BoxDecoration get kBottomSheetCardDecoration => BoxDecoration(
    color:ColorPalette.primaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  );
}
