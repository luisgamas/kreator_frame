// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages wallpaper download progress.
/// Allows updating progress from 0.0 to 1.0 during a download.
///
/// State values:
/// - `null`: idle (no download active)
/// - `-1.0`: indeterminate progress (Content-Length unknown)
/// - `0.0` to `1.0`: determinate progress
class ProgressDownloaderNotifier extends Notifier<double?> {
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
}

/// Provider that exposes the wallpaper download progress state.
final progressDownloaderProvider =
    NotifierProvider<ProgressDownloaderNotifier, double?>(
  ProgressDownloaderNotifier.new,
);
