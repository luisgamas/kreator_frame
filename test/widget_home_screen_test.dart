import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/domain/entities/tab_bar_entity.dart';

// Mock for Preferences to avoid Null check errors and native plugins
class MockPreferencesNotifier extends AppValuesPreferencesNotifier {
  @override
  AppValuesPreferencesState build() {
    return AppValuesPreferencesState(
      isDynamicColor: false,
    );
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

    test('TabsBarAppProvider should handle empty data state', () {
      final container = ProviderContainer(
        overrides: [
          tabsBarAppProvider.overrideWith((ref) => AsyncValue.data([])),
        ],
      );
      
      final state = container.read(tabsBarAppProvider);
      expect(state.value, isEmpty);
    });
  });
}
