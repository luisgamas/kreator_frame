// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';

/// Abstract data source interface defining all data operations.
///
/// This interface defines the contract for data access operations in the application.
/// Implementations should handle all external data sources (network, local storage, etc.).
/// Following Clean Architecture principles, this abstraction allows the domain layer
/// to remain independent of implementation details.
abstract class DataSource {
  /// Retrieves application information (version, build number, app name).
  Future<AppInfoEntity> getAppInformation();

  /// Checks if there are updates available for the application.
  /// Returns a string indicating update status.
  Future<String> checkAppForUpdates();

  /// Executes an immediate in-app update.
  /// Returns a string indicating the update result.
  Future<String> executeImmediateAppUpdate();

  /// Sets a wallpaper from a URL to the device.
  /// [location] indicates where to apply (home screen, lock screen, both).
  Future<bool> setWallpaper(String url, int location);

  /// Opens the native Android wallpaper picker for the given image URL.
  /// The system UI handles cropping and the choice of home/lock/both.
  Future<bool> openNativeWallpaperPicker(String url);

  /// Opens the Android system app chooser ("Apply with...") for the given image URL.
  /// Shows all installed apps that can handle ACTION_ATTACH_DATA for images.
  Future<bool> openWallpaperChooser(String url);

  /// Retrieves the list of available wallpapers.
  Future<List<WallpaperEntity>> getListOfWallpapers();

  /// Retrieves the list of widgets filtered by file extension.
  /// [filesExt] can be 'kwgt' or 'klwp'.
  /// [thumbName] is the thumbnail filename to extract from widget packages.
  Future<List<WidgetEntity>> getListOfWidgets(String filesExt, String thumbName);

  /// Launches an external application or URL.
  Future<void> launchExternalApp(String url);

  /// Retrieves the list of open-source licenses used in the app.
  Future<List<LicenseEntity>> getLicenses();

  /// Download a wallpaper from a URL and save it to the device gallery.
  ///
  /// Uses MediaStore API (Scoped Storage) on Android 10+ without requiring permissions.
  /// Only requires WRITE_EXTERNAL_STORAGE for Android 9 and earlier versions.
  ///
  /// Parameters:
  /// - [url]: URL of the wallpaper to download
  /// - [fileName]: Name of the file to save (without extension)
  /// - [onProgressUpdate]: Optional callback to track download progress (0.0 to 1.0).
  ///   Receives null when Content-Length is unknown (indeterminate progress).
  ///
  /// Returns [true] if the download was successful, [false] otherwise
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double?)? onProgressUpdate,
  });

  /// Cancels the currently active wallpaper download if one is in progress.
  /// Safe to call when no download is active.
  void cancelDownloadWallpaper();

  /// Checks if a Kustom app (KWGT, KLWP, etc.) is installed on the device.
  Future<bool> isKustomAppInstalled(String packageName);

  /// Sends a widget/preset to the corresponding Kustom app via an Android Intent.
  /// Uses the kfile:// URI scheme to trigger direct import into the Kustom editor.
  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  });
}
