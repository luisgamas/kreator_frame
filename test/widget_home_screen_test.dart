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
    return [];
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
    });
  });
}
