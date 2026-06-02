// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/constants/environment.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/repository_provider.dart';
import 'package:kreator_frame/shared/services/services.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

// * STATE
/// State that holds user preferences for app appearance and behavior.
///
/// Stores:
/// - Theme mode option (system, light, dark) as a pure domain enum
/// - Accent color for the theme
/// - Dynamic color (Material You) toggle
/// - Whether dynamic colors are actually available on this device
/// - Grid view preferences (currently unused)
class AppValuesPreferencesState {
  final Color colorAccentForTheme;
  final ThemeModeOption themeModeOption;
  final bool isDynamicColor;
  final bool dynamicColorAvailable;
  final bool minimalViewForGrids;

  AppValuesPreferencesState({
    Color? colorAccentForTheme,
    ThemeModeOption? themeModeOption,
    this.isDynamicColor = false,
    this.dynamicColorAvailable = false,
    this.minimalViewForGrids = false,
  })  : colorAccentForTheme = colorAccentForTheme ?? AppConstants.accentColors[4],
        themeModeOption = themeModeOption ?? ThemeModeOption.system;

  /// Maps the domain [themeModeOption] to Flutter's [ThemeMode] for MaterialApp.
  ThemeMode get themeModeForApp => AppConstants.themeModeFromOption(themeModeOption);

  AppValuesPreferencesState copyWith({
    Color? colorAccentForTheme,
    ThemeModeOption? themeModeOption,
    bool? isDynamicColor,
    bool? dynamicColorAvailable,
    bool? minimalViewForGrids,
  }) => AppValuesPreferencesState(
    colorAccentForTheme: colorAccentForTheme ?? this.colorAccentForTheme,
    themeModeOption: themeModeOption ?? this.themeModeOption,
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
    final keyValueStorageServices = ref.watch(keyValueStorageProvider);
    return _loadPreferences(keyValueStorageServices);
  }

  Future<AppValuesPreferencesState> _loadPreferences(
    KeyValueStorageServices keyValueStorageServices,
  ) async {
    final indexColorAccent = await keyValueStorageServices.getKeyValue<int>(Environment.keyColorTheme) ?? 4;
    final indexThemeMode = await keyValueStorageServices.getKeyValue<String>(Environment.keyThemeMode);

    final themeModeOption = switch (indexThemeMode) {
      'system' => ThemeModeOption.system,
      'light' => ThemeModeOption.light,
      'dark' => ThemeModeOption.dark,
      _ => ThemeModeOption.system,
    };

    if (indexColorAccent == -1) {
      return AppValuesPreferencesState(
        isDynamicColor: true,
        themeModeOption: themeModeOption,
      );
    } else {
      final clampedIndex = (indexColorAccent >= 0 && indexColorAccent < AppConstants.accentColors.length)
          ? indexColorAccent
          : 4;
      return AppValuesPreferencesState(
        isDynamicColor: false,
        colorAccentForTheme: AppConstants.accentColors[clampedIndex],
        themeModeOption: themeModeOption,
      );
    }
  }

  Future<void> setPreferenceForThemeMode(ThemeModeOption option) async {
    final currentState = state.value;
    if (currentState == null) return;

    final keyValueStorageServices = ref.read(keyValueStorageProvider);
    await keyValueStorageServices.setKeyValue(Environment.keyThemeMode, option.name);
    if (!ref.mounted) return;
    if (option != currentState.themeModeOption) {
      state = AsyncData(currentState.copyWith(themeModeOption: option));
    }
  }

  Future<void> setPreferenceForColorAccent(Color color) async {
    final currentState = state.value;
    if (currentState == null) return;

    final colorIndex = AppConstants.accentColors.indexOf(color);
    final keyValueStorageServices = ref.read(keyValueStorageProvider);
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

    final keyValueStorageServices = ref.read(keyValueStorageProvider);
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
