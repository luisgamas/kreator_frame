// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/config/constants/env_vars.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';
import 'package:kreator_frame/presentation/screens/secondary/kustom_widgets_screen.dart';

/// Notifier that manages the application's tab list.
///
/// Emits pure domain [TabBarEntity] data so the domain layer stays free
/// of Flutter UI types. The presentation layer is responsible for mapping
/// each entity into a concrete widget.
class TabsBarAppNotifier extends AsyncNotifier<List<TabBarEntity>> {
  @override
  Future<List<TabBarEntity>> build() async {
    ref.keepAlive();
    final repository = ref.watch(repositoryProvider);
    final kwgt = await repository.getListOfWidgets('kwgt', 'preset_thumb_portrait.jpg');
    final klwp = await repository.getListOfWidgets('klwp', 'preset_thumb_portrait.jpg');
    final List<TabBarEntity> tabList = [];

    if (kwgt.isNotEmpty) {
      tabList.add(
        const TabBarEntity(
          type: TabBarType.kustomWidget,
          label: KustomWidgetConfig.kwgtTabLabel,
        ),
      );
    }

    if (klwp.isNotEmpty) {
      tabList.add(
        const TabBarEntity(
          type: TabBarType.kustomLiveWallpaper,
          label: KustomWidgetConfig.klwpTabLabel,
        ),
      );
    }

    if (EnvVars.userWallpapersUrl != 'NA' &&
        EnvVars.userWallpapersUrl != 'Error WALLPAPERS_URL') {
      tabList.add(
        const TabBarEntity(
          type: TabBarType.wallpapers,
          label: 'WALLPAPERS',
        ),
      );
    }

    return tabList;
  }
}

/// Provider that exposes the application's tab list.
/// The state is kept in memory for the lifetime of the app.
final tabsBarAppProvider = AsyncNotifierProvider<TabsBarAppNotifier, List<TabBarEntity>>(
  TabsBarAppNotifier.new,
);
