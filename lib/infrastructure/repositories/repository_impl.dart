// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';

/// Implementation of the Repository interface.
///
/// This class acts as a pass-through to the DataSource, following Clean Architecture
/// principles where the repository sits between the domain and data layers. While
/// currently a simple delegation, this structure allows for:
/// - Future aggregation of multiple data sources
/// - Addition of caching logic
/// - Domain-specific data transformations
/// - Business rule enforcement
///
/// The repository receives the DataSource through dependency injection via providers.
class RepositoryImpl extends Repository {
  final DataSource dataSource;

  RepositoryImpl(this.dataSource);

  @override
  Future<AppInfoEntity> getAppInformation() {
    return dataSource.getAppInformation();
  }

  @override
  Future<InAppUpdateEntity> checkAppForUpdates() {
    return dataSource.checkAppForUpdates();
  }

  @override
  Future<InAppUpdateEntity> executeImmediateAppUpdate() {
    return dataSource.executeImmediateAppUpdate();
  }

  @override
  Future<bool> setWallpaper(String url, int location) {
    return dataSource.setWallpaper(url, location);
  }

  @override
  Future<bool> openNativeWallpaperPicker(String url) {
    return dataSource.openNativeWallpaperPicker(url);
  }

  @override
  Future<bool> openWallpaperChooser(String url) {
    return dataSource.openWallpaperChooser(url);
  }

  @override
  Future<List<WallpaperEntity>> getListOfWallpapers() {
    return dataSource.getListOfWallpapers();
  }
  
  @override
  Future<List<WidgetEntity>> getListOfWidgets(String filesExt, String thumbName) {
    return dataSource.getListOfWidgets(filesExt, thumbName);
  }

  @override
  Future<void> launchExternalApp(String url) {
    return dataSource.launchExternalApp(url);
  }
  
  @override
  Future<List<LicenseEntity>> getLicenses() {
    return dataSource.getLicenses();
  }

  @override
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double?)? onProgressUpdate,
  }) {
    return dataSource.downloadWallpaper(
      url,
      fileName,
      onProgressUpdate: onProgressUpdate,
    );
  }

  @override
  void cancelDownloadWallpaper() {
    dataSource.cancelDownloadWallpaper();
  }

  @override
  Future<bool> isKustomAppInstalled(String packageName) {
    return dataSource.isKustomAppInstalled(packageName);
  }

  @override
  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  }) {
    return dataSource.sendWidgetToKustomApp(
      packageName: packageName,
      editorActivity: editorActivity,
      assetPath: assetPath,
    );
  }
}
