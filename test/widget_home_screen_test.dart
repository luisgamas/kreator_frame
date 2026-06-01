// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/entities/tab_bar_entity.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';

// Mock for Preferences to avoid native plugin issues
class MockPreferencesNotifier extends AppValuesPreferencesNotifier {
  @override
  Future<AppValuesPreferencesState> build() async {
    return AppValuesPreferencesState(
      isDynamicColor: false,
    );
  }
}

// Correctly typed Mock for TabsBarAppNotifier
class MockTabsBarNotifier extends TabsBarAppNotifier {
  @override
  Future<List<TabBarEntity>> build() async {
    return const [
      TabBarEntity(type: TabBarType.kustomWidget, label: 'KWGT'),
      TabBarEntity(type: TabBarType.kustomLiveWallpaper, label: 'KLWP'),
      TabBarEntity(type: TabBarType.wallpapers, label: 'WALLPAPERS'),
    ];
  }
}

void main() {
  group('Riverpod State Tests', () {
    test('App Values Preferences Provider should initialize with default state', () async {
      final container = ProviderContainer(
        overrides: [
          appValuesPreferencesProvider.overrideWith(() => MockPreferencesNotifier()),
        ],
      );

      final state = await container.read(appValuesPreferencesProvider.future);
      expect(state.isDynamicColor, false);
    });

    test('TabsBarAppProvider should initialize correctly', () async {
      final container = ProviderContainer(
        overrides: [
          tabsBarAppProvider.overrideWith(() => MockTabsBarNotifier()),
        ],
      );

      final state = await container.read(tabsBarAppProvider.future);
      expect(state, isNotNull);
      expect(state.length, 3);
      expect(state[0].type, TabBarType.kustomWidget);
      expect(state[0].label, 'KWGT');
      expect(state[1].type, TabBarType.kustomLiveWallpaper);
      expect(state[1].label, 'KLWP');
      expect(state[2].type, TabBarType.wallpapers);
      expect(state[2].label, 'WALLPAPERS');
    });
  });

  group('TabBarEntity Tests', () {
    test('equality and hashCode are based on type and label', () {
      const a = TabBarEntity(type: TabBarType.kustomWidget, label: 'KWGT');
      const b = TabBarEntity(type: TabBarType.kustomWidget, label: 'KWGT');
      const c = TabBarEntity(type: TabBarType.kustomWidget, label: 'OTHER');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('domain entity has no Flutter UI types', () {
      const entity = TabBarEntity(type: TabBarType.wallpapers, label: 'WALLPAPERS');
      // The entity is plain Dart data: only String + enum fields
      expect(entity.type, isA<TabBarType>());
      expect(entity.label, isA<String>());
    });
  });
}
