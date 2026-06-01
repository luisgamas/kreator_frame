// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

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
///
/// The state is a single `bool` representing "any wallpaper operation in
/// progress" so the three location buttons and the apply/chooser/native
/// buttons in the preview bottom sheet can share loading state and stay
/// disabled while one of them is running.
class WallpaperOperationsNotifier extends Notifier<bool> {
  @override
  bool build() => false;

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
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.setWallpaper(wallpaper.url, location);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Opens the native Android wallpaper picker for the given [wallpaper].
  ///
  /// Returns `true` if the picker was launched successfully.
  Future<bool> openInNativePicker(WallpaperEntity wallpaper) async {
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openNativeWallpaperPicker(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Opens the Android system app chooser ("Apply with...") for the given
  /// [wallpaper].
  ///
  /// Returns `true` if the chooser intent was launched successfully.
  Future<bool> openInChooser(WallpaperEntity wallpaper) async {
    state = true;
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.openWallpaperChooser(wallpaper.url);
      if (!ref.mounted) return result;
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

/// Provider that exposes the wallpaper operations state.
///
/// The boolean state represents "any wallpaper operation in progress" and is
/// shared by all the buttons in the preview bottom sheet so that the whole
/// sheet stays disabled while one operation runs.
final wallpaperOperationsProvider =
    NotifierProvider<WallpaperOperationsNotifier, bool>(
  WallpaperOperationsNotifier.new,
);
