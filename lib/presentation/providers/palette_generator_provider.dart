import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kreator_frame/shared/utils/utils.dart';

class ShowPaletteColors extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggle() => state = !state;

  void reset() => state = false;
}

final showPaletteColorsProvider = NotifierProvider<ShowPaletteColors, bool>(
  ShowPaletteColors.new,
);

final generatePaletteProvider = FutureProvider.family<List<Color>, String>((ref, imageUrl) async {
  final paletteColors = await ColorPaletteExtractor.extractColors(
    imageProvider: CachedNetworkImageProvider(imageUrl),
  );
  return paletteColors;
});
