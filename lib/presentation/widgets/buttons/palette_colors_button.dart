import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';

class PaletteColorsButton extends ConsumerWidget {
  const PaletteColorsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPaletteColors = ref.watch(showPaletteColorsProvider);

    return IconButton(
      onPressed: () => ref.read(showPaletteColorsProvider.notifier).toggle(),
      icon: Icon(
        showPaletteColors ? Hicon.paletteBold : Hicon.paletteOutline,
        color: Colors.white,
      ),
    );
  }
}
