/// Pure domain enum representing the available theme mode options.
/// Free from Flutter UI dependencies — no ThemeMode, no IconData, no BuildContext.
enum ThemeModeOption {
  system,
  light,
  dark,
}

/// Pure domain entity representing a theme mode option.
/// Contains only the enum identifier and a semantic label key.
/// UI details (icon, localized title) are resolved in the presentation layer.
class ThemeModeEntity {
  final ThemeModeOption option;

  const ThemeModeEntity({required this.option});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeEntity && other.option == option;

  @override
  int get hashCode => option.hashCode;
}
