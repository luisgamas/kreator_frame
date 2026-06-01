// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';

/// Configuration for Kustom widget screen display.
///
/// Defines visual and behavioral settings for displaying KWGT or KLWP widgets.
/// Each configuration encapsulates the parameters needed to customize the grid
/// display, preview dimensions, and external linking behavior.
class KustomWidgetConfig {
  /// The file extension identifying the widget type (e.g., 'kwgt', 'klwp').
  final String widgetExtension;

  /// External URL/link to launch when tapping a widget card
  /// if the target Kustom app is not installed.
  final String externalLink;

  /// Target Kustom app package name for deep linking.
  final String targetPackage;

  /// Target editor activity to launch within the Kustom app.
  final String editorActivity;

  /// Total height of each grid cell (image area + text section + Card margins).
  /// Controls the [SliverGridDelegateWithFixedCrossAxisCount.mainAxisExtent]
  /// passed to the grid, so [CustomCardPreviews] can fill the available space.
  final double cellHeight;

  /// BoxFit setting for how preview images fit in their containers.
  final BoxFit previewFit;

  /// Whether to add padding around preview images.
  final bool addPadding;

  /// Display label for the tab bar.
  final String tabLabel;

  const KustomWidgetConfig({
    required this.widgetExtension,
    required this.externalLink,
    required this.targetPackage,
    required this.editorActivity,
    required this.cellHeight,
    required this.previewFit,
    required this.addPadding,
    required this.tabLabel,
  });

  /// Display label for the KWGT tab.
  static const String kwgtTabLabel = 'KWGT';

  /// Display label for the KLWP tab.
  static const String klwpTabLabel = 'KLWP';

  /// Configuration for KWGT widgets.
  ///
  /// KWGT stands for Kustom Widget. These are smaller Android app widgets
  /// with standard dimensions and scaleDown fitting for proper aspect ratio
  /// preservation.
  /// cellHeight = 200 (image) + 54 (text section) + 8 (Card margins) = 262dp
  static const kwgt = KustomWidgetConfig(
    widgetExtension: 'kwgt',
    externalLink: Environment.externalLinkKWGT,
    targetPackage: Environment.pkgKWGT,
    editorActivity: Environment.activityKWGT,
    cellHeight: 262,
    previewFit: BoxFit.scaleDown,
    addPadding: true,
    tabLabel: kwgtTabLabel,
  );

  /// Configuration for KLWP live wallpapers.
  ///
  /// KLWP stands for Kustom Live Wallpaper. These are fullscreen wallpapers
  /// with taller aspect ratios, using cover fitting for seamless display.
  /// cellHeight = 290 (image) + 54 (text section) + 8 (Card margins) = 352dp
  static const klwp = KustomWidgetConfig(
    widgetExtension: 'klwp',
    externalLink: Environment.externalLinkKLWP,
    targetPackage: Environment.pkgKLWP,
    editorActivity: Environment.activityKLWP,
    cellHeight: 352,
    previewFit: BoxFit.cover,
    addPadding: false,
    tabLabel: klwpTabLabel,
  );
}

/// A unified screen for displaying Kustom widgets (KWGT, KLWP, etc.).
///
/// This screen displays a masonry grid of Kustom widget previews fetched from
/// the repository. Each preview card shows the widget thumbnail, name, and
/// developer name. Tapping a card opens the corresponding Kustom app link
/// (typically Play Store) using the configured external link.
///
/// The screen is configured via [KustomWidgetConfig] which allows displaying
/// different widget types with customized preview heights, fitting behaviors,
/// and padding settings without code duplication.
///
/// Example:
/// ```dart
/// KustomWidgetsScreen(config: KustomWidgetConfig.kwgt)
/// ```
class KustomWidgetsScreen extends ConsumerWidget {
  final KustomWidgetConfig config;

  const KustomWidgetsScreen({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider);
    final widgets = ref.watch(getWidgetsProvider(config.widgetExtension));

    return widgets.when(
      data: (data) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: config.cellHeight,
          ),
          itemCount: data.length,
          padding: const EdgeInsets.all(AppSpacing.xxs),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final widget = data[index];

            return ZoomIn(
              child: FadeIn(
                child: CustomCardPreviews(
                  isUrlImage: false,
                  image: widget.widgetThumbnail,
                  topText: widget.nameWidget,
                  bottomText: widget.nameDeveloper,
                  fitPreview: config.previewFit,
                  addPadding: config.addPadding,
                  onTap: () async {
                    final installed = await repository.isKustomAppInstalled(config.targetPackage);
                    if (installed) {
                      await repository.sendWidgetToKustomApp(
                        packageName: config.targetPackage,
                        editorActivity: config.editorActivity,
                        assetPath: widget.assetPath,
                      );
                    } else {
                      await repository.launchExternalApp(config.externalLink);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      error: (_, _) => ErrorView(
        onRetry: () => ref.invalidate(getWidgetsProvider(config.widgetExtension)),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(strokeCap: StrokeCap.round),
      ),
    );
  }
}
