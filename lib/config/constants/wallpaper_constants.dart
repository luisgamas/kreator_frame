/// Android wallpaper screen location flags.
///
/// These constants mirror the Android `WallpaperManager` flags:
/// - `FLAG_SYSTEM` (home screen) = 1
/// - `FLAG_LOCK` (lock screen) = 2
/// - `FLAG_SYSTEM | FLAG_LOCK` (both screens) = 3
class WallpaperConstants {
  WallpaperConstants._();

  static const int wallpaperHomeScreen = 1;
  static const int wallpaperLockScreen = 2;
  static const int wallpaperBothScreens = 3;
}
