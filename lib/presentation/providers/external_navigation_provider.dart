// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/presentation/providers/repository_provider.dart';

/// Immutable state for the external navigation notifier.
///
/// [isLaunching] reflects whether an `launchExternalApp` call is currently
/// running. The current call sites are fire-and-forget taps (settings
/// links, donation button, social media, etc.), so the flag exists mostly
/// for future UI extensions (e.g. a "navigating..." affordance) and to
/// keep the notifier stateful in line with the rest of the project
/// (every Notifier in this project exposes an immutable state).
class ExternalNavigationState {
  final bool isLaunching;

  const ExternalNavigationState({
    this.isLaunching = false,
  });

  ExternalNavigationState copyWith({
    bool? isLaunching,
  }) {
    return ExternalNavigationState(
      isLaunching: isLaunching ?? this.isLaunching,
    );
  }
}

/// Notifier that centralizes external URL / app launches.
///
/// This is the single presentation-layer entry point for
/// `Repository.launchExternalApp`, which is currently called from
/// settings, donation banner, dashboard about and package about
/// screens. Funneling all of them through this notifier:
/// - keeps the layering clean (no widget imports the repository)
/// - gives a single hook to add telemetry, snackbar feedback or
///   error handling later
/// - exposes a tiny state surface so widgets can disable a button
///   while a launch is in flight
class ExternalNavigationNotifier extends Notifier<ExternalNavigationState> {
  @override
  ExternalNavigationState build() => const ExternalNavigationState();

  /// Launches the given [url] in the system handler (browser, Play
  /// Store, social app, etc.) via the repository.
  ///
  /// The datasource throws an `Exception('Could not launch your url')`
  /// when the platform refuses to launch; the exception is rethrown
  /// unchanged so call sites can decide whether to surface it (some
  /// already show a snackbar on missing social handles).
  Future<void> launchExternalApp(String url) async {
    state = state.copyWith(isLaunching: true);
    try {
      final repository = ref.read(repositoryProvider);
      await repository.launchExternalApp(url);
    } finally {
      if (ref.mounted) state = state.copyWith(isLaunching: false);
    }
  }
}

/// Provider that exposes the external navigation state and the
/// `launchExternalApp` operation.
final externalNavigationProvider =
    NotifierProvider<ExternalNavigationNotifier, ExternalNavigationState>(
  ExternalNavigationNotifier.new,
);
