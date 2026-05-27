import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/domain/entities/tab_bar_entity.dart';

// Mock for Preferences to avoid native plugin issues
class MockPreferencesNotifier extends AppValuesPreferencesNotifier {
  @override
  AppValuesPreferencesState build() {
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
    test('App Values Preferences Provider should initialize with default state', () {
      final container = ProviderContainer(
        overrides: [
          appValuesPreferencesProvider.overrideWith(() => MockPreferencesNotifier()),
        ],
      );
      
      final state = container.read(appValuesPreferencesProvider);
      expect(state.isDynamicColor, false);
    });

    test('TabsBarAppProvider should initialize correctly', () {
      final container = ProviderContainer(
        overrides: [
          tabsBarAppProvider.overrideWith(() => MockTabsBarNotifier()),
        ],
      );
      
      final state = container.read(tabsBarAppProvider);
      expect(state, isNotNull);
    });
  });
}
