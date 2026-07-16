// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/screens/secondary/kustom_widgets_screen.dart';
import 'package:kreator_frame/presentation/screens/secondary/wallpapers_screen.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';

/// Main home screen that displays the app content in tabs.
///
/// This widget uses providers for state management:
/// - `tabsBarAppProvider`: Provides the list of tabs to display
/// - `inAppUpdateProvider`: Checks for updates on mount and
///   executes immediate updates when available
///
/// All state is managed through Riverpod providers, eliminating the need
/// for local stateful widget management.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inAppUpdateProvider.notifier).checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabsBar = ref.watch(tabsBarAppProvider);

    // Show a dialog when an update is available so the user can choose
    // whether to proceed. Google Play will show its own confirmation
    // overlay once the user taps "Update".
    ref.listen(inAppUpdateProvider, (previous, next) {
      if (next.phase == InAppUpdatePhase.available) {
        _showUpdateAvailableDialog();
      }
    });

    return Scaffold(
      body: tabsBar.when(
        data: (data) => DefaultTabController(
          length: data.length,
          child: Builder(builder: (context) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // App Bar with tabs derived from the domain entity list
                  CustomSliverAppBar(
                    tabs: data.map((tab) => Tab(text: tab.label)).toList(),
                  ),
                ];
              },
              body: TabBarView(
                children: data.map(_buildTabView).toList(),
              ),
            );
          }),
        ),
        error: (_, _) => ErrorView(
          onRetry: () => ref.invalidate(tabsBarAppProvider),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(strokeCap: StrokeCap.round),
        ),
      ),
    );
  }

  /// Shows a user-facing dialog when a new version is available.
  ///
  /// Tapping "Update" triggers the immediate update flow; tapping "Later"
  /// leaves the state in [InAppUpdatePhase.available] so the dialog can
  /// be shown again on a future app launch.
  Future<void> _showUpdateAvailableDialog() async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
          'A new version is available. Would you like to update now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (shouldUpdate == true && context.mounted) {
      ref.read(inAppUpdateProvider.notifier).executeUpdate();
    }
  }

  /// Maps a pure domain [TabBarEntity] into a concrete widget.
  ///
  /// This is the single boundary where the presentation layer
  /// translates domain data into Flutter UI, keeping the domain
  /// layer free of framework dependencies.
  Widget _buildTabView(TabBarEntity tab) {
    return switch (tab.type) {
      TabBarType.kustomWidget =>
        const KustomWidgetsScreen(config: KustomWidgetConfig.kwgt),
      TabBarType.kustomLiveWallpaper =>
        const KustomWidgetsScreen(config: KustomWidgetConfig.klwp),
      TabBarType.wallpapers => const WallpapersScreen(),
    };
  }
}
