// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

/// Immutable state for the Kustom operations notifier.
///
/// [isLoading] reflects whether a Kustom operation is currently running,
/// so the `KustomWidgetsScreen` grid can stay enabled/disabled
/// accordingly. [lastResult] holds the boolean result of the most recent
/// sendWidget call, useful for the UI to react via `ref.listen` if it
/// needs to surface a snackbar.
class KustomOperationState {
  final bool isLoading;
  final bool? lastResult;

  const KustomOperationState({
    this.isLoading = false,
    this.lastResult,
  });

  KustomOperationState copyWith({
    bool? isLoading,
    bool? lastResult,
  }) {
    return KustomOperationState(
      isLoading: isLoading ?? this.isLoading,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

/// Notifier that centralizes Kustom (KWGT / KLWP) app interactions.
///
/// This is the single presentation-layer entry point for
/// `Repository.isKustomAppInstalled` and `Repository.sendWidgetToKustomApp`.
/// Widgets invoke notifier methods, the notifier talks to the repository
/// through DI and the repository delegates to the datasource. Widgets
/// never touch the repository directly.
class KustomOperationsNotifier extends Notifier<KustomOperationState> {
  @override
  KustomOperationState build() => const KustomOperationState();

  /// Returns whether the Kustom app identified by [packageName] is
  /// installed on the device.
  ///
  /// This is a thin convenience wrapper around the repository call. It
  /// does not mutate the notifier state because it is used as a decision
  /// point before launching the Kustom app / the Play Store fallback.
  Future<bool> isKustomAppInstalled(String packageName) async {
    final repository = ref.read(repositoryProvider);
    return repository.isKustomAppInstalled(packageName);
  }

  /// Sends a widget/preset to the Kustom app identified by [packageName].
  ///
  /// Returns `true` if the send intent was launched successfully, `false`
  /// otherwise. Errors raised by the datasource are propagated as `false`
  /// to match the pre-refactor behaviour.
  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.sendWidgetToKustomApp(
        packageName: packageName,
        editorActivity: editorActivity,
        assetPath: assetPath,
      );
      if (!ref.mounted) return result;
      state = state.copyWith(isLoading: false, lastResult: result);
      return result;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, lastResult: false);
      return false;
    }
  }
}

/// Provider that exposes the Kustom operations state and operations.
final kustomOperationsProvider =
    NotifierProvider<KustomOperationsNotifier, KustomOperationState>(
  KustomOperationsNotifier.new,
);
