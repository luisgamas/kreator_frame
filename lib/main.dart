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
/// Configures the MaterialApp with:
/// - Localization support (English and Spanish)
/// - Go Router navigation
/// - Dynamic theming (light/dark modes with custom accent colors)
/// - Material You dynamic color support
/// - State management via Riverpod providers
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final appValuesFromPreference = ref.watch(appValuesPreferencesProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final isDynamic = appValuesFromPreference.isDynamicColor;

        // Validate dynamic color schemes — fall back to seed on Samsung/Xiaomi bugs
        final validatedLight = isDynamic ? DynamicColorValidator.validate(lightDynamic) : null;
        final validatedDark = isDynamic ? DynamicColorValidator.validate(darkDynamic) : null;

        // Track whether dynamic colors actually loaded for the UI
        final dynamicAvailable = validatedLight != null || validatedDark != null;
        if (isDynamic && !dynamicAvailable) {
          debugPrint('[DynamicColor] Device returned null or degenerate scheme — using fallback seed color');
        }
        // Update notifier so the UI can react to dynamic color availability
        ref.read(appValuesPreferencesProvider.notifier).updateDynamicColorAvailability(dynamicAvailable);

        final lightTheme = AppTheme(
          primaryColor: appValuesFromPreference.colorAccentForTheme,
          dynamicColorScheme: validatedLight,
        );

        final darkTheme = AppTheme(
          primaryColor: appValuesFromPreference.colorAccentForTheme,
          dynamicColorScheme: validatedDark,
        );

        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          themeMode: appValuesFromPreference.themeModeForApp,
          theme: lightTheme.lightTheme,
          darkTheme: darkTheme.darkTheme,
        );
      },
    );
  }
}
