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
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/infrastructure/infrastructure.dart';

/// Implementation of the DataSource contract.
/// Handles all data access operations including app info, updates, wallpapers, widgets, and licenses.
/// Acts as the single point of contact for all data-related operations.
class DataSourceImpl extends DataSource {
  final InAppUpdateManager _inAppUpdateManager = InAppUpdateManager();
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static const _channel = MethodChannel('kreator_frame/wallpaper');

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
  /// Returns possible values: 'recovered', 'updateAvailable', 'notAvailable', 'error'
  @override
  Future<String> checkAppForUpdates() async {
    try {
      final appUpdateInfo = await _inAppUpdateManager.checkForUpdate();

      if (appUpdateInfo == null) return 'notAvailable';

      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await _inAppUpdateManager.startAnUpdate(type: AppUpdateType.immediate);
        return 'recovered';
      }

      return 'updateAvailable';
    } catch (e) {
      return 'error';
    }
  }

  /// Executes an immediate app update.
  /// Returns possible values: 'upToDate', 'error'
  @override
  Future<String> executeImmediateAppUpdate() async {
    try {
      await _inAppUpdateManager.startAnUpdate(type: AppUpdateType.immediate);
      return 'upToDate';
    } catch (e) {
      return 'error';
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
      final result = await _channel.invokeMethod<bool>('setWallpaper', {
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
      final result = await _channel.invokeMethod<bool>('openNativeWallpaperPicker', {
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
      final result = await _channel.invokeMethod<bool>('openWallpaperChooser', {
        'url': url,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the list of available wallpapers from the remote API.
  /// Maps the response to WallpaperEntity objects.
  @override
  Future<List<WallpaperEntity>> getListOfWallpapers() async {
    try {
      final response = await dio.get(Environment.userWallpapersUrl);
      final wallpaperModel = WallpaperModel.fromJson(response.data);

      final List<WallpaperEntity> wallpapersEntities = wallpaperModel.wallpapers
          .map((wallpaper) => WallpaperMapper.wallpapersToEntity(wallpaper))
          .toList();

      return wallpapersEntities;
    } catch (e) {
      return [];
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
  /// - [onProgressUpdate]: Optional callback to track download progress (0.0 to 1.0)
  ///
  /// Returns [true] if the download and saving were successful, [false] in case of error.
  @override
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double)? onProgressUpdate,
  }) async {
    try {
      // Download the image using Dio with progress tracking
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgressUpdate != null) {
            // Calculate progress as percentage (0.0 to 1.0)
            final progress = received / total;
            onProgressUpdate(progress);
          }
        },
      );

      // Save the image to the gallery using MediaStore (Scoped Storage)
      // image_gallery_saver_plus uses MediaStore on Android 10+ without needing permissions
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: fileName,
      );

      // Verify if saving was successful
      // result can return a Map with 'isSuccess' or directly a String with the path
      if (result is Map && result['isSuccess'] == true) {
        onProgressUpdate?.call(0);
        return true;
      } else if (result is String && result.isNotEmpty) {
        onProgressUpdate?.call(0);
        return true;
      }

      onProgressUpdate?.call(0);
      return false;
    } catch (e) {
      onProgressUpdate?.call(0);
      return false;
    }
  }

  // ============================================================
  // Widget Operations
  // ============================================================

  /// Retrieves the list of widgets (KWGT or KLWP) from the assets folder.
  /// Loads zip files, extracts thumbnails, and creates WidgetEntity objects.
  /// [filesExt] can be 'kwgt' or 'klwp'
  /// [thumbName] is the thumbnail filename within the zip
  @override
  Future<List<WidgetEntity>> getListOfWidgets(
      String filesExt, String thumbName) async {
    List<WidgetEntity> widgets = [];
    String folderAsset = '';

    // Get list of .zip files in the assets folder
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

      // Decode the .zip file
      Archive archive = ZipDecoder().decodeBytes(bytes);

      // Get preview image if it exists in the .zip file
      ArchiveFile? thumbFile =
          archive.firstWhere((file) => file.name == thumbName);

      widgets.add(WidgetEntity(
        nameWidget: zipFileName.replaceAll('.$filesExt', ''),
        nameDeveloper: Environment.userDeveloperName,
        widgetThumbnail: thumbFile.content,
      ));
    }

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
    // Load the asset manifest
    final AssetManifest assetManifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    // List all assets
    final List<String> assetList = assetManifest.listAssets();

    // Filter .zip files in the assets folder
    List<String> zipFiles =
        assetList.where((asset) => asset.endsWith('.$filesExt')).toList();
    // Remove path prefix and file extension
    zipFiles = zipFiles.map((zip) => zip.split('/').last).toList();
    return zipFiles;
  }

}
