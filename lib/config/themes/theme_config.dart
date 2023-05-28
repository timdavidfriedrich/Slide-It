import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rating/constants/constants.dart';

class ThemeConfig {
  static const ColorScheme _defaultLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.green,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Color(0xFF101010),
    onBackground: Colors.white,
    surface: Color(0x0AFFFFFF),
    onSurface: Colors.white,
  );

  static const ColorScheme _defaultDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.green,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Color(0xFF101010),
    onBackground: Colors.white,
    surface: Color(0x0AFFFFFF),
    onSurface: Colors.white,
  );

  static ThemeData _dynamicThemeData(BuildContext context, ColorScheme? deviceColorScheme, Brightness brightness) {
    ColorScheme defaultColorScheme = brightness == Brightness.dark ? _defaultDarkColorScheme : _defaultLightColorScheme;
    ColorScheme? dynamicColorScheme = deviceColorScheme?.copyWith(primary: defaultColorScheme.primary);
    ColorScheme colorScheme = dynamicColorScheme ?? defaultColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        color: colorScheme.background,
        titleSpacing: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: colorScheme.background,
      // cardTheme: CardTheme(
      //   elevation: 0,
      //   color: colorScheme.surface,
      //   margin: EdgeInsets.zero,
      // ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Constants.defaultBorderRadius)),
        alignLabelWithHint: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(16, 0, 16, 0)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.primary.withOpacity(0.1);
            }
            if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
              return colorScheme.primary.withOpacity(0.2);
            }
            return colorScheme.primary;
          }),
          foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(32, 16, 32, 16)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.primary.withOpacity(0.1);
            }
            if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
              return colorScheme.primary.withOpacity(0.2);
            }
            return colorScheme.primary;
          }),
          foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        applyThemeToAll: true,
        barBackgroundColor: colorScheme.background,
        scaffoldBackgroundColor: colorScheme.background,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          titleLarge: TextStyle(
            fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.25,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          titleSmall: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData light(BuildContext context, ColorScheme? dynamicColorScheme) {
    Brightness brightness = Brightness.light;
    return _dynamicThemeData(context, dynamicColorScheme, brightness);
  }

  static ThemeData dark(BuildContext context, ColorScheme? dynamicColorScheme) {
    Brightness brightness = Brightness.dark;
    return _dynamicThemeData(context, dynamicColorScheme, brightness);
  }
}
