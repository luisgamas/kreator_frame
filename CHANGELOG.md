# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

---

## [v1.7.0] - 2026-07-16

### Changed
- **In-app update system reimplemented**: Replaced fragile `String`-based status protocol with typed `InAppUpdateEntity` + `InAppUpdateAvailability` enum across all layers (datasource → repository → notifier).
- **`InAppUpdateManager` lifecycle managed via Riverpod DI**: Extracted `InAppUpdateManager` creation from `DataSourceImpl` into a dedicated `inAppUpdateManagerProvider` with `ref.onDispose()` cleanup, eliminating resource leaks.
- **Rich state machine for update flow**: Replaced two-boolean `InAppUpdateState` with `InAppUpdatePhase` enum covering the full lifecycle: `idle` → `checking` → `available` / `notAvailable` / `failed` → `executing`.
- **User consent dialog before update**: `HomeScreen` now shows an `AlertDialog` with "Update" / "Later" options instead of silently auto-executing the immediate update flow.
- **`CustomSliverAppBar` inlined into `SliverAppBar.large`**: Removed the separate app-bar widget wrappers and inlined them into a single `SliverAppBar` with an async-loaded title, removing ~137 lines and flattening the widget tree.
- **`SliverAppBar` collapsed size reduced to `.medium`**: Tuned the app bar size to `.medium` for better visual consistency across screens, accounting for the double title and the tab bar.
- **Theme debug logging removed**: Dropped the temporary `[DynamicColor]` debug prints and the raw-scheme logger from `main.dart` and trimmed the verbose comments in `DynamicColorValidator`. The Samsung/Xiaomi surface-container ramp repair logic is unchanged.

### Fixed
- **Error swallowing in update operations**: Error messages from `InAppUpdateManager` exceptions are now preserved in `InAppUpdateEntity.errorMessage` and logged via `debugPrint` instead of being replaced by a generic `'error'` string.

### Build
- **Flutter/Dart SDK constraints loosened**: `environment.sdk` is now `>=3.12.0` and `environment.flutter` is now `>=3.44.0` (open upper bounds) so `flutter pub get`/`run` work on any compatible SDK instead of failing against an exact pin. Lower bounds preserve the minimum versions the code relies on (`Color.withValues`, `WidgetStateProperty`).
- **CI Flutter version pinned in the deploy workflow**: The `Deploy AAB to Google Play` workflow now sets `flutter-version: 3.44.0` explicitly instead of reading `flutter-version-file: pubspec.yaml`. The version-file option requires an exact version and is incompatible with the loosened range above; pinning in CI keeps builds deterministic while pubspec stays flexible.

---

## [v1.6.1] - 2026-06-02

### Fixed
- **Release notes exceed Google Play 500-char limit per language**: Trimmed `.github/whatsnew/whatsnew-en-US` (588 -> 490 chars) and `whatsnew-es-ES` (657 -> 481 chars) so the `Deploy AAB to Google Play` workflow can upload them via the Google Play API.

---

## [v1.6.0] - 2026-06-02

### Fixed
- **Android native wallpaper picker & chooser permission issues on Xiaomi**: Explicitly granted read URI permissions to resolving packages for `getCropAndSetWallpaperIntent` and `ACTION_ATTACH_DATA` in `WallpapersNativeServices.kt`. Prevents `SecurityException` crashes on customized Android ROMs like MIUI/HyperOS.
- **MainActivity platform method crash**: Added safety try-catch blocks inside the Main Looper Handler post block in `MainActivity.kt` to handle launch exceptions safely and avoid crashing the app on unsupported devices.
- **Enabled Android native picker option**: Re-enabled the native wallpaper picker button callback in `WallpaperPreviewScreen` which was previously disabled.
- **Race condition in `AppValuesPreferencesNotifier`**: Migrated to `AsyncNotifier` so `SharedPreferences` are read before returning any state. Eliminates the theme-flash on app start where the default theme appeared for one frame before the saved preference loaded.
- **Side effect in `InAppUpdateNotifier.build()`**: Removed the `Future.microtask(() => checkAppForUpdates())` call from `build()` and replaced it with explicit invocation via `ref.read()`. Added `ref.mounted` guards after every `await` in `InAppUpdateNotifier` to prevent `setState()` errors when the widget is disposed during an async operation.
- **Race condition in `PermissionsNotifier`**: Migrated to `AsyncNotifier` to ensure `_init()` completes before returning the permission state. Eliminates the flash of a "denied" permission button on Android 10+ where storage permissions are granted by default.
- **Memory leak in `getListOfWidgets()`**: Added an in-memory cache keyed by file extension so repeated calls do not re-parse all ZIP archives from `AssetManifest`. The `Archive` objects are now properly handled, avoiding `Uint8List` retention across calls.
- **Missing `orElse` in `firstWhere()`**: Replaced `archive.firstWhere(...)` with `firstWhereOrNull` to prevent `StateError` when a ZIP archive does not contain the expected thumbnail file.
- **`ui.Image` GPU memory leak in `ColorPaletteExtractor`**: Added explicit `.dispose()` calls on `image` and `resizedImage` via `try`/`finally` blocks, ensuring GPU memory is freed immediately after color extraction.
- **Wallpaper preview full-resolution memory usage**: Limited `CachedNetworkImage` with `memCacheWidth` to cap decoded image size. Changed `InteractiveViewer` to `constrained: true` to prevent loading the full image into memory when zoomed out.
- **`ref.watch` used in action methods**: Replaced all `ref.watch()` calls with `ref.read()` inside button callbacks (`_applyWallpaper`, `_openChooser`, `_openNativePicker`) in `WallpaperPreviewScreen` to follow Riverpod best practices.
- **`setKeyValue` fire-and-forget**: Migrating to `AsyncNotifier` ensures preference persistence (SharedPreferences write) completes before the local state is updated, preventing state/persistence desync.
- **`_activeCancelToken` reference lost on datasource rebuild**: Extracted the `dio.CancelToken` lifecycle out of `DataSourceImpl` into a dedicated `DownloadCancelTokenHolder` service injected via `Provider`. The token now survives any `dataSourceProvider` rebuild (e.g. when `dioProvider` is invalidated), so `cancelDownloadWallpaper()` always operates on the in-flight request. The new holder also handles overlapping downloads safely: registering a new token cancels any previous, still-active one. Covered by 8 unit tests.
- **Direct repository access from widgets**: Added `WallpaperOperationsNotifier`, `DownloadOperationsNotifier`, `KustomOperationsNotifier`, `ExternalNavigationNotifier` and refactored UI accordingly.
- **`ThemeModeEntity` with Flutter types in domain layer**: Extracted `ThemeModeOption` pure enum into domain, moved `ThemeMode`/`IconData`/`BuildContext` mapping to presentation via `AppConstants` static helpers. `AppValuesPreferencesState` now stores `ThemeModeOption` with a `themeModeForApp` getter for `MaterialApp`.
- **`NetworkFailure` dead code**: Eliminated unused `NetworkFailure` entity and its export from `domain.dart`. Current error handling pattern (try/catch with defaults) is functional and consistent.
- **`KeyValueStorageServicesImpl` instantiated directly in notifier**: Added `keyValueStorageProvider` (`Provider<KeyValueStorageServices>`) in `repository_provider.dart`. `AppValuesPreferencesNotifier` now injects the service via `ref.watch`/`ref.read` instead of creating instances manually. Enables mock testing and follows the project's existing DI pattern.
- **`MyApp` full-widget rebuilds on any preference change**: Extracted `_MyAppContent` widget that uses `ref.select()` to observe only the specific preference fields needed (`isDynamicColor`, `colorAccentForTheme`, `themeModeForApp`). Changes in unrelated fields (e.g. `dynamicColorAvailable`, `minimalViewForGrids`) no longer trigger MaterialApp rebuilds.
- **`WallpaperDownloadButton` frequent rebuilds during download**: Extracted `_DownloadProgressIndicator` widget to isolate frequent progress updates. The parent widget uses `ref.select()` to observe only whether a download is active (`progress != null`), while the indicator widget observes the exact progress value. Limits rebuild scope during active downloads.
- **`Environment` class mixed unrelated responsibilities**: Split the monolithic `Environment` class into 7 focused files: `EnvVars` (.env variables), `StorageKeys` (SharedPreferences keys), `AppInfo` (app name/version/developer), `AssetPaths` (asset paths), `WallpaperConstants` (Android wallpaper flags), `ExternalLinks` (URLs), `KustomConfig` (Kustom app packages). `environment.dart` becomes a barrel export for backward compatibility.
- **Side effect in `MyApp.build()` with `ref.read`**: Converted `_MyAppContent` to `ConsumerStatefulWidget` and used `addPostFrameCallback` to defer dynamic color availability update after the frame completes, eliminating the `ref.read()` side-effect during `build()`.
- **Pixel overflow in `CustomSliverAppBar`**: Removed the fixed-height `PreferredSize` wrapper around the `TabBar` in the `SliverAppBar.bottom` property. The `TabBar` now calculates its intrinsic height dynamically, preventing pixel overflow or clipped text on devices with larger system font sizes or varying screen densities.

### Changed
- **Granular loading states in wallpaper bottom sheet**: Refactored `WallpaperOperationsNotifier` state from `bool` to a custom `WallpaperOperation` enum. This allows the preview bottom sheet to show the progress indicator ONLY on the button initiating the operation, while other options are grayed out safely.
- **Progressive full-resolution loading in wallpaper preview**: Refactored `_HeroImagePreview` in [wallpaper_preview_screen.dart](file:///C:/Users/Agent/Documents/Projects/kreator_frame/lib/presentation/screens/tertiary/wallpaper_preview_screen.dart) to load the high-resolution image progressively. It displays a memory-optimized 1.5x width preview during the entry transition to ensure 60fps animations, then asynchronously loads the full-resolution image and fades it in using `AnimatedOpacity` once decoded.
- **Wallpaper preview memory lifecycle control**: Evicts the high-resolution image from Flutter's memory cache (`ImageCache`) in `dispose()` to prevent memory leaks and free up device RAM when leaving the screen.
- Refactored `TabBarEntity` to a pure domain data entity (type + label) without any Flutter UI types. The `TabsBarAppNotifier` no longer builds widgets; the presentation layer (`HomeScreen`) maps each `TabBarEntity` to its concrete widget via a `switch` on a new `TabBarType` enum. `CustomSliverAppBar` now receives a `List<Tab>` parameter instead of reading the provider itself. Resolves the Clean Architecture violation tracked in `analisis.md` (section 2.1).
- Applied `const` constructors across multiple widget files to reduce rebuild overhead.
- `DataSourceImpl` constructor now requires a `DownloadCancelTokenHolder` in addition to `Dio`, formalising dependency injection for the cancel-token lifecycle (see fix above). `dataSourceProvider` wires the holder through a new `downloadCancelTokenHolderProvider`.
- Updated all files importing `Environment` to use specific constant classes (`EnvVars`, `StorageKeys`, `AppInfo`, `AssetPaths`, `WallpaperConstants`, `ExternalLinks`, `KustomConfig`).

### Performance
- **SharedPreferences instance caching**: `KeyValueStorageServicesImpl` now caches the `SharedPreferences` singleton via a lazy `_instance` getter with null-coalescing assignment, eliminating redundant `getInstance()` async calls on every read/write operation.
- **AsyncNotifier migration for race conditions**: `AppValuesPreferencesNotifier`, `InAppUpdateNotifier`, and `PermissionsNotifier` migrated to `AsyncNotifier` pattern, eliminating the "default state flash" at startup and ensuring state consistency.
- **`ref.select()` for rebuild optimization**: `MyApp` and `WallpaperDownloadButton` now use `ref.select()` to observe only the specific state fields they need, reducing unnecessary widget rebuilds when unrelated state changes.

---

## [v1.5.3] - 2026-03-07

### Fixed
- Migrated broken `kutt.it` external links to a new custom domain (`sink.gamas.workers.dev`) for social media, website, and policy documentation.
- Optimized network timeouts (`connectTimeout`: 10s, `receiveTimeout`: 15s) in `DataSourceImpl` to improve responsiveness and prevent long loading states on poor connectivity.
- Added robust error handling to `getListOfWallpapers` to gracefully handle network failures and return an empty list.

### Changed
- Adjusted donation button height to 48dp in `SettingsScreen` for improved UI consistency across the dashboard.

---

## [v1.5.2] - 2026-02-18

### Added
- Material You dynamic color (Material Design 3) support with `dynamic_color` package integration.
- Dynamic color option as first item in color theme selector with spectrum gradient visualization (SweepGradient).
- Wallpaper app chooser feature via Android system intent (ACTION_ATTACH_DATA): "Apply with..." bottom sheet showing all available apps for wallpaper application.
- New `_LocationButton` widget: compact icon button layout for wallpaper location selection (home, lock, both) with improved bottom sheet space efficiency.

### Changed
- Color theme selector now displays theme-adaptive color previews: colors adjust brightness/saturation based on current light/dark mode for proper contrast.
- Refactored color theme selector grid: dynamic color option (index 0) with SweepGradient, accent colors shifted to indices 1+.
- `ColorScheme.fromSeed()` now generates per-color display variants matching current app brightness in real-time.
- Wallpaper application bottom sheet layout optimized: 3 location options now display as compact icon buttons in a single row instead of 3 full-width buttons.
- `_ModalButton` replaced with `_LocationButton` and `_WallpaperChooserButton` for improved visual hierarchy and space efficiency.
- `_WallpaperChooserButton` uses `CustomButton.text` for visual differentiation as an alternative wallpaper application method.
- Theme mode switcher refined for consistent UI coherence across appearance settings.

### Technical Details
- Added `isDynamicColor` field to `AppValuesPreferencesState` with index `-1` storage convention.
- New `setPreferenceForDynamicColor()` method in `AppValuesPreferencesNotifier`.
- Added static `buildFromColorScheme()` method to `AppTheme` for Material You support.
- Wrapped `MaterialApp.router` with `DynamicColorBuilder` in `main.dart` with fallback to seed color for unsupported devices.
- New native Kotlin method `prepareWallpaperChooserIntent()` in `WallpapersNativeServices` for ACTION_ATTACH_DATA intent generation.
- New MethodChannel handler `openWallpaperChooser` in MainActivity for system app chooser intent.
- Added `openWallpaperChooser(String url)` across datasource → repository → UI layers.
- Localization strings: `bottomWallSelectorChooser` (English: "More options...", Spanish: "Más opciones...") and shortened location labels for compact display.
- `_LocationButton` widget: icon button (tonal) with label text below, supporting loading states and tap callbacks.

### Notes
- Dynamic Color support requires Android 12+ and is fully supported on Pixel devices; Samsung and other OEMs may have limited support due to custom color palette implementations.
- Wallpaper chooser requires Android system support for ACTION_ATTACH_DATA; behavior depends on installed apps that handle image attachment intents.

---

## [v1.5.1] - 2026-02-17

### Added
- New `ErrorView` reusable widget for displaying error states in async operations with optional retry button and customizable styling. Integrated across all screens using `AsyncValue.when()` for consistent error handling.
- Native Android wallpaper picker service via `WallpaperManager.getCropAndSetWallpaperIntent()`, allowing system UI selection of home screen, lock screen, or both. Implemented with `FileProvider` for secure content URI sharing.
- `WallpapersNativeServices` Kotlin class with clean separation of concerns: custom wallpaper application (download → crop → apply) and native picker integration (download → expose via FileProvider → system intent).
- New `_NativePickerButton` widget in WallpaperPreviewScreen providing alternative wallpaper application via native Android system UI.
- Wallpaper location constants in `Environment` class: `wallpaperHomeScreen` (1), `wallpaperLockScreen` (2), `wallpaperBothScreens` (3).
- New method `openNativeWallpaperPicker(String url)` across all data/repository layers (datasource → repository → UI).
- Localization strings for native picker option: `bottomWallSelectorNative` (English: "Use Android Wallpaper Picker", Spanish: "Usar selector nativo de Android").

### Fixed
- Completed the Riverpod 2.x → 3.x library migration by upgrading `flutter_riverpod` to `3.2.1` (previously only API patterns were updated, but the library remained on `2.6.1`).
- Replaced `FamilyAsyncNotifier<T, Arg>` (removed in Riverpod 3.x) with standard `AsyncNotifier<T>` using constructor-based argument injection for the `WidgetsNotifier` family provider.
- Replaced `AsyncValue.valueOrNull` (removed in Riverpod 3.x) with `AsyncValue.value` in `AboutPackageAppScreen`.

### Changed
- Migrated wallpaper application from third-party `flutter_wallpaper_manager` (0.0.4) to native Android implementation via Kotlin MethodChannel (`kreator_frame/wallpaper`). Image download, center-crop, and scaling now execute on background threads via `Thread` + `Handler` pattern, eliminating main thread blocking.
- Removed `Size size` parameter from `setWallpaper()` method across all layers (datasource → repository → UI). Screen dimensions now obtained natively via Android's `Resources.getSystem().displayMetrics`.
- Refactored error handling in HomeScreen, LicensesScreen, KustomWidgetsScreen, WallpapersScreen, and WallpaperPreviewScreen to use the new centralized `ErrorView` widget, eliminating code duplication.
- Replaced `flutter_staggered_grid_view` library with native `GridView.builder` using `mainAxisExtent` for precise cell height control. Refactored `CustomCardPreviews` to be constraint-responsive: removed `heightPreview` parameter, enabled image section to expand with `Expanded`, allowing parent grid to fully control sizing.
- Updated `KustomWidgetConfig` to use `cellHeight` (total grid cell height including image, text, and margins) instead of separate `previewHeight`, improving separation of concerns. Updated calculations: KWGT = 262dp (200 image + 62 overhead), KLWP = 352dp (290 image + 62 overhead).
- Updated multiple dependency versions to latest compatible releases: `archive`, `device_info_plus`, `dio`, `flutter_dotenv`, `flutter_markdown_plus`, `flutter_native_splash`, `go_router`, `image`, `shared_preferences`.
- Removed unused `flutter_cache_manager` direct dependency and corrected asset references in `Environment` constants.

### Removed
- `flutter_wallpaper_manager` (0.0.4) - functionality completely replaced with native Kotlin implementation.
- `flutter_staggered_grid_view` (0.7.0) - functionality replicated using native Flutter GridView.
- Unused Dart image processing methods: removed `_cropAndSaveImage()`, `dart:ui` codec operations, and `path_provider` dependency from datasource layer (moved to native Kotlin).

---

## [v1.5.0] - 2026-02-16

### Added
- Complete English documentation for all public classes and methods across the entire codebase.
- Auto-initialization pattern for in-app update checks using provider lifecycle.
- Material Design 3 improvements to AppBar, Cards, and Profile Header components.
- New unified KustomWidgetsScreen replacing duplicate KWGT/KLWP screens with configuration-based approach.
- Extracted WallpaperDownloadButton as reusable widget with progress tracking.

### Changed
- Migrated all providers from Riverpod 2.x codegen patterns to Riverpod 3.x manual patterns.
- Converted all ConsumerStatefulWidget instances to ConsumerWidget for better state management.
- Reorganized shared layer: split AppHelpers into SnackbarHelpers and AppConstants.
- Extracted route constants to dedicated AppRoutes class.
- Enhanced all entities with copyWith, operator==, and hashCode methods.
- Reorganized DataSourceImpl with clear sections and comprehensive documentation.
- Reduced wallpaper_preview_screen from 465 to 332 lines (-28.6%).
- Eliminated 100% code duplication between KWGT and KLWP screens.
- Optimized AppBar logo size (70dp → 65dp) with improved spacing and layout.
- Implemented ripple feedback effect in cards using InkWell.
- Reduced profile header avatar size (80dp → 65dp) for better visual balance.
- Moved button widgets (social_media_button_list, wallpaper_download_button) to organized buttons folder.
- Translated all Spanish comments and documentation to English.
- Updated all barrel export files with proper alphabetical organization.

### Removed
- Unused dependencies: flutter_hooks and hooks_riverpod.
- All .g.dart generated files and codegen-related dependencies.
- Legacy StateNotifier and StateNotifierProvider patterns.
- Duplicate screen files (kwgt_screen.dart and klwp_screen.dart).

### Fixed
- Improved provider injection chain: dataSourceProvider → repositoryProvider → notifiers.
- Enhanced download state management using progressDownloaderProvider instead of local state.
- Better Material Design 3 compliance while maintaining visual coherence.

## [v1.4.0] - 2025-07-11

### Added
- In App Update now available thanks to flutter_upgrade_version library.

### Changed
- Set minifyEnabled and shrinkResources to false in android/app/build.gradle file to maintain Kustom API recommended settings.
- Changed package_info_plus library to flutter_upgrade_version and improved use of app data for internal handling.

## [v1.3.0] - 2025-07-10

### Added
- The new flutter_markdown_plus library now controls the view widget for texts of type md.

### Changed
- Updated dependencies to the latest compatible versions.
- Removed obsolete riverpods that handled Theme and Color control and now use a customized riverpod optimized for proper loading and reading control.
- flutter_markdown library was discontinued and changed to flutter_markdown_plus.
- Terms & Conditions and Privacy Policy are now accessed via external links to the personal website.
- Now the access to the data sources is through the repository controlled by a read riverpod, allowing a better management of instances and declarations.
- Migrated the license list loading to a stateful riverpod class for better optimization of license loading and caching.

## [v1.2.1] - 2025-04-19

### Changed
- Updated dependencies to the latest compatible versions.
- Changes in the process for applying wallpaper to the device.
- Minor changes in app design and user experience (UI && UX).

## [v1.1.0] - 2024-10-18

### Added
- Added request for user permission to save downloaded images to device A13+ & A13-.
- Added a loading indicator for image previews.

### Changed
- Updated dependencies to the latest compatible versions.
- Change ofifical datala (Terms & Conditions and Privacy Policy).
- Change of method for applying the centred wallpaper.
- Changes in the design and representation of OSS licenses.
- Change widget to display image from URL with cache and loader.

## [v1.0.5] - 2024-08-06

### Added
- Improved error handling and logging for better debugging.
- Enhanced documentation and comments for better code readability.
- Refactored AppColorThemeProvider to initialize theme color state using a private method (_updateColorTheme).
- Refactored AppThemeModeProvider to initialize theme mode state using a private method (_updateThemeFromStorage).

### Changed
- Updated dependencies to the latest compatible versions.
- Refactored widget layout to improve performance and responsiveness.
- Fixed issues with state management in specific scenarios.
- Improved error handling and logging for better debugging.
- Enhanced documentation and comments for better code readability.
- The build method in AppColorThemeProvider now calls _updateColorTheme to initialize the theme color state.
- The build method in AppThemeModeProvider now calls _updateThemeFromStorage to initialize the theme mode state.
- Removed unnecessary calls to update methods in MyApp's build method.
- Simplified MyApp's build method to directly use theme and color state from providers.

## [v1.0.4] - 2024-05-29

### Added
- Support for KWGT and KLWP widgets.
- Adaptive icon support on Android.
- Support for image downloads on Android 14.
- Coupling for separate data handling between dashboard, dashboard developer, and widget package developer.

>[!IMPORTANT]
> ***Older versions not available***
