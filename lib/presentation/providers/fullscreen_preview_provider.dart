import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullscreenPreview extends Notifier<bool> {
  @override
  bool build() => true;

  void showInFullscreen() => state = !state;
}

final fullscreenPreviewProvider = NotifierProvider<FullscreenPreview, bool>(
  FullscreenPreview.new,
);
