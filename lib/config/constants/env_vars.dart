// 📦 Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables loaded from the `.env` file.
///
/// These values are user-configurable and vary across deployments
/// (developer name, social media URLs, wallpapers source URL).
class EnvVars {
  EnvVars._();

  static String userDeveloperName = dotenv.env['DEVELOPER_NAME'] ?? 'Error DEVELOPER_NAME';
  static String userWallpapersUrl = dotenv.env['WALLPAPERS_URL'] ?? 'Error WALLPAPERS_URL';
  static String userTwitterUrl = dotenv.env['TWITTER'] ?? 'Error TWITTER';
  static String userInstagramUrl = dotenv.env['INSTAGRAM'] ?? 'Error INSTAGRAM';
  static String userPlayStoreUrl = dotenv.env['GOOGLE_PLAY_STORE'] ?? 'Error GOOGLE_PLAY_STORE';
}
