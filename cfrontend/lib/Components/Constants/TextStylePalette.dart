import 'package:flutter/material.dart';

import 'ColorPalette.dart';

class TextStylePalette {
  static TextStyle get kTextStyleInterMedium => const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black);

  static TextStyle get kTextStyleInterSemiBold => const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black);

  static TextStyle get kTextStyleInterLarge => const TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Color(0xffFF2E00));

  static TextStyle get kTextStyleInterRegular => const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white);

  static TextStyle get kTextStyleErrorStyle =>
      TextStyle(fontSize: 10, color: ColorPalette.danger);
}
