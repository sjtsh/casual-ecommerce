import 'package:flutter/material.dart';

class SpacePalette {
  static SizedBox get spaceLargest => const SizedBox(height: 32, width: 32);

  static SizedBox get spaceExtraLarge => const SizedBox(height: 24, width: 24);

  static SizedBox get spaceLarge => const SizedBox(height: 20, width: 20);

  static SizedBox get spaceMedium => const SizedBox(height: 12, width: 12);

  static SizedBox get spaceSmall => const SizedBox(height: 6, width: 6);

  static SizedBox get spaceTiny => const SizedBox(height: 4, width: 4);

  static EdgeInsets get paddingSmall => const EdgeInsets.all(6);

  static EdgeInsets get paddingMediumV =>
      const EdgeInsets.symmetric(vertical: 8);

  static EdgeInsets get paddingMedium => const EdgeInsets.all(10);

  static EdgeInsets get paddingLarge => const EdgeInsets.all(12);
  static EdgeInsets get paddingExtraLarge => const EdgeInsets.all(20);

  static EdgeInsets get paddingLargeH =>
      const EdgeInsets.symmetric(horizontal: 12);
  static EdgeInsets get paddingExtraLargeH =>
      const EdgeInsets.symmetric(horizontal: 20);

  static EdgeInsets get paddingExtraLargeR => const EdgeInsets.only(right: 12);

  static Widget addPaddingMediumV(Widget child) =>
      Padding(padding: paddingMediumV, child: child);
}
