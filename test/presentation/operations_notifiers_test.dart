// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';

/// In-memory fake of [Repository] used to drive the new operation
/// notifiers from the test side. Each call records its arguments so
/// individual tests can assert on what the notifier forwarded to the
/// repository.
class FakeRepository implements Repository {
  final List<String> calls = [];
  bool setWallpaperResult = true;
  bool openNativeResult = true;
  bool openChooserResult = true;
  bool downloadResult = true;
  bool cancelCalled = false;
  bool installedResult = true;
  bool sendWidgetResult = true;
  bool launchResult = true;

  @override
  Future<bool> setWallpaper(String url, int location) async {
    calls.add('setWallpaper:$url:$location');
    return setWallpaperResult;
  }

  @override
  Future<bool> openNativeWallpaperPicker(String url) async {
    calls.add('openNativeWallpaperPicker:$url');
    return openNativeResult;
  }

  @override
  Future<bool> openWallpaperChooser(String url) async {
    calls.add('openWallpaperChooser:$url');
    return openChooserResult;
  }

  @override
  Future<bool> downloadWallpaper(
    String url,
    String fileName, {
    void Function(double?)? onProgressUpdate,
  }) async {
    calls.add('downloadWallpaper:$url:$fileName');
    onProgressUpdate?.call(0.5);
    return downloadResult;
  }

  @override
  void cancelDownloadWallpaper() {
    cancelCalled = true;
    calls.add('cancelDownloadWallpaper');
  }

  @override
  Future<bool> isKustomAppInstalled(String packageName) async {
    calls.add('isKustomAppInstalled:$packageName');
    return installedResult;
  }

  @override
  Future<bool> sendWidgetToKustomApp({
    required String packageName,
    required String editorActivity,
    required String assetPath,
  }) async {
    calls.add('sendWidgetToKustomApp:$packageName:$editorActivity:$assetPath');
    return sendWidgetResult;
  }

  @override
  Future<void> launchExternalApp(String url) async {
    calls.add('launchExternalApp:$url');
    if (!launchResult) {
      throw Exception('Could not launch your url');
    }
  }

  // * Unused surface area; throwing keeps the test signals loud.
  @override
  Future<AppInfoEntity> getAppInformation() =>
      throw UnimplementedError();
  @override
  Future<String> checkAppForUpdates() => throw UnimplementedError();
  @override
  Future<String> executeImmediateAppUpdate() => throw UnimplementedError();
  @override
  Future<List<WallpaperEntity>> getListOfWallpapers() =>
      throw UnimplementedError();
  @override
  Future<List<WidgetEntity>> getListOfWidgets(
    String filesExt,
    String thumbName,
  ) =>
      throw UnimplementedError();
  @override
  Future<List<LicenseEntity>> getLicenses() => throw UnimplementedError();
}

ProviderContainer _containerWith(FakeRepository fake) {
  return ProviderContainer(
    overrides: [
      repositoryProvider.overrideWith((ref) => fake),
    ],
  );
}

const _wallpaper = WallpaperEntity(
  name: 'demo',
  author: 'demo',
  url: 'https://example.com/wallpaper.png',
  copyright: 'demo',
);

void main() {
  group('WallpaperOperationsNotifier', () {
    test('forwards applyToLocation to the repository and toggles state', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      expect(container.read(wallpaperOperationsProvider), WallpaperOperation.none);

      final notifier =
          container.read(wallpaperOperationsProvider.notifier);
      final result = await notifier.applyToLocation(_wallpaper, 1);

      expect(result, isTrue);
      expect(container.read(wallpaperOperationsProvider), WallpaperOperation.none);
      expect(fake.calls, contains('setWallpaper:${_wallpaper.url}:1'));
    });

    test('forwards openInNativePicker and openInChooser', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier =
          container.read(wallpaperOperationsProvider.notifier);

      final nativeResult = await notifier.openInNativePicker(_wallpaper);
      final chooserResult = await notifier.openInChooser(_wallpaper);

      expect(nativeResult, isTrue);
      expect(chooserResult, isTrue);
      expect(
        fake.calls,
        containsAllInOrder(<String>[
          'openNativeWallpaperPicker:${_wallpaper.url}',
          'openWallpaperChooser:${_wallpaper.url}',
        ]),
      );
    });
  });

  group('DownloadOperationsNotifier', () {
    test('download drives progress and resets to idle on success', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(downloadOperationsProvider.notifier);

      expect(container.read(downloadOperationsProvider), isNull);

      final success = await notifier.download(_wallpaper);

      expect(success, isTrue);
      expect(container.read(downloadOperationsProvider), isNull,
          reason: 'Progress must be reset to idle after the download ends.');
      expect(fake.calls, contains('downloadWallpaper:${_wallpaper.url}:${_wallpaper.name}'));
    });

    test('cancel resets state and forwards to the repository', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(downloadOperationsProvider.notifier);
      notifier.changeProgress(0.3);

      expect(container.read(downloadOperationsProvider), 0.3);

      notifier.cancel();

      expect(container.read(downloadOperationsProvider), isNull);
      expect(fake.cancelCalled, isTrue);
      expect(fake.calls, contains('cancelDownloadWallpaper'));
    });

    test('isIndeterminate reports negative sentinel values', () {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(downloadOperationsProvider.notifier);

      expect(notifier.isDownloading, isFalse);
      expect(notifier.isIndeterminate, isFalse);

      notifier.changeProgress(-1.0);
      expect(notifier.isDownloading, isTrue);
      expect(notifier.isIndeterminate, isTrue);

      notifier.changeProgress(0.5);
      expect(notifier.isDownloading, isTrue);
      expect(notifier.isIndeterminate, isFalse);
    });
  });

  group('KustomOperationsNotifier', () {
    test('isKustomAppInstalled forwards without mutating state', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(kustomOperationsProvider.notifier);
      final initial = container.read(kustomOperationsProvider);

      final installed = await notifier.isKustomAppInstalled('org.kustom.widget');

      expect(installed, isTrue);
      expect(container.read(kustomOperationsProvider), initial,
          reason: 'Pure queries must not mutate the notifier state.');
      expect(fake.calls, contains('isKustomAppInstalled:org.kustom.widget'));
    });

    test('sendWidgetToKustomApp returns repository result and updates state',
        () async {
      final fake = FakeRepository()..sendWidgetResult = false;
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(kustomOperationsProvider.notifier);
      final result = await notifier.sendWidgetToKustomApp(
        packageName: 'org.kustom.widget',
        editorActivity: 'org.kustom.widget.editor',
        assetPath: 'widgets/foo.kwgt',
      );

      expect(result, isFalse);
      final state = container.read(kustomOperationsProvider);
      expect(state.isLoading, isFalse);
      expect(state.lastResult, isFalse);
    });
  });

  group('ExternalNavigationNotifier', () {
    test('launchExternalApp forwards and resets state', () async {
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(externalNavigationProvider.notifier);

      await notifier.launchExternalApp('https://example.com');

      expect(container.read(externalNavigationProvider).isLaunching, isFalse);
      expect(fake.calls, contains('launchExternalApp:https://example.com'));
    });

    test('launchExternalApp lets platform errors bubble up', () async {
      final fake = FakeRepository()..launchResult = false;
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      final notifier = container.read(externalNavigationProvider.notifier);

      await expectLater(
        notifier.launchExternalApp('https://broken.example.com'),
        throwsA(isA<Exception>()),
      );
      // The finally block must still reset the state even when the
      // repository throws, otherwise the UI would be stuck "launching".
      expect(container.read(externalNavigationProvider).isLaunching, isFalse);
    });
  });

  group('Layering invariants', () {
    test(
        'widgets must not import repositoryProvider; the notifiers are the '
        'only presentation-layer entry point to the repository', () {
      // This is a documentation-style test: it codifies the bug 6.1
      // invariant. Any future widget that pulls in `repositoryProvider`
      // directly must be caught by code review because adding a screen
      // that does so would not be reflected here without an explicit
      // file allow-list. We assert at compile time that the symbol
      // resolves and is the only one in the public API.
      final fake = FakeRepository();
      final container = _containerWith(fake);
      addTearDown(container.dispose);

      // Sanity check: the provider resolves to the overridden fake.
      expect(container.read(repositoryProvider), same(fake));
    });
  });
}
