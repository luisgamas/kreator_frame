// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

/// Notifier that manages wallpaper download progress and the download /
/// cancel operations that drive it.
///
/// This notifier is the single presentation-layer entry point for
/// `Repository.downloadWallpaper` and `Repository.cancelDownloadWallpaper`.
/// It centralises the progress-callback wiring that used to live in the
/// `WallpaperDownloadButton` widget, so widgets only talk to the
/// notifier and the notifier talks to the repository through DI.
///
/// State values:
/// - `null`: idle (no download active)
/// - `-1.0`: indeterminate progress (Content-Length unknown)
/// - `0.0` to `1.0`: determinate progress
class DownloadOperationsNotifier extends Notifier<double?> {
  @override
  double? build() => null;

  /// Updates the current download progress.
  ///
  /// [progress] values:
  /// - `null`: reset to idle state
  /// - `-1.0`: set indeterminate state (unknown Content-Length)
  /// - `0.0` to `1.0`: set determinate progress
  void changeProgress(double? progress) {
    state = progress;
  }

  /// Whether the download has started.
  bool get isDownloading => state != null;

  /// Whether the progress is indeterminate (Content-Length unknown).
  bool get isIndeterminate => state != null && state! < 0;

  /// Downloads the given [wallpaper] through the repository and reflects
  /// progress into [state].
  ///
  /// The method always clears the progress on completion (success or
  /// failure) so the UI returns to the idle state.
  Future<bool> download(WallpaperEntity wallpaper) async {
    final repository = ref.read(repositoryProvider);
    changeProgress(-1.0);

    try {
      final success = await repository.downloadWallpaper(
        wallpaper.url.trim(),
        wallpaper.name,
        onProgressUpdate: (progress) {
          if (progress == null) {
            if (!isIndeterminate) {
              changeProgress(-1.0);
            }
          } else {
            changeProgress(progress);
          }
        },
      );
      changeProgress(null);
      return success;
    } catch (_) {
      changeProgress(null);
      return false;
    }
  }

  /// Cancels the in-flight download through the repository and resets the
  /// progress to idle.
  void cancel() {
    final repository = ref.read(repositoryProvider);
    repository.cancelDownloadWallpaper();
    changeProgress(null);
  }
}

/// Provider that exposes the wallpaper download progress state and the
/// download / cancel operations.
final downloadOperationsProvider =
    NotifierProvider<DownloadOperationsNotifier, double?>(
  DownloadOperationsNotifier.new,
);
