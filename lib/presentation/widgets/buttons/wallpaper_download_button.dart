// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

/// A specialized download button for wallpapers with progress tracking and cancel support.
///
/// This widget provides a complete download experience with:
/// - Loading state with spinning progress indicator
/// - Download progress with percentage display (0-100%)
/// - Indeterminate progress when Content-Length is unknown
/// - Cancel button to abort an active download
/// - Permission handling (requests storage permission if needed)
/// - Error handling with snackbar feedback
/// - Success confirmation
///
/// State management is handled entirely through providers:
/// - `downloadOperationsProvider`: Tracks download progress and exposes the
///   `download` / `cancel` operations that talk to the repository.
/// - `permissionsProvider`: Manages storage permission state.
///
/// The widget uses MediaStore API for proper scoped storage support on Android 10+.
class WallpaperDownloadButton extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;
  final Color? iconColor;

  const WallpaperDownloadButton({
    super.key,
    required this.wallpaperEntity,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionsProvider);
    final progressValue = ref.watch(downloadOperationsProvider);
    final colors = Theme.of(context).colorScheme;

    // Show progress indicator with cancel when a download is active
    if (progressValue != null) {
      return _buildDownloadingState(context, ref, progressValue, colors);
    }

    final permissions = permissionsAsync.value;
    final storageGranted = permissions?.storageGranted ?? false;

    return CustomIconButton(
      onPressed: () => storageGranted
          ? _downloadWallpaper(context, ref, colors)
          : ref.read(permissionsProvider.notifier).requestStoragePermission(),
      icon: Hicon.downloadOutline,
      iconColor: iconColor ?? Colors.white,
      isLoading: false,
    );
  }

  /// Builds the downloading state: determinate progress ring or indeterminate spinner.
  /// Tapping the progress cancels the download.
  Widget _buildDownloadingState(
    BuildContext context,
    WidgetRef ref,
    double progressValue,
    ColorScheme colors,
  ) {
    final isIndeterminate = progressValue < 0;

    return Tooltip(
      message: 'Cancel',
      child: GestureDetector(
        onTap: () => _cancelDownload(context, ref, colors),
        child: SizedBox(
          height: 48,
          width: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isIndeterminate)
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2.5,
                  ),
                )
              else ...[
                SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2.5,
                  ),
                ),
                Text(
                  '${(progressValue * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              // Cancel icon overlay in top-right
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: iconColor?.withValues(alpha: 0.7) ?? Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cancels the active wallpaper download through the operations notifier.
  void _cancelDownload(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
  ) {
    ref.read(downloadOperationsProvider.notifier).cancel();
    SnackbarHelpers.showSuccess(
      context: context,
      message: 'Download cancelled',
      color: colors,
    );
  }

  /// Downloads the wallpaper through the operations notifier.
  ///
  /// This method does not require permissions on Android 10+ (API 29+) because
  /// the underlying datasource uses MediaStore to save the image directly to
  /// the device gallery.
  Future<void> _downloadWallpaper(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
  ) async {
    final success = await ref
        .read(downloadOperationsProvider.notifier)
        .download(wallpaperEntity);

    if (context.mounted) {
      if (success) {
        SnackbarHelpers.showSuccess(
          context: context,
          message: AppLocalizations.of(context)!.downloadOk,
          color: colors,
        );
      } else {
        SnackbarHelpers.showError(
          context: context,
          message: AppLocalizations.of(context)!.downloadError,
          color: colors,
        );
      }
    }
  }
}
