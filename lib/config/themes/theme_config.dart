import 'package:flutter/material.dart';

class ThemeConfig {
  static ThemeData light(BuildContext context, ColorScheme? colorScheme) {
    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      brightness: Brightness.light,
      colorScheme: colorScheme,
    );
  }

  static ThemeData dark(BuildContext context, ColorScheme? colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );
  }
}
