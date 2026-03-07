// 📦 Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration and constants for the application.
///
/// Contains three types of configuration:
/// 1. User-configurable values from .env file (developer name, URLs, social media)
/// 2. SharedPreference keys for persistent storage
/// 3. Static application constants (name, version, asset paths, external links)
///
/// WARNING: Variables marked with "DO NOT REMOVE" are critical for app functionality.
class Environment {
  // * Declaration of static environment variables for non-instance access of the class **DO NOT REMOVE**
  static String userDeveloperName = dotenv.env['DEVELOPER_NAME'] ?? 'Error DEVELOPER_NAME';
  static String userWallpapersUrl = dotenv.env['WALLPAPERS_URL'] ?? 'Error WALLPAPERS_URL';
  static String userTwitterUrl = dotenv.env['TWITTER'] ?? 'Error TWITTER';
  static String userInstagramUrl = dotenv.env['INSTAGRAM'] ?? 'Error INSTAGRAM';
  static String userPlayStoreUrl = dotenv.env['GOOGLE_PLAY_STORE'] ?? 'Error GOOGLE_PLAY_STORE';

  // * Variables of SharedPreference **DO NOT REMOVE**
  static const String keyThemeMode = 'ThemeMode';
  static const String keyColorTheme = 'ColorTheme';
  // static const keyMinimalGrid = 'MinimalGridKey';

  // * Variables of Dashboard Preference **DO NOT REMOVE**
  static const String dashName = 'Kreator Frame';
  static const String dashVersion = '1.5.2';
  static const String dashDeveloper = 'Luis Gamas';

  // * Variables for assets **DO NOT REMOVE**
  static const String iconPackageLogo = 'assets/logo/app_logo.png';
  static const String iconDashboardLogo = 'assets/dashboard/dashboard_icon.png';

  // * Wallpaper screen location constants **DO NOT REMOVE**
  static const int wallpaperHomeScreen = 1;   // Equivalent to WallpaperManager.FLAG_SYSTEM
  static const int wallpaperLockScreen = 2;   // Equivalent to WallpaperManager.FLAG_LOCK
  static const int wallpaperBothScreens = 3;  // FLAG_SYSTEM | FLAG_LOCK

  // * Variables for external links **DO NOT REMOVE**
  static const String externalLinkTwitter = 'https://sink.gamas.workers.dev/gamas-x';
  static const String externalLinkInstagram = 'https://sink.gamas.workers.dev/gamas-instagram';
  static const String externalLinkWebsite = 'https://sink.gamas.workers.dev/gamas-website';
  static const String externalLinkPrivacyPolicy = 'https://sink.gamas.workers.dev/gamas-privpol';
  static const String externalLinkTermsAndConditions = 'https://sink.gamas.workers.dev/gamas-termcond';
  static const String externalLinkBuyMeACoffe = 'https://buymeacoffee.com/luisgamas';
  static const String externalLinkKLWP = 'https://play.google.com/store/apps/details?id=org.kustom.wallpaper';
  static const String externalLinkKWGT = 'https://play.google.com/store/apps/details?id=org.kustom.widget';
}
