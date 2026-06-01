// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

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
    final size = MediaQuery.of(context).size;

    // * Widget
    return SliverAppBar(
      backgroundColor: colors.surface,
      expandedHeight: 150,
      pinned: true,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AppBarWidgets(textStyles: textStyles, colors: colors),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.05),
        child: TabBar(
          labelStyle: textStyles.labelLarge,
          unselectedLabelStyle: textStyles.labelMedium,
          labelColor: colors.secondary,
          indicatorColor: colors.secondary,
          unselectedLabelColor: colors.outline,
          splashBorderRadius: AppRadius.radiusSm,
          tabs: tabs,
        ),
      ),
    );
  }
}

class _AppBarWidgets extends ConsumerWidget {
  const _AppBarWidgets({
    required this.textStyles,
    required this.colors,
  });

  final TextTheme textStyles;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAppInfo = ref.watch(packageInfoProvider);
    final appRouter = ref.watch(appRouterProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Leading: App logo
        ZoomIn(
          child: Card(
            margin: EdgeInsets.zero,
            color: colors.surfaceContainer,
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            child: const Image(
              height: 65,
              width: 65,
              image: AssetImage(Environment.iconPackageLogo),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Title section: App name + developer
        ZoomIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // App name
              packageAppInfo.when(
                data: (data) {
                  return Text(
                    data.appName,
                    style: textStyles.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
                error: (error, stackTrace) {
                  return Text(
                    'Error',
                    style: textStyles.titleLarge?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
                loading: () {
                  return Text(
                    '...',
                    style: textStyles.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),

              // Developer info
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.byDeveloper(Environment.userDeveloperName),
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (Environment.userDeveloperName == Environment.dashDeveloper) ...[
                    const Gap(AppSpacing.xxxs),
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
        ),

        // Actions: Settings button
        ZoomIn(
          child: CustomIconButton(
            onPressed: () => appRouter.push(AppRoutes.settings),
            icon: Hicon.categoryBold,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
