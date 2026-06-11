// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';

/// Sliver app bar used in the main home screen.
///
/// The list of [tabs] is provided by the caller so this widget stays
/// free of any domain-layer types. The presentation layer is responsible
/// for mapping domain entities into Flutter [Tab] widgets.
class CustomSliverAppBar extends ConsumerWidget {
  /// Tabs to render in the bottom [TabBar].
  final List<Tab> tabs;

  const CustomSliverAppBar({
    super.key,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final packageAppInfo = ref.watch(packageInfoProvider);
    final appRouter = ref.watch(appRouterProvider);

    // * Widget
    return SliverAppBar.large(
      pinned: true,
      title: packageAppInfo.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.byDeveloper(
                      EnvVars.userDeveloperName,
                    ),
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (EnvVars.userDeveloperName == AppInfo.appDeveloper) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    Hicon.verifiedBold,
                    color: colors.secondary,
                    size: AppIconSizes.xxxs,
                  ),
                ],
              ],
            ),
          ],
        ),
        error: (_, _) => Text(
          'Error',
          style: textStyles.headlineMedium?.copyWith(
            color: colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        loading: () => Text(
          '...',
          style: textStyles.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        CustomIconButton(
          onPressed: () => appRouter.push(AppRoutes.settings),
          icon: Hicon.categoryBold,
          tooltip: 'Settings',
        ),
      ],
      bottom: TabBar(
        labelStyle: textStyles.labelLarge,
        unselectedLabelStyle: textStyles.labelMedium,
        labelColor: colors.secondary,
        indicatorColor: colors.secondary,
        unselectedLabelColor: colors.outline,
        splashBorderRadius: AppRadius.radiusSm,
        tabs: tabs,
      ),
    );
  }
}
