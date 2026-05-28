import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ColorPaletteExtractor {
  ColorPaletteExtractor._();

  static const int _defaultMaxColors = 15;
  static const int _defaultResize = 200;
  static const int _defaultBinSize = 24;
  static const int _minAlphaThreshold = 128;
  static const int _rgbaPixelSize = 4;
  static const int _fullAlpha = 255;

  static Future<List<Color>> extractColors({
    required ImageProvider imageProvider,
    int maxColors = _defaultMaxColors,
    int resize = _defaultResize,
    int binSize = _defaultBinSize,
  }) async {
    _validateParameters(maxColors, resize, binSize);

    try {
      final image = await _loadImage(imageProvider);
      final resizedImage = await _resizeImage(image, resize);
      final pixelData = await _extractPixelData(resizedImage);

      final colorHistogram = _buildColorHistogram(pixelData, binSize);
      return _getSortedColors(colorHistogram, maxColors);
    } catch (e) {
      throw Exception('Failed to extract colors: $e');
    }
  }

  static void _validateParameters(int maxColors, int resize, int binSize) {
    if (maxColors <= 0) {
      throw ArgumentError.value(maxColors, 'maxColors', 'Must be positive');
    }
    if (resize <= 0) {
      throw ArgumentError.value(resize, 'resize', 'Must be positive');
    }
    if (binSize <= 0 || binSize > 255) {
      throw ArgumentError.value(binSize, 'binSize', 'Must be between 1 and 255');
    }
  }

  static Future<ui.Image> _loadImage(ImageProvider provider) async {
    final completer = Completer<ui.Image>();
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        completer.completeError(error, stackTrace);
      },
    );

    final stream = provider.resolve(const ImageConfiguration());
    stream.addListener(listener);

    try {
      final image = await completer.future;
      return image;
    } finally {
      stream.removeListener(listener);
    }
  }

  static Future<ui.Image> _resizeImage(ui.Image originalImage, int targetSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final scale = math.min(
      targetSize / originalImage.width,
      targetSize / originalImage.height,
    );

    final scaledWidth = (originalImage.width * scale).round();
    final scaledHeight = (originalImage.height * scale).round();

    final offsetX = (targetSize - scaledWidth) / 2;
    final offsetY = (targetSize - scaledHeight) / 2;

    final srcRect = Rect.fromLTWH(
      0, 0,
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );

    final dstRect = Rect.fromLTWH(
      offsetX, offsetY,
      scaledWidth.toDouble(),
      scaledHeight.toDouble(),
    );

    canvas.drawImageRect(originalImage, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    return picture.toImage(targetSize, targetSize);
  }

  static Future<Uint8List> _extractPixelData(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception('Failed to extract pixel data from image');
    }
    return byteData.buffer.asUint8List();
  }

  static Map<int, int> _buildColorHistogram(Uint8List pixels, int binSize) {
    final colorHistogram = <int, int>{};

    for (int i = 0; i < pixels.length; i += _rgbaPixelSize) {
      final alpha = pixels[i + 3];

      if (alpha < _minAlphaThreshold) continue;

      final red = _binColor(pixels[i], binSize);
      final green = _binColor(pixels[i + 1], binSize);
      final blue = _binColor(pixels[i + 2], binSize);

      final colorValue = _createColorValue(red, green, blue);

      colorHistogram[colorValue] = (colorHistogram[colorValue] ?? 0) + 1;
    }

    return colorHistogram;
  }

  static int _binColor(int value, int binSize) {
    return (value ~/ binSize) * binSize;
  }

  static int _createColorValue(int red, int green, int blue) {
    return (_fullAlpha << 24) | (red << 16) | (green << 8) | blue;
  }

  static List<Color> _getSortedColors(Map<int, int> histogram, int maxColors) {
    if (histogram.isEmpty) return <Color>[];

    final sortedEntries = histogram.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(maxColors)
        .map((entry) => Color(entry.key))
        .toList();
  }
}
