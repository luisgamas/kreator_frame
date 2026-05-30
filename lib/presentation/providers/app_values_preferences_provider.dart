// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/constants/environment.dart';
import 'package:kreator_frame/shared/services/services.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

// * STATE
/// State that holds user preferences for app appearance and behavior.
///
/// Stores:
/// - Theme mode (light, dark, system)
/// - Accent color for the theme
/// - Dynamic color (Material You) toggle
/// - Whether dynamic colors are actually available on this device
/// - Grid view preferences (currently unused)
class AppValuesPreferencesState {
  final Color colorAccentForTheme;
  final ThemeMode themeModeForApp;
  final bool isDynamicColor;
  final bool dynamicColorAvailable;
  final bool minimalViewForGrids;

  AppValuesPreferencesState({
    Color? colorAccentForTheme,
    ThemeMode? themeModeForApp,
    this.isDynamicColor = false,
    this.dynamicColorAvailable = false,
    this.minimalViewForGrids = false,
  })  : colorAccentForTheme = colorAccentForTheme ?? AppConstants.accentColors[4],
        themeModeForApp = themeModeForApp ?? AppConstants.themeModeOptions[0].themeMode;

  AppValuesPreferencesState copyWith({
    Color? colorAccentForTheme,
    ThemeMode? themeModeForApp,
    bool? isDynamicColor,
    bool? dynamicColorAvailable,
    bool? minimalViewForGrids,
  }) => AppValuesPreferencesState(
    colorAccentForTheme: colorAccentForTheme ?? this.colorAccentForTheme,
    themeModeForApp: themeModeForApp ?? this.themeModeForApp,
    isDynamicColor: isDynamicColor ?? this.isDynamicColor,
    dynamicColorAvailable: dynamicColorAvailable ?? this.dynamicColorAvailable,
    minimalViewForGrids: minimalViewForGrids ?? this.minimalViewForGrids,
  );

}

// * NOTIFIER
/// Notifier that manages user preferences for app appearance.
///
/// Loads preferences from persistent storage on initialization and provides
/// methods to update theme mode and accent color. All changes are automatically
/// persisted to SharedPreferences.
class AppValuesPreferencesNotifier extends AsyncNotifier<AppValuesPreferencesState> {
  @override
  Future<AppValuesPreferencesState> build() async {
    final keyValueStorageServices = KeyValueStorageServicesImpl();
    return _loadPreferences(keyValueStorageServices);
  }

  Future<AppValuesPreferencesState> _loadPreferences(
    KeyValueStorageServices keyValueStorageServices,
  ) async {
    final indexColorAccent = await keyValueStorageServices.getKeyValue<int>(Environment.keyColorTheme) ?? 4;
    final indexThemeMode = await keyValueStorageServices.getKeyValue<String>(Environment.keyThemeMode);

    final themeMode = switch (indexThemeMode) {
      'system' => AppConstants.themeModeOptions[0].themeMode,
      'light' => AppConstants.themeModeOptions[1].themeMode,
      'dark' => AppConstants.themeModeOptions[2].themeMode,
      _ => ThemeMode.system,
    };

    if (indexColorAccent == -1) {
      return AppValuesPreferencesState(
        isDynamicColor: true,
        themeModeForApp: themeMode,
      );
    } else {
      final clampedIndex = (indexColorAccent >= 0 && indexColorAccent < AppConstants.accentColors.length)
          ? indexColorAccent
          : 4;
      return AppValuesPreferencesState(
        isDynamicColor: false,
        colorAccentForTheme: AppConstants.accentColors[clampedIndex],
        themeModeForApp: themeMode,
      );
    }
  }

  Future<void> setPreferenceForThemeMode(ThemeMode themeMode) async {
    final currentState = state.value;
    if (currentState == null) return;

    final keyValueStorageServices = KeyValueStorageServicesImpl();
    await keyValueStorageServices.setKeyValue(Environment.keyThemeMode, themeMode.name);
    if (!ref.mounted) return;
    if (themeMode != currentState.themeModeForApp) {
      state = AsyncData(currentState.copyWith(themeModeForApp: themeMode));
    }
  }

  Future<void> setPreferenceForColorAccent(Color color) async {
    final currentState = state.value;
    if (currentState == null) return;

    final colorIndex = AppConstants.accentColors.indexOf(color);
    final keyValueStorageServices = KeyValueStorageServicesImpl();
    await keyValueStorageServices.setKeyValue(Environment.keyColorTheme, colorIndex);
    if (!ref.mounted) return;
    state = AsyncData(currentState.copyWith(
      colorAccentForTheme: color,
      isDynamicColor: false,
    ));
  }

  Future<void> setPreferenceForDynamicColor() async {
    final currentState = state.value;
    if (currentState == null) return;

    final keyValueStorageServices = KeyValueStorageServicesImpl();
    await keyValueStorageServices.setKeyValue(Environment.keyColorTheme, -1);
    if (!ref.mounted) return;
    state = AsyncData(currentState.copyWith(isDynamicColor: true));
  }

  /// Updates whether dynamic colors actually loaded on this device.
  /// Called from main.dart after DynamicColorBuilder provides the schemes.
  void updateDynamicColorAvailability(bool available) {
    final currentState = state.value;
    if (currentState == null) return;
    if (currentState.dynamicColorAvailable != available) {
      state = AsyncData(currentState.copyWith(dynamicColorAvailable: available));
    }
  }
}

// * PROVIDER
/// Provider that exposes user preference state and management functionality.
/// The state persists across app restarts using SharedPreferences.
final appValuesPreferencesProvider = AsyncNotifierProvider<AppValuesPreferencesNotifier, AppValuesPreferencesState>(
  AppValuesPreferencesNotifier.new,
);
