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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          _HeroImagePreview(wallpaperEntity: widget.wallpaperEntity),

          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: size.height * 0.20,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.9],
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),

          // Fullscreen toggle
          GestureDetector(
            onTap: ref.read(fullscreenPreviewProvider.notifier).showInFullscreen,
          ),

          _BottomContentData(wallpaperEntity: widget.wallpaperEntity),
        ],
      ),
    );
  }
}

// ##
class _HeroImagePreview extends StatefulWidget {
  final WallpaperEntity wallpaperEntity;

  const _HeroImagePreview({
    required this.wallpaperEntity,
  });

  @override
  State<_HeroImagePreview> createState() => _HeroImagePreviewState();
}

class _HeroImagePreviewState extends State<_HeroImagePreview> {
  bool _isHighResLoaded = false;
  bool _hasStartedLoading = false;

  CachedNetworkImageProvider? _highResProvider;
  Animation<double>? _routeAnimation;
  AnimationStatusListener? _statusListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupRouteAnimationListener();
  }

  /// Sets up a listener on the route entry animation to defer loading the
  /// heavy high-resolution image until after the animation finishes.
  void _setupRouteAnimationListener() {
    if (_hasStartedLoading) return;

    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (animation == null) {
      _startLoadingHighRes();
      return;
    }

    _routeAnimation = animation;
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        _startLoadingHighRes();
        _cleanupRouteListener();
      }
    };
    animation.addStatusListener(_statusListener!);

    // If the animation is already completed (e.g. returning to this screen), start immediately.
    if (animation.isCompleted) {
      _startLoadingHighRes();
      _cleanupRouteListener();
    }
  }

  void _cleanupRouteListener() {
    if (_routeAnimation != null && _statusListener != null) {
      _routeAnimation!.removeStatusListener(_statusListener!);
      _routeAnimation = null;
      _statusListener = null;
    }
  }

  /// Begins loading and decoding the full high-resolution image in the background.
  void _startLoadingHighRes() {
    if (!mounted || _hasStartedLoading) return;
    _hasStartedLoading = true;

    final url = widget.wallpaperEntity.url;
    final provider = CachedNetworkImageProvider(url);
    _highResProvider = provider;

    precacheImage(provider, context).then((_) {
      if (mounted) {
        setState(() {
          _isHighResLoaded = true;
        });
      }
    }).catchError((error) {
      debugPrint('Error pre-caching high-res wallpaper: $error');
    });
  }

  @override
  void dispose() {
    _cleanupRouteListener();
    // Evict the heavy full-resolution image from Flutter's memory cache
    // when disposing the preview screen to prevent memory leaks and free up RAM.
    if (_highResProvider != null) {
      _highResProvider!.evict().then((bool success) {
        debugPrint('High-res wallpaper evicted from cache: $success');
      }).catchError((error) {
        debugPrint('Error evicting high-res wallpaper: $error');
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Lightweight low-resolution preview image (decoded at smaller size)
    final lowResImage = CachedNetworkImage(
      imageUrl: widget.wallpaperEntity.url,
      width: size.width,
      height: size.height,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
      memCacheWidth: (size.width * 1.5).round(),
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(strokeCap: StrokeCap.round),
      ),
      errorWidget: (_, _, _) => const Center(
        child: Icon(
          Hicon.dangerTriangleOutline,
        ),
      ),
    );

    // Full high-resolution image widget
    Widget highResImage;
    if (_highResProvider != null) {
      highResImage = Image(
        image: _highResProvider!,
        width: size.width,
        height: size.height,
        fit: BoxFit.fitHeight,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    } else {
      highResImage = const SizedBox.shrink();
    }

    return Hero(
      tag: widget.wallpaperEntity.url,
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        constrained: false,
        child: Stack(
          children: [
            // Always render low-resolution image as the base/placeholder
            lowResImage,

            // Smoothly cross-fade to the high-resolution image once loaded
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isHighResLoaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
                child: highResImage,
              ),
            ),
          ],
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
    final showContent = ref.watch(fullscreenPreviewProvider);

    return Positioned(
      bottom: AppSpacing.lg,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          FadeInUp(
            animate: showContent ? showPaletteColors : false,
            child: PaletteColorsGrid(wallpaperEntity: wallpaperEntity),
          ),

          const Gap(10),

          FadeInUp(
            animate: showContent,
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
    final isOperationRunning = ref.watch(wallpaperOperationsProvider);
    final colors = Theme.of(context).colorScheme;

    return CustomIconButton.filled(
      onPressed: isOperationRunning
        ? null
        : () => _showBottomCard(
          context: context,
          ref: ref,
          colors: colors
        ),
      icon: Hicon.send1Outline,
      iconColor: Colors.black,
      color: Colors.white,
      isLoading: isOperationRunning,
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
                  screenLocation: WallpaperConstants.wallpaperHomeScreen,
                ),
              ),
              Expanded(
                child: _LocationButton(
                  icon: Hicon.lock2Outline,
                  label: AppLocalizations.of(context)!.bottomWallSelectorLS,
                  wallpaperEntity: wallpaperEntity,
                  screenLocation: WallpaperConstants.wallpaperLockScreen,
                ),
              ),
              Expanded(
                child: _LocationButton(
                  icon: Hicon.display1Outline,
                  label: AppLocalizations.of(context)!.bottomWallSelectorBS,
                  wallpaperEntity: wallpaperEntity,
                  screenLocation: WallpaperConstants.wallpaperBothScreens,
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
    final isOperationRunning = ref.watch(wallpaperOperationsProvider);
    final textStyles = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconButton.tonal(
          buttonSize: 56,
          onPressed: isOperationRunning
            ? null
            : () => _applyWallpaper(context, ref),
          icon: icon,
          isLoading: isOperationRunning,
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

  Future<void> _applyWallpaper(BuildContext context, WidgetRef ref) async {
    final appRouter = ref.read(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    final result = await ref
        .read(wallpaperOperationsProvider.notifier)
        .applyToLocation(wallpaperEntity, screenLocation);

    if (context.mounted) {
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
    final isOperationRunning = ref.watch(wallpaperOperationsProvider);

    return CustomButton.text(
      width: double.infinity,
      borderRadius: AppRadius.radiusLg,
      isLoading: isOperationRunning,
      text: AppLocalizations.of(context)!.bottomWallSelectorChooser,
      onPressed: () => _openChooser(context, ref),
    );
  }

  Future<void> _openChooser(BuildContext context, WidgetRef ref) async {
    final appRouter = ref.read(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    final result = await ref
        .read(wallpaperOperationsProvider.notifier)
        .openInChooser(wallpaperEntity);

    if (context.mounted) {
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
    final isOperationRunning = ref.watch(wallpaperOperationsProvider);

    return CustomButton.tonal(
      width: double.infinity,
      borderRadius: AppRadius.radiusLg,
      isLoading: isOperationRunning,
      text: AppLocalizations.of(context)!.bottomWallSelectorNative,
      onPressed: () => _openNativePicker(context, ref),
    );
  }

  Future<void> _openNativePicker(BuildContext context, WidgetRef ref) async {
    final appRouter = ref.read(appRouterProvider);
    final colors = Theme.of(context).colorScheme;

    final result = await ref
        .read(wallpaperOperationsProvider.notifier)
        .openInNativePicker(wallpaperEntity);

    if (context.mounted) {
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
