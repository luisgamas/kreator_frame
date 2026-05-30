// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/presentation/providers/providers.dart';
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
    // Trigger update check explicitly on first mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inAppUpdateProvider.notifier).checkAppForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabsBar = ref.watch(tabsBarAppProvider);

    // Auto-execute immediate update when available
    ref.listen(inAppUpdateProvider, (previous, next) async {
      if (next.canExecuteUpdate && !next.hasLaunchedUpdate) {
        await ref.read(inAppUpdateProvider.notifier).executeImmediateAppUpdate();
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
                  // App Bar
                  const CustomSliverAppBar(),
                ];
              },
              body: TabBarView(
                children: data.map((tabEntity) => tabEntity.tabBarView).toList(),
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
}
