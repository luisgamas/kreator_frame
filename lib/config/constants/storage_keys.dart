/// Keys used for persistent storage via SharedPreferences.
///
/// These keys must remain stable across app versions to avoid
/// losing user preferences on update.
class StorageKeys {
  StorageKeys._();

  static const String keyThemeMode = 'ThemeMode';
  static const String keyColorTheme = 'ColorTheme';
  // static const String keyMinimalGrid = 'MinimalGridKey';
}
