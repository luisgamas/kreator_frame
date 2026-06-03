// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

/// Enum representing the currently running wallpaper operation.
enum WallpaperOperation {
  none,
  homeScreen,
  lockScreen,
  bothScreens,
  nativePicker,
  chooser,
}

/// Notifier that centralizes wallpaper operations (apply, native picker, chooser).
///
/// This notifier is the single presentation-layer entry point for any
/// operation that ends up calling [Repository.setWallpaper],
/// [Repository.openNativeWallpaperPicker] or
/// [Repository.openWallpaperChooser].
///
/// It exists to keep the Clean Architecture layering intact: widgets
/// invoke notifier methods, the notifier talks to the repository through
/// DI, and the repository delegates to the datasource. Widgets never
/// touch the repository directly.
class WallpaperOperationsNotifier extends Notifier<WallpaperOperation> {
  @override
  WallpaperOperation build() => WallpaperOperation.none;

  /// Applies the given [wallpaper] to the specified Android location
  /// (home, lock or both).
  ///
  /// Returns `true` if the native side reported success, `false` otherwise.
  /// Errors are swallowed at the datasource level and surface as `false`,
  /// matching the pre-refactor behaviour.
  Future<bool> applyToLocation(
    WallpaperEntity wallpaper,
    int location,
  ) async {
    if (location == 1) {
      state = WallpaperOperation.homeScreen;
    } else if (location == 2) {
      state = WallpaperOperation.lockScreen;
    } else {
      state = WallpaperOperation.bothScreens;
    }
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.setWallpaper(wallpaper.url, location);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = WallpaperOperation.none;
    }
  }

  /// Opens the native Android wallpaper picker for the given [wallpaper].
  ///
  /// Returns `true` if the picker was launched successfully.
  Future<bool> openInNativePicker(WallpaperEntity wallpaper) async {
    state = WallpaperOperation.nativePicker;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openNativeWallpaperPicker(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = WallpaperOperation.none;
    }
  }

  /// Opens the Android system app chooser ("Apply with...") for the given
  /// [wallpaper].
  ///
  /// Returns `true` if the chooser intent was launched successfully.
  Future<bool> openInChooser(WallpaperEntity wallpaper) async {
    state = WallpaperOperation.chooser;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openWallpaperChooser(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = WallpaperOperation.none;
    }
  }
}

/// Provider that exposes the wallpaper operations state.
final wallpaperOperationsProvider =
    NotifierProvider<WallpaperOperationsNotifier, WallpaperOperation>(
  WallpaperOperationsNotifier.new,
);
