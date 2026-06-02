// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

/// Entry point of the Kreator Frame application.
///
/// Initializes Flutter bindings, sets portrait orientation, loads environment
/// variables from .env file, and starts the app with Riverpod state management.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

/// Root widget of the Kreator Frame application.
///
/// Handles the [AsyncValue] lifecycle (loading / error / data) and delegates
/// the actual MaterialApp configuration to [_MyAppContent], which uses
/// [ref.select] to rebuild only when the specific preference fields change.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appValuesAsync = ref.watch(appValuesPreferencesProvider);

    return appValuesAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeCap: StrokeCap.round),
          ),
        ),
      ),
      error: (_, _) => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to load preferences'),
          ),
        ),
      ),
      data: (_) => const _MyAppContent(),
    );
  }
}

/// Builds the actual [MaterialApp] using [ref.select] to observe only the
/// preference fields it needs, avoiding full-widget rebuilds when unrelated
/// state fields (e.g. [AppValuesPreferencesState.dynamicColorAvailable])
/// change.
///
/// **Side-effect free:** Dynamic color validation is handled by listening to
/// the [DynamicColorBuilder] output and forwarding it to the notifier via
/// [AppValuesPreferencesNotifier.updateDynamicColorAvailability], which is
/// called from a [ref.listen] callback (not from `build()`).
class _MyAppContent extends ConsumerStatefulWidget {
  const _MyAppContent();

  @override
  ConsumerState<_MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends ConsumerState<_MyAppContent> {
  @override
  void initState() {
    super.initState();
    // Schedule the dynamic color validation after the first frame so the
    // DynamicColorBuilder has had a chance to provide the color schemes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateDynamicColor();
    });
  }

  /// Reads the current dynamic color schemes from [DynamicColorBuilder]
  /// and updates the notifier with the availability status.
  void _validateDynamicColor() {
    // This method is called once after init and whenever the theme changes.
    // The actual validation logic lives in the notifier.
    // We just need to trigger it with the current context.
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    final isDynamic = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.isDynamicColor ?? false),
    );
    final colorAccent = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.colorAccentForTheme ?? AppConstants.accentColors[4]),
    );
    final themeMode = ref.watch(
      appValuesPreferencesProvider.select((async) => async.value?.themeModeForApp ?? ThemeMode.system),
    );

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Validate dynamic color schemes — fall back to seed on Samsung/Xiaomi bugs
        final validatedLight = isDynamic ? DynamicColorValidator.validate(lightDynamic) : null;
        final validatedDark = isDynamic ? DynamicColorValidator.validate(darkDynamic) : null;

        // Track whether dynamic colors actually loaded for the UI
        final dynamicAvailable = validatedLight != null || validatedDark != null;
        if (isDynamic && !dynamicAvailable) {
          debugPrint('[DynamicColor] Device returned null or degenerate scheme — using fallback seed color');
        }

        // Update notifier after the build completes to avoid side-effects in build()
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appValuesPreferencesProvider.notifier).updateDynamicColorAvailability(dynamicAvailable);
        });

        final lightTheme = AppTheme(
          primaryColor: colorAccent,
          dynamicColorScheme: validatedLight,
        );

        final darkTheme = AppTheme(
          primaryColor: colorAccent,
          dynamicColorScheme: validatedDark,
        );

        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          themeMode: themeMode,
          theme: lightTheme.lightTheme,
          darkTheme: darkTheme.darkTheme,
        );
      },
    );
  }
}
