// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';

/// Abstract repository interface for the domain layer.
///
/// This interface mirrors the DataSource interface but exists in the domain layer
/// to follow Clean Architecture principles. The repository abstracts the data layer
/// and can potentially aggregate data from multiple sources or add domain-specific
/// business logic.
///
/// In this application, the repository acts as a pass-through to the data source,
/// but this separation allows for future enhancements without affecting the domain layer.
abstract class Repository {
  /// Retrieves application information (version, build number, app name).
  Future<AppInfoEntity> getAppInformation();

  /// Checks if there are updates available for the application.
  Future<String> checkAppForUpdates();

  /// Executes an immediate in-app update.
  Future<String> executeImmediateAppUpdate();

  /// Sets a wallpaper from a URL to the device.
  Future<bool> setWallpaper(String url, int location);

  /// Opens the native Android wallpaper picker for the given image URL.
  Future<bool> openNativeWallpaperPicker(String url);

  /// Opens the Android system app chooser ("Apply with...") for the given image URL.
  Future<bool> openWallpaperChooser(String url);

  /// Retrieves the list of available wallpapers.
  Future<List<WallpaperEntity>> getListOfWallpapers();

  /// Retrieves the list of widgets filtered by type.
  Future<List<WidgetEntity>> getListOfWidgets(String filesExt, String thumbName);

  /// Launches an external application or URL.
  Future<void> launchExternalApp(String url);

  /// Retrieves the list of open-source licenses.
  Future<List<LicenseEntity>> getLicenses();

  /// Downloads a wallpaper to the device gallery.
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double?)? onProgressUpdate,
  });

  /// Cancels the currently active wallpaper download if one is in progress.
  void cancelDownloadWallpaper();
}
