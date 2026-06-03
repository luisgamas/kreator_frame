import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';

class PaletteColorsGrid extends ConsumerWidget {
  final WallpaperEntity wallpaperEntity;

  const PaletteColorsGrid({
    super.key,
    required this.wallpaperEntity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletteColors = ref.watch(generatePaletteProvider(wallpaperEntity.url));

    return paletteColors.when(
      data: (paletteColors) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: paletteColors.map((color) {
            return GestureDetector(
              onTap: () async {
                final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                await Clipboard.setData(ClipboardData(text: hex));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        backgroundColor: color,
                        showCloseIcon: true,
                        closeIconColor: Colors.white,
                        content: Text(
                          hex,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                }
              },
              child: Container(
                width: 30,
                height: 65,
                color: color,
              ),
            );
          }).toList(),
        ),
      ),
      error: (_, _) => const SizedBox(),
      loading: () => const Center(
        child: SizedBox(
          height: 60,
          child: Center(
            child: CircularProgressIndicator(
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}
