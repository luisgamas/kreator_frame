// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';
import 'package:kreator_frame/shared/utils/utils.dart';

class WallpaperPreviewScreen extends ConsumerStatefulWidget {
  final WallpaperEntity wallpaperEntity;

  const WallpaperPreviewScreen({
    super.key,
    required this.wallpaperEntity
  });

  @override
  ConsumerState<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends ConsumerState<WallpaperPreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showPaletteColorsProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         _HeroImagePreview(wallpaperEntity: widget.wallpaperEntity),
          
          const SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.70, 1.0],
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ),

          _BottomContentData(wallpaperEntity: widget.wallpaperEntity),
        ],
      ),
    );
  }
}

// ##
class _HeroImagePreview extends StatelessWidget {
  final WallpaperEntity wallpaperEntity;

  const _HeroImagePreview({
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Hero(
      tag: wallpaperEntity.url,
      child: Image(
        image: CachedNetworkImageProvider(wallpaperEntity.url),
        width: size.width,
        height: size.height,
        fit: BoxFit.fitHeight,
        filterQuality: FilterQuality.high,
        loadingBuilder: (context, child, loadingProgress) {
          return loadingProgress == null
          ? child
          : const Center(
            child: CircularProgressIndicator(strokeCap: StrokeCap.round),
          );
        },
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Hicon.dangerTriangleOutline
          ),
        ),
      ),
    );
  }
}

// ##
class _BottomContentData extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;

  const _BottomContentData({
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;
    final showPaletteColors = ref.watch(showPaletteColorsProvider);
    
    return Positioned(
      bottom: AppSpacing.lg,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          if (showPaletteColors)
            FadeInUp(
              child: PaletteColorsGrid(wallpaperEntity: wallpaperEntity),
            ),

          const Gap(10),

          FadeIn(
            delay: AppDurations.slow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallpaperEntity.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.titleLarge?.copyWith(
                    color: Colors.white
                  ),
                ),
                Text(
                  wallpaperEntity.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const _NoFunctionButton(icon: Hicon.heart2Outline),
                    const Gap(AppSpacing.xxxs),
                    const PaletteColorsButton(),
                    const Gap(AppSpacing.xxxs),
                    WallpaperDownloadButton(wallpaperEntity: wallpaperEntity),
                    const Spacer(),
                    _ApplyWallpaperButton(wallpaperEntity: wallpaperEntity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ##
class _NoFunctionButton extends StatelessWidget {
  final IconData icon;

  const _NoFunctionButton({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomIconButton(
      onPressed: () => SnackbarHelpers.showError(
        context: context,
        message: AppLocalizations.of(context)!.noFunction,
        color: colors
      ),
      icon: icon,
      iconColor: Colors.white,
    );
  }
}

// ##
class _ApplyWallpaperButton extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;

  const _ApplyWallpaperButton({
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setWallpaperState = ref.watch(setWallpaperProvider);
    final colors = Theme.of(context).colorScheme;

    return CustomIconButton.filled(
      onPressed: setWallpaperState
        ? null
        : () => _showBottomCard(
          context: context,
          ref: ref,
          colors: colors
        ),
      icon: Hicon.send1Outline,
      iconColor: Colors.black,
      color: Colors.white,
      isLoading: setWallpaperState,
      buttonSize: 56,
    );
  }

  void _showBottomCard({
    required BuildContext context,
    required WidgetRef ref,
    required ColorScheme colors,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (context) => _BottomCardContent(
        wallpaperEntity: wallpaperEntity,
        colors: colors,
      ),
    );
  }
}

// ##
class _BottomCardContent extends StatelessWidget {
  final WallpaperEntity wallpaperEntity;
  final ColorScheme colors;

  const _BottomCardContent({
    required this.wallpaperEntity,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.bottomWallSelectorTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.xs),
          Text(
            AppLocalizations.of(context)!.bottomWallSelectorSubTitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _LocationButton(
                  icon: Hicon.home3Outline,
                  label: AppLocalizations.of(context)!.bottomWallSelectorHS,
                  wallpaperEntity: wallpaperEntity,
                  screenLocation: Environment.wallpaperHomeScreen,
                ),
              ),
              Expanded(
                child: _LocationButton(
                  icon: Hicon.lock2Outline,
                  label: AppLocalizations.of(context)!.bottomWallSelectorLS,
                  wallpaperEntity: wallpaperEntity,
                  screenLocation: Environment.wallpaperLockScreen,
                ),
              ),
              Expanded(
                child: _LocationButton(
                  icon: Hicon.display1Outline,
                  label: AppLocalizations.of(context)!.bottomWallSelectorBS,
                  wallpaperEntity: wallpaperEntity,
                  screenLocation: Environment.wallpaperBothScreens,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xxs),
          const Divider(),
          _NativePickerButton(wallpaperEntity: wallpaperEntity),
          const Gap(AppSpacing.xs),
          _WallpaperChooserButton(wallpaperEntity: wallpaperEntity),
          const Gap(AppSpacing.md),
        ],
      ),
    );
  }
}

// ##
class _LocationButton extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;
  final IconData icon;
  final String label;
  final int screenLocation;

  const _LocationButton({
    required this.wallpaperEntity,
    required this.icon,
    required this.label,
    required this.screenLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setWallpaperState = ref.watch(setWallpaperProvider);
    final textStyles = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconButton.tonal(
          buttonSize: 56,
          onPressed: setWallpaperState ? null : () => _applyWallpaper(context, ref),
          icon: icon,
          isLoading: setWallpaperState,
        ),
        const Gap(AppSpacing.xxxs),
        Text(
          label,
          style: textStyles.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _applyWallpaper(BuildContext context, WidgetRef ref) async {
    final repository = ref.watch(repositoryProvider);
    final appRouter = ref.watch(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    ref.read(setWallpaperProvider.notifier).changeState();

    final result = await repository.setWallpaper(wallpaperEntity.url, screenLocation);

    if (context.mounted) {
      ref.read(setWallpaperProvider.notifier).changeState();
      if (result) {
        SnackbarHelpers.showSuccess(
          context: context,
          message: AppLocalizations.of(context)!.appliedOk,
          color: colors,
        );
      } else {
        SnackbarHelpers.showError(
          context: context,
          message: AppLocalizations.of(context)!.appliedError,
          color: colors,
        );
      }
      appRouter.pop();
    }
  }
}

// ##
class _WallpaperChooserButton extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;

  const _WallpaperChooserButton({
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setWallpaperState = ref.watch(setWallpaperProvider);

    return CustomButton.text(
      width: double.infinity,
      borderRadius: AppRadius.radiusLg,
      isLoading: setWallpaperState,
      text: AppLocalizations.of(context)!.bottomWallSelectorChooser,
      onPressed: () => _openChooser(context, ref),
    );
  }

  void _openChooser(BuildContext context, WidgetRef ref) async {
    final repository = ref.watch(repositoryProvider);
    final appRouter = ref.watch(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    ref.read(setWallpaperProvider.notifier).changeState();

    final result = await repository.openWallpaperChooser(wallpaperEntity.url);

    if (context.mounted) {
      ref.read(setWallpaperProvider.notifier).changeState();
      if (!result) {
        SnackbarHelpers.showError(
          context: context,
          message: AppLocalizations.of(context)!.appliedError,
          color: colors,
        );
      }
      appRouter.pop();
    }
  }
}

// ##
class _NativePickerButton extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;

  const _NativePickerButton({
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setWallpaperState = ref.watch(setWallpaperProvider);

    return CustomButton.tonal(
      width: double.infinity,
      borderRadius: AppRadius.radiusLg,
      isLoading: setWallpaperState,
      text: AppLocalizations.of(context)!.bottomWallSelectorNative,
      onPressed: () => _openNativePicker(context, ref),
    );
  }

  void _openNativePicker(BuildContext context, WidgetRef ref) async {
    final repository = ref.watch(repositoryProvider);
    final appRouter = ref.watch(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    ref.read(setWallpaperProvider.notifier).changeState();

    final result = await repository.openNativeWallpaperPicker(wallpaperEntity.url);

    if (context.mounted) {
      ref.read(setWallpaperProvider.notifier).changeState();
      if (!result) {
        SnackbarHelpers.showError(
          context: context,
          message: AppLocalizations.of(context)!.appliedError,
          color: colors,
        );
      }
      appRouter.pop();
    }
  }
}
