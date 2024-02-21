import 'package:flutter/material.dart';

class Palettes {}

class BasicPalette {
  static ThemeData normalTheme = ThemeData(
    primaryColor: BasicPalette.primaryColor,
    backgroundColor: BasicPalette.backgroundColor,
    splashColor: BasicPalette.accentColor,
    disabledColor: BasicPalette.disabledColor,
  );

  static Color get primaryColor => const Color.fromRGBO(136, 174, 27, 1);

  static Color get accentColor => const Color.fromRGBO(115, 145, 21, 1);

  static Color get backgroundColor => const Color.fromRGBO(255, 255, 255, 1);

  static Color get disabledColor => const Color.fromRGBO(175, 175, 175, 1);

  static Color get heatColor => const Color.fromRGBO(231, 216, 125, 1);

  static Color get coolColor => const Color.fromRGBO(99, 157, 209, 1);
}
