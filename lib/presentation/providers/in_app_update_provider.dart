// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

/// Phase of the in-app update lifecycle within the presentation layer.
///
/// Tracks where the user is in the update flow so the UI can render the
/// appropriate feedback (idle, loading spinner, error banner, etc.).
enum InAppUpdatePhase {
  /// No check has been performed yet.
  idle,

  /// Currently querying the Play Store for an available update.
  checking,

  /// An update is available and ready to be started by the user.
  available,

  /// No update is available at this time.
  notAvailable,

  /// An update was started previously and is being resumed.
  inProgress,

  /// Currently executing the immediate update flow.
  executing,

  /// An irrecoverable error occurred during check or execution.
  failed,
}

/// Presentation-layer state for the in-app update feature.
///
/// Holds the current [phase] of the update lifecycle together with an
/// optional error message so the UI can react to every state transition
/// without interpreting raw strings or tracking multiple booleans.
class InAppUpdateState {
  final InAppUpdatePhase phase;
  final String? errorMessage;

  const InAppUpdateState({
    this.phase = InAppUpdatePhase.idle,
    this.errorMessage,
  });

  bool get canExecuteUpdate =>
      phase == InAppUpdatePhase.available;

  InAppUpdateState copyWith({
    InAppUpdatePhase? phase,
    String? errorMessage,
  }) {
    return InAppUpdateState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier that manages the in-app update lifecycle.
///
/// Responsibilities (single-responsibility):
/// - Expose check/execute actions to the UI.
/// - Translate [InAppUpdateEntity] results from the repository into
///   presentation-layer [InAppUpdatePhase] transitions.
/// - Guard against duplicate execution and stale async callbacks.
///
/// The check should be triggered explicitly from the UI layer (e.g., in
/// [HomeScreen.initState]) rather than performing side effects during
/// provider initialization.
class InAppUpdateNotifier extends Notifier<InAppUpdateState> {
  @override
  InAppUpdateState build() {
    return const InAppUpdateState();
  }

  /// Queries the Play Store for an available update.
  ///
  /// Skips the network call entirely if an update has already been detected
  /// or is currently being executed, avoiding wasted requests.
  Future<void> checkForUpdates() async {
    if (state.phase == InAppUpdatePhase.available ||
        state.phase == InAppUpdatePhase.executing ||
        state.phase == InAppUpdatePhase.inProgress) {
      return;
    }

    state = state.copyWith(phase: InAppUpdatePhase.checking, errorMessage: null);

    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.checkAppForUpdates();

      if (!ref.mounted) return;

      state = state.copyWith(
        phase: _mapAvailabilityToPhase(result.availability),
        errorMessage: result.errorMessage,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: InAppUpdatePhase.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Starts the immediate update flow via Google Play.
  ///
  /// This should only be called after [state.canExecuteUpdate] is `true`.
  /// Once started, Google Play owns the entire flow (download → install →
  /// restart), so the state transitions to [InAppUpdatePhase.executing]
  /// and the app will likely be restarted by the Play Store.
  Future<void> executeUpdate() async {
    if (state.phase != InAppUpdatePhase.available) return;

    state = state.copyWith(phase: InAppUpdatePhase.executing, errorMessage: null);

    try {
      final repository = ref.read(repositoryProvider);
      final result = await repository.executeImmediateAppUpdate();

      if (!ref.mounted) return;

      state = state.copyWith(
        phase: _mapAvailabilityToPhase(result.availability),
        errorMessage: result.errorMessage,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: InAppUpdatePhase.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resets the state back to idle, allowing a fresh check later.
  void reset() {
    state = const InAppUpdateState();
  }
}

InAppUpdatePhase _mapAvailabilityToPhase(InAppUpdateAvailability availability) {
  return switch (availability) {
    InAppUpdateAvailability.unknown =>
      InAppUpdatePhase.notAvailable,
    InAppUpdateAvailability.notAvailable =>
      InAppUpdatePhase.notAvailable,
    InAppUpdateAvailability.available =>
      InAppUpdatePhase.available,
    InAppUpdateAvailability.inProgress =>
      InAppUpdatePhase.inProgress,
    InAppUpdateAvailability.failed =>
      InAppUpdatePhase.failed,
  };
}

/// Provider that exposes in-app update state and actions.
///
/// UI should watch this provider to react to state transitions and call
/// [InAppUpdateNotifier.checkForUpdates] on mount.
final inAppUpdateProvider =
    NotifierProvider<InAppUpdateNotifier, InAppUpdateState>(
  InAppUpdateNotifier.new,
);
