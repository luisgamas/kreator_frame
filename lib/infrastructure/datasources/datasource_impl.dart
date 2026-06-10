// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/config/constants/env_vars.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/infrastructure/infrastructure.dart';
import 'package:kreator_frame/shared/services/services.dart';

/// Implementation of the DataSource contract.
/// Handles all data access operations including app info, updates, wallpapers, widgets, and licenses.
/// Acts as the single point of contact for all data-related operations.
class DataSourceImpl extends DataSource {
  final Dio _dio;
  final DownloadCancelTokenHolder _downloadCancelTokenHolder;
  final InAppUpdateManager _inAppUpdateManager;

  DataSourceImpl({
    required this._dio,
    required this._downloadCancelTokenHolder,
    required this._inAppUpdateManager,
  });

  static const _wallpaperChannel = MethodChannel('kreator_frame/wallpaper');
  static const _kustomChannel = MethodChannel('kreator_frame/kustom');

  // ============================================================
  // App Information
  // ============================================================

  /// Retrieves the application information (name, version, build number).
  /// Returns default error values if retrieval fails.
  @override
  Future<AppInfoEntity> getAppInformation() async {
    try {
      final appInfo = await PackageManager.getPackageInfo();
      return AppInfoEntity(
        appName: appInfo.appName,
        packageName: appInfo.packageName,
        packageVersion: appInfo.version,
        buildNumber: appInfo.buildNumber,
      );
    } catch (e) {
      return const AppInfoEntity(
        appName: 'Error appName',
        packageName: 'Error packageName',
        packageVersion: 'Error version',
        buildNumber: 'Error buildNumber',
      );
    }
  }

  // ============================================================
  // In-App Updates
  // ============================================================

  /// Checks if an update is available for the application.
  /// Returns a typed entity instead of a raw string.
  @override
  Future<InAppUpdateEntity> checkAppForUpdates() async {
    try {
      final appUpdateInfo = await _inAppUpdateManager.checkForUpdate();

      if (appUpdateInfo == null) {
        return const InAppUpdateEntity(
          availability: InAppUpdateAvailability.notAvailable,
        );
      }

      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await _inAppUpdateManager.startAnUpdate(type: AppUpdateType.immediate);
        return const InAppUpdateEntity(
          availability: InAppUpdateAvailability.inProgress,
        );
      }

      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        return const InAppUpdateEntity(
          availability: InAppUpdateAvailability.available,
        );
      }

      return const InAppUpdateEntity(
        availability: InAppUpdateAvailability.notAvailable,
      );
    } catch (e) {
      debugPrint('checkAppForUpdates error: $e');
      return InAppUpdateEntity(
        availability: InAppUpdateAvailability.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Executes an immediate app update.
  /// Returns a typed entity instead of a raw string.
  @override
  Future<InAppUpdateEntity> executeImmediateAppUpdate() async {
    try {
      await _inAppUpdateManager.startAnUpdate(type: AppUpdateType.immediate);
      return const InAppUpdateEntity(
        availability: InAppUpdateAvailability.unknown,
      );
    } catch (e) {
      debugPrint('executeImmediateAppUpdate error: $e');
      return InAppUpdateEntity(
        availability: InAppUpdateAvailability.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // Wallpaper Operations
  // ============================================================

  /// Sets a wallpaper on the device (home screen, lock screen, or both).
  /// Delegates to native Android via MethodChannel for background processing.
  /// Returns true if successful, false otherwise.
  @override
  Future<bool> setWallpaper(String url, int location) async {
    try {
      final result = await _wallpaperChannel.invokeMethod<bool>('setWallpaper', {
        'url': url,
        'location': location,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Opens the native Android wallpaper picker by launching a system intent.
  /// Downloads the image to a temp cache file and delegates the rest to the OS.
  /// Returns true if the intent was launched successfully, false otherwise.
  @override
  Future<bool> openNativeWallpaperPicker(String url) async {
    try {
      final result = await _wallpaperChannel.invokeMethod<bool>('openNativeWallpaperPicker', {
        'url': url,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Opens the Android system app chooser (ACTION_ATTACH_DATA) for the given image URL.
  /// Android displays all apps that can handle the image (e.g. Google Photos, Gallery).
  /// Returns true if the chooser intent was launched successfully, false otherwise.
  @override
  Future<bool> openWallpaperChooser(String url) async {
    try {
      final result = await _wallpaperChannel.invokeMethod<bool>('openWallpaperChooser', {
        'url': url,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the list of available wallpapers from the remote API.
  /// Maps the response to WallpaperEntity objects.
  /// Returns an empty list on any error to allow graceful UI fallback.
  @override
  Future<List<WallpaperEntity>> getListOfWallpapers() async {
    try {
      final response = await _dio.get(EnvVars.userWallpapersUrl);
      final wallpaperModel = WallpaperModel.fromJson(response.data as Map<String, dynamic>);

      final List<WallpaperEntity> wallpapersEntities = wallpaperModel.wallpapers
          .map((wallpaper) => WallpaperMapper.wallpapersToEntity(wallpaper))
          .toList();

      return wallpapersEntities;
    } on DioException catch (e) {
      debugPrint('DioException fetching wallpapers: ${e.type} - ${e.message}');
      return [];
    } on TypeError catch (e) {
      debugPrint('JSON parsing error for wallpapers: $e');
      return [];
    } catch (e) {
      debugPrint('Unexpected error fetching wallpapers: $e');
      return [];
    }
  }

  /// Cancels the current wallpaper download if one is in progress.
  ///
  /// Delegates to [DownloadCancelTokenHolder] so the token outlives this
  /// datasource instance (e.g. when `dataSourceProvider` is rebuilt because
  /// one of its watched providers changes). The holder is provided through
  /// dependency injection via [dataSourceProvider].
  @override
  void cancelDownloadWallpaper() {
    _downloadCancelTokenHolder.cancel();
  }

  // ============================================================
  // Kustom App Integration
  // ============================================================

  @override
  Future<bool> isKustomAppInstalled(String packageName) async {
    try {
      final result = await _kustomChannel.invokeMethod<bool>('isKustomAppInstalled', {
        'packageName': packageName,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  }) async {
    try {
      final result = await _kustomChannel.invokeMethod<bool>('sendWidgetToKustomApp', {
        'packageName': packageName,
        'editorActivity': editorActivity,
        'assetPath': assetPath,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Download a wallpaper from a URL and save it to the device gallery.
  ///
  /// This method uses the MediaStore API (Scoped Storage), which works without permissions
  /// on Android 10+ (API 29+). It only requires WRITE_EXTERNAL_STORAGE for Android 9
  /// and earlier versions.
  ///
  /// The file is saved in the Pictures folder of the device's shared storage
  /// with the specified name.
  ///
  /// Parameters:
  /// - [url]: URL of the wallpaper to download
  /// - [fileName]: Name of the file to save (without extension)
  /// - [onProgressUpdate]: Optional callback to track download progress (0.0 to 1.0).
  ///   If the server does not send Content-Length, the callback will receive null,
  ///   indicating indeterminate progress.
  ///
  /// Returns [true] if the download and saving were successful, [false] in case of error.
  @override
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double?)? onProgressUpdate,
  }) async {
    final cancelToken = _downloadCancelTokenHolder.register();

    try {
      final response = await _dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (onProgressUpdate == null) return;
          if (total != -1) {
            onProgressUpdate(received / total);
          } else {
            // Content-Length unknown — signal indeterminate progress
            onProgressUpdate(null);
          }
        },
      );

      _downloadCancelTokenHolder.clear();

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data as List<int>),
        quality: 100,
        name: fileName,
      );

      onProgressUpdate?.call(0);

      if (result is Map && result['isSuccess'] == true) {
        return true;
      } else if (result is String && result.isNotEmpty) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      _downloadCancelTokenHolder.clear();
      onProgressUpdate?.call(0);

      if (e.type == DioExceptionType.cancel) {
        debugPrint('Download cancelled: ${e.message}');
        return false;
      } else {
        debugPrint('DioException downloading wallpaper: ${e.type} - ${e.message}');
        return false;
      }
    } catch (e) {
      _downloadCancelTokenHolder.clear();
      onProgressUpdate?.call(0);
      debugPrint('Unexpected error downloading wallpaper: $e');
      return false;
    }
  }

  // ============================================================
  // Widget Operations
  // ============================================================

  /// Cache for loaded widgets to avoid repeated asset loading and zip decoding.
  final Map<String, List<WidgetEntity>> _widgetCache = {};

  /// Retrieves the list of widgets (KWGT or KLWP) from the assets folder.
  /// Loads zip files, extracts thumbnails, and creates WidgetEntity objects.
  /// Results are cached to avoid repeated expensive asset loading.
  /// [filesExt] can be 'kwgt' or 'klwp'
  /// [thumbName] is the thumbnail filename within the zip
  @override
  Future<List<WidgetEntity>> getListOfWidgets(
      String filesExt, String thumbName) async {
    // Return cached result if available
    if (_widgetCache.containsKey(filesExt)) {
      return _widgetCache[filesExt]!;
    }

    List<WidgetEntity> widgets = [];
    String folderAsset = '';

    List<String> zipFiles = await _listZipFiles(filesExt);

    if (filesExt == 'kwgt') {
      folderAsset = 'widgets';
    } else if (filesExt == 'klwp') {
      folderAsset = 'wallpapers';
    }

    for (String zipFileName in zipFiles) {
      ByteData data = await rootBundle
          .load('android/app/src/main/assets/$folderAsset/$zipFileName');
      List<int> bytes = data.buffer.asUint8List();

      Archive archive = ZipDecoder().decodeBytes(bytes);
      try {
        // Find thumbnail file, skip if not found
        ArchiveFile? thumbFile;
        for (final file in archive) {
          if (file.name == thumbName) {
            thumbFile = file;
            break;
          }
        }

        if (thumbFile == null) continue;

        widgets.add(WidgetEntity(
          nameWidget: zipFileName.replaceAll('.$filesExt', ''),
          nameDeveloper: EnvVars.userDeveloperName,
          widgetThumbnail: Uint8List.fromList(thumbFile.content as List<int>),
          assetPath: '$folderAsset/$zipFileName',
        ));
      } finally {
        // Archive doesn't have an explicit dispose, but we clear the reference
        // to help GC collect the decoded data
        archive.clear();
      }
    }

    // Cache the result
    _widgetCache[filesExt] = widgets;
    return widgets;
  }

  // ============================================================
  // External Navigation
  // ============================================================

  /// Launches an external app/URL using the system URL launcher.
  /// Throws an exception if the URL cannot be launched.
  @override
  Future<void> launchExternalApp(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
    )) {
      throw Exception('Could not launch your url');
    }
  }

  // ============================================================
  // Licenses
  // ============================================================

  /// Retrieves a list of open source licenses from the project.
  /// Consolidates licenses by package name and sorts alphabetically.
  /// Returns an empty list if retrieval fails.
  @override
  Future<List<LicenseEntity>> getLicenses() async {
    try {
      final licenses = await LicenseRegistry.licenses.toList();
      final Map<String, List<String>> consolidatedLicenses = {};

      for (var license in licenses) {
        for (var packageName in license.packages) {
          final licenseContent =
              license.paragraphs.map((e) => e.text).join('\n\n');

          if (consolidatedLicenses.containsKey(packageName)) {
            consolidatedLicenses[packageName]?.add(licenseContent);
          } else {
            consolidatedLicenses[packageName] = [licenseContent];
          }
        }
      }

      final licenseEntities = consolidatedLicenses.entries
          .map((entry) => LicenseMapper.dataToEntity(
                packageName: entry.key,
                licenses: entry.value,
              ))
          .toList();

      licenseEntities.sort((a, b) => a.name.compareTo(b.name));
      return licenseEntities;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  /// Lists all .zip files in the assets folder with the specified extension.
  /// Filters by [filesExt] and returns only the filenames without paths.
  Future<List<String>> _listZipFiles(String filesExt) async {
    final AssetManifest assetManifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    final List<String> assetList = assetManifest.listAssets();

    List<String> zipFiles =
        assetList.where((asset) => asset.endsWith('.$filesExt')).toList();
    zipFiles = zipFiles.map((zip) => zip.split('/').last).toList();
    return zipFiles;
  }
}
