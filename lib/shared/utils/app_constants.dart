// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';

/// Application-wide constants and configuration values.
/// Centralized constants for colors, theme options, and other immutable values.
class AppConstants {
  AppConstants._();

  /// List of available accent colors for app theming.
  /// Uses Material Design color palette accents.
  static const List<Color> accentColors = [
    Color(0xFFE53935), // red
    Color(0xFFD81B60), // pink
    Color(0xFF8E24AA), // purple
    Color(0xFF5E35B1), // deep purple
    Color(0xFF3949AB), // indigo
    Color(0xFF1E88E5), // blue
    Color(0xFF039BE5), // light blue
    Color(0xFF00ACC1), // cyan
    Color(0xFF00897B), // teal
    Color(0xFF43A047), // green
    Color(0xFF7CB342), // light green
    Color(0xFFC0CA33), // lime
    Color(0xFFFDD835), // yellow
    Color(0xFFFFB300), // amber
    Color(0xFFFB8C00), // orange
    Color(0xFFF4511E), // deep orange
    Color(0xFF6D4C41), // brown
    Color(0xFF546E7A), // blue grey
    Color(0xFF455A64), // neutral dark
    Color(0xFF607D8B), // neutral light
  ];

  /// List of available theme mode options as pure domain entities.
  static const List<ThemeModeEntity> themeModeOptions = [
    ThemeModeEntity(option: ThemeModeOption.system),
    ThemeModeEntity(option: ThemeModeOption.light),
    ThemeModeEntity(option: ThemeModeOption.dark),
  ];

  /// Maps a [ThemeModeOption] to its Flutter [ThemeMode] equivalent.
  static ThemeMode themeModeFromOption(ThemeModeOption option) {
    return switch (option) {
      ThemeModeOption.system => ThemeMode.system,
      ThemeModeOption.light => ThemeMode.light,
      ThemeModeOption.dark => ThemeMode.dark,
    };
  }

  /// Maps a [ThemeModeOption] to its display icon.
  static IconData iconForThemeMode(ThemeModeOption option) {
    return switch (option) {
      ThemeModeOption.system => Hicon.situation2Outline,
      ThemeModeOption.light => Hicon.sun1Outline,
      ThemeModeOption.dark => Hicon.moonOutline,
    };
  }

  /// Maps a [ThemeModeOption] to its localized title.
  static String Function(BuildContext) titleForThemeMode(ThemeModeOption option) {
    return switch (option) {
      ThemeModeOption.system => (context) => AppLocalizations.of(context)!.themeSystem,
      ThemeModeOption.light => (context) => AppLocalizations.of(context)!.themeLight,
      ThemeModeOption.dark => (context) => AppLocalizations.of(context)!.themeDark,
    };
  }
}
