// 📦 Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// * State
/// State that holds permission statuses for the application.
///
/// Manages storage permission state with special handling for Android versions:
/// - Android 10+ (API 29+): No permissions needed (Scoped Storage/MediaStore)
/// - Android 9 and earlier: Requires WRITE_EXTERNAL_STORAGE permission
class PermissionsState {
  final PermissionStatus storage;

  PermissionsState({
    this.storage = PermissionStatus.denied,
  });

  PermissionsState copyWith({
    PermissionStatus? storage,
  }) => PermissionsState(
    storage: storage ?? this.storage,
  );

  /// Returns true if storage permission is granted.
  /// For Android 10+ (API 29+), always returns true because no permissions
  /// are needed to save files using MediaStore/Scoped Storage.
  /// For Android 9 and earlier, checks WRITE_EXTERNAL_STORAGE permission.
  bool get storageGranted {
    return storage == PermissionStatus.granted;
  }
}

// * Notifier State
/// Notifier that manages permission requests and status checks.
///
/// Loads permission states on creation and provides methods to request
/// permissions when needed. Adapts behavior based on Android version.
class PermissionsNotifier extends AsyncNotifier<PermissionsState> {
  int _androidSdkVersion = 25;

  @override
  Future<PermissionsState> build() async {
    await _getAndroidVersion();
    return _checkPermissions();
  }

  Future<void> _getAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _androidSdkVersion = androidInfo.version.sdkInt;
  }

  /// Checks necessary permissions based on Android version.
  /// - Android 10+ (API 29+): No permissions needed to write to MediaStore
  /// - Android 9 and earlier (API ≤28): Requires WRITE_EXTERNAL_STORAGE
  Future<PermissionsState> _checkPermissions() async {
    final storageStatus = await _determineStoragePermission();
    return PermissionsState(storage: storageStatus);
  }

  /// Determines storage permission status based on Android version.
  /// For Android 10+ automatically returns granted because no permissions are needed.
  Future<PermissionStatus> _determineStoragePermission() async {
    // Android 10+ (API 29+) uses Scoped Storage and doesn't need permissions to write
    if (_androidSdkVersion >= 29) {
      return PermissionStatus.granted;
    }

    // Android 9 and earlier need WRITE_EXTERNAL_STORAGE
    return Permission.storage.status;
  }

  /// Requests storage permission only if necessary (Android ≤28).
  /// For Android 10+, does nothing because no permissions are needed.
  Future<void> requestStoragePermission() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Do not request storage permission on Android 10+
    if (_androidSdkVersion >= 29) {
      state = AsyncData(currentState.copyWith(storage: PermissionStatus.granted));
      return;
    }

    // Android 9 and earlier: request WRITE_EXTERNAL_STORAGE
    final storageStatus = await Permission.storage.request();
    if (!ref.mounted) return;
    state = AsyncData(currentState.copyWith(storage: storageStatus));

    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }
}

// * Provider
/// Provider that exposes permission states and management functionality.
final permissionsProvider = AsyncNotifierProvider<PermissionsNotifier, PermissionsState>(
  PermissionsNotifier.new,
);
