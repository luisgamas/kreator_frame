// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:google_fonts/google_fonts.dart';

// 🌎 Project imports:
import 'package:kreator_frame/shared/utils/dynamic_color_validator.dart';

class AppTheme {
  final Color primaryColor;
  final ColorScheme? dynamicColorScheme;

  AppTheme({
    required this.primaryColor,
    this.dynamicColorScheme,
  });

  late final ThemeData lightTheme = _buildTheme(Brightness.light);
  late final ThemeData darkTheme = _buildTheme(Brightness.dark);

  /// Whether the dynamic color scheme was actually used.
  /// Returns false if the scheme was null or degenerate (Samsung/Xiaomi bug).
  late final bool dynamicColorApplied = DynamicColorValidator.validate(dynamicColorScheme) != null;

  ThemeData _buildTheme(Brightness brightness) {
    // Validate dynamic color scheme — null or degenerate schemes fall back to seed
    final validatedDynamic = DynamicColorValidator.validate(dynamicColorScheme);
    final colorScheme = validatedDynamic ?? ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final baseTheme = colorScheme.brightness == Brightness.light 
      ? Typography.material2021().black 
      : Typography.material2021().white;
    final headsThemes = GoogleFonts.googleSansTextTheme(baseTheme);
    final bodysThemes = GoogleFonts.robotoFlexTextTheme(baseTheme);

    return baseTheme.copyWith(
      displayLarge: headsThemes.displayLarge,
      displayMedium: headsThemes.displayMedium,
      displaySmall: headsThemes.displaySmall,
      headlineLarge: headsThemes.headlineLarge,
      headlineMedium: headsThemes.headlineMedium,
      headlineSmall: headsThemes.headlineSmall,
      titleLarge: headsThemes.titleLarge,
      titleMedium: headsThemes.titleMedium,
      titleSmall: headsThemes.titleSmall,
      bodyLarge: bodysThemes.bodyLarge,
      bodyMedium: bodysThemes.bodyMedium,
      bodySmall: bodysThemes.bodySmall,
      labelLarge: bodysThemes.labelLarge,
      labelMedium: bodysThemes.labelMedium,
      labelSmall: bodysThemes.labelSmall,
    ).apply(
      displayColor: colorScheme.onSurface,
      bodyColor: colorScheme.onSurface,
    );
  }
} 
