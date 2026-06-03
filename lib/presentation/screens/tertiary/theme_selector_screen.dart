// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    // * Widget view
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // * App Bar
          CustomSliverAppBarScreens(
            tileText: AppLocalizations.of(context)!.themeAppBarTitle
          ),

          // * Title & Mode Theme Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                AppLocalizations.of(context)!.themeSelector,
                style: textStyles.titleLarge
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusLg,
                color: colors.surfaceContainerHighest),
              sliver: const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.md),
                sliver: ThemeModeSwitcher(),
              ),
            ),
          ),

          // * Separator
          const SliverGap(AppSpacing.lg),

          // * Title & Color Theme Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                AppLocalizations.of(context)!.themeColorSelector,
                style: textStyles.titleLarge
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusLg,
                  color: colors.surfaceContainerHighest),
              sliver: const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.md),
                sliver: ColorThemeSwitcher(),
              ),
            ),
          ),

          // Warning when dynamic colors are not available on this device
          const _DynamicColorWarning(),

          const SliverGap(AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Shows a warning when dynamic colors are selected but not available on this device.
class _DynamicColorWarning extends ConsumerWidget {
  const _DynamicColorWarning();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appValuesAsync = ref.watch(appValuesPreferencesProvider);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final appValuesFromPreference = appValuesAsync.value;
    if (appValuesFromPreference == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Only show when dynamic color is selected but not actually available
    if (!appValuesFromPreference.isDynamicColor || appValuesFromPreference.dynamicColorAvailable) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: AppRadius.radiusLg,
          ),
          child: Row(
            children: [
              Icon(
                Hicon.dangerCircleOutline,
                color: colors.onErrorContainer,
                size: 20,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.themeDynamicColorUnavailable,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
