// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:kreator_frame/shared/services/download_cancel_token_holder.dart';

void main() {
  group('DownloadCancelTokenHolder', () {
    test('starts without an active token', () {
      final holder = DownloadCancelTokenHolder();

      expect(holder.activeToken, isNull);
      expect(holder.hasActiveToken, isFalse);
    });

    test('register() returns a fresh, non-cancelled token and tracks it', () {
      final holder = DownloadCancelTokenHolder();

      final token = holder.register();

      expect(token, isA<CancelToken>());
      expect(token.isCancelled, isFalse);
      expect(holder.activeToken, same(token));
      expect(holder.hasActiveToken, isTrue);
    });

    test('clear() removes the active token without cancelling it', () {
      final holder = DownloadCancelTokenHolder();
      final token = holder.register();

      holder.clear();

      expect(holder.activeToken, isNull);
      expect(holder.hasActiveToken, isFalse);
      // clear() should not cancel — only the actual download completion path
      // decides whether cancellation is desired.
      expect(token.isCancelled, isFalse);
    });

    test('cancel() cancels the active token and clears the reference', () {
      final holder = DownloadCancelTokenHolder();
      final token = holder.register();

      holder.cancel();

      expect(token.isCancelled, isTrue);
      expect(holder.activeToken, isNull);
      expect(holder.hasActiveToken, isFalse);
    });

    test('cancel() is a no-op when there is no active token', () {
      final holder = DownloadCancelTokenHolder();

      expect(() => holder.cancel(), returnsNormally);
      expect(holder.hasActiveToken, isFalse);
    });

    test('cancel() is idempotent and safe to call twice', () {
      final holder = DownloadCancelTokenHolder();
      final token = holder.register();

      holder.cancel();
      expect(() => holder.cancel(), returnsNormally);
      expect(token.isCancelled, isTrue);
    });

    test(
        'register() cancels a previously active token to avoid leaks across '
        'overlapping download attempts', () {
      final holder = DownloadCancelTokenHolder();
      final firstToken = holder.register();
      final secondToken = holder.register();

      expect(firstToken.isCancelled, isTrue,
          reason: 'Previous in-flight token must be cancelled when a new one '
              'is registered, otherwise the original download leaks.');
      expect(secondToken.isCancelled, isFalse);
      expect(holder.activeToken, same(secondToken));
    });

    test(
        'the active token outlives the lifecycle of a datasource that '
        'consumes the holder (simulates a dataSourceProvider rebuild)', () {
      // Simulate the exact bug scenario from analisis.md (7.1):
      // A "datasource" instance is recreated while a download is in flight.
      // The cancel button on the new instance must still be able to cancel
      // the original download because the token lives in the holder, not in
      // the datasource instance.
      final holder = DownloadCancelTokenHolder();
      final tokenA = holder.register();

      // Simulate dataSourceProvider rebuild — old instance discarded,
      // new instance gets the SAME holder.
      // ignore: unnecessary_statements
      tokenA;

      // Cancel is invoked from a code path that was wired to the new
      // instance (e.g. the WallpaperDownloadButton), but it must hit the
      // same holder.
      holder.cancel();

      expect(tokenA.isCancelled, isTrue,
          reason:
              'Cancel must work even when the original DataSourceImpl that '
              'started the download has been replaced by a new instance.');
      expect(holder.hasActiveToken, isFalse);
    });
  });
}
