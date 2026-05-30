// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

class ColorThemeSwitcher extends ConsumerWidget {
  const ColorThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appValuesAsync = ref.watch(appValuesPreferencesProvider);
    final colors = Theme.of(context).colorScheme;

    final appValuesFromPreference = appValuesAsync.value;
    if (appValuesFromPreference == null) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const SizedBox.shrink(),
          childCount: 0,
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisCount: 4,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // First item: Dynamic color (Material You)
          if (index == 0) {
            final isSelected = appValuesFromPreference.isDynamicColor;
            final dynamicFailed = isSelected && !appValuesFromPreference.dynamicColorAvailable;

            return GestureDetector(
              onTap: isSelected
                  ? null
                  : () => ref.read(appValuesPreferencesProvider.notifier)
                      .setPreferenceForDynamicColor(),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const SweepGradient(
                    colors: AppConstants.accentColors,
                  ),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Stack(
                  children: [
                    // Selection indicator
                    AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: AppDurations.normal,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: AppRadius.radiusSm,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.radiusXs,
                              color: colors.onPrimary.withValues(alpha: 0.7),
                            ),
                            child: const Icon(
                              Hicon.tickBold,
                              size: AppIconSizes.xxs,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Warning indicator when dynamic colors failed to load
                    if (dynamicFailed)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Icon(
                            Hicon.dangerTriangleOutline,
                            size: 12,
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          // Remaining items: accent color options (shifted by 1)
          final colorIndex = index - 1;
          final seedColor = AppConstants.accentColors[colorIndex];
          final isSelectedColor = !appValuesFromPreference.isDynamicColor &&
              seedColor == appValuesFromPreference.colorAccentForTheme;

          // Generate a theme-adaptive display color based on current brightness
          final displayScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Theme.of(context).brightness,
          );

          return GestureDetector(
            onTap: isSelectedColor
                ? null
                  : () => ref.read(appValuesPreferencesProvider.notifier)
                      .setPreferenceForColorAccent(AppConstants.accentColors[colorIndex]),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: displayScheme.primary,
                borderRadius: AppRadius.radiusLg,
              ),
              child: AnimatedOpacity(
                opacity: isSelectedColor ? 1 : 0,
                duration: AppDurations.normal,
                child: Center(
                  child: ClipRRect(
                    borderRadius: AppRadius.radiusSm,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.radiusXs,
                        color: colors.onPrimary.withValues(alpha: 0.7),
                      ),
                      child: const Icon(
                        Hicon.tickBold,
                        size: AppIconSizes.xxs,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        childCount: AppConstants.accentColors.length + 1,
      ),
    );
  }
}
