// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

// * STATE
/// State that holds in-app update information and status.
///
/// Tracks whether an update is available and whether an update
/// has already been launched to avoid duplicate update prompts.
class InAppUpdateState {
  final bool canExecuteUpdate;
  final bool hasLaunchedUpdate;

  InAppUpdateState({
    this.canExecuteUpdate = false,
    this.hasLaunchedUpdate = false,
  });

  InAppUpdateState copyWith({
    bool? canExecuteUpdate,
    bool? hasLaunchedUpdate,
  }) => InAppUpdateState(
    canExecuteUpdate: canExecuteUpdate ?? this.canExecuteUpdate,
    hasLaunchedUpdate: hasLaunchedUpdate ?? this.hasLaunchedUpdate,
  );
}

// * NOTIFIER
/// Notifier that manages in-app update state.
///
/// Check should be triggered explicitly (e.g., from HomeScreen on mount)
/// rather than performing side effects during build().
class InAppUpdateNotifier extends Notifier<InAppUpdateState> {
  @override
  InAppUpdateState build() {
    return InAppUpdateState();
  }

  /// Checks if there are updates available for the application.
  /// Updates the state with the result of the verification.
  Future<void> checkAppForUpdates() async {
    try {
      if (state.hasLaunchedUpdate) return;

      final repository = ref.read(repositoryProvider);
      final resultOfReviewingUpdates = await repository.checkAppForUpdates();

      if (!ref.mounted) return;
      state = state.copyWith(
        canExecuteUpdate: resultOfReviewingUpdates == 'updateAvailable',
        hasLaunchedUpdate: resultOfReviewingUpdates == 'recovered',
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        canExecuteUpdate: false,
        hasLaunchedUpdate: false,
      );
    }
  }

  /// Executes the immediate update of the application.
  /// Can only be executed if an update is available.
  Future<void> executeImmediateAppUpdate() async {
    try {
      final repository = ref.read(repositoryProvider);
      final resultOfReviewingUpdates = await repository.executeImmediateAppUpdate();

      if (!ref.mounted) return;
      state = state.copyWith(
        canExecuteUpdate: resultOfReviewingUpdates == 'upToDate' ? false : state.canExecuteUpdate,
        hasLaunchedUpdate: resultOfReviewingUpdates == 'upToDate',
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        canExecuteUpdate: false,
        hasLaunchedUpdate: false,
      );
    }
  }
}

// * PROVIDER
/// Provider that exposes in-app update state and functionality.
/// Check should be triggered explicitly from the UI layer.
final inAppUpdateProvider = NotifierProvider<InAppUpdateNotifier, InAppUpdateState>(
  InAppUpdateNotifier.new,
);
