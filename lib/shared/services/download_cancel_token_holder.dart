// 📦 Package imports:
import 'package:dio/dio.dart';

/// Holds the active [CancelToken] used by wallpaper downloads.
///
/// This holder is intentionally kept outside [DataSourceImpl] so the token
/// outlives the datasource's instance. Because [DataSourceImpl] is created
/// through a [Provider] that watches other dependencies (e.g. `dioProvider`),
/// any invalidation would otherwise rebuild the datasource and silently drop
/// the in-flight token, leaving the user unable to cancel an ongoing download.
///
/// The holder is a plain, framework-agnostic service. It is shared with the
/// datasource through dependency injection, so a single instance is used by
/// the entire download flow:
/// - [register] is called by the datasource when a download starts.
/// - [cancel] can be called by any consumer that owns the cancel button.
/// - [clear] is called by the datasource when the download settles
///   (success, failure, or cancellation) so the holder is ready for the next
///   download.
class DownloadCancelTokenHolder {
  CancelToken? _activeToken;

  /// The currently active token, or `null` when no download is in progress.
  CancelToken? get activeToken => _activeToken;

  /// Whether a download is currently tracked by this holder.
  bool get hasActiveToken => _activeToken != null;

  /// Creates a new [CancelToken], registers it as the active token, and
  /// returns it so the caller can pass it to `dio.get(...)`.
  ///
  /// If a previous token is still active it is cancelled first to avoid leaks.
  CancelToken register() {
    final previous = _activeToken;
    if (previous != null && !previous.isCancelled) {
      previous.cancel('Superseded by a new download request');
    }
    final token = CancelToken();
    _activeToken = token;
    return token;
  }

  /// Cancels the active download if there is one.
  ///
  /// Safe to call when no download is active. The token is cleared after
  /// cancellation so [hasActiveToken] returns to `false`.
  void cancel() {
    final token = _activeToken;
    if (token == null) return;
    if (!token.isCancelled) {
      token.cancel('Download cancelled by user');
    }
    _activeToken = null;
  }

  /// Clears the active token without cancelling it.
  ///
  /// Called by the datasource once a download completes (success or error)
  /// so the holder does not retain a reference to a token that has already
  /// settled.
  void clear() {
    _activeToken = null;
  }
}
