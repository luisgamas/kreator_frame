// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for the Dio HTTP client.
///
/// Returns a shared Dio instance configured with:
/// - [connectTimeout]: 10s for establishing a connection
/// - [receiveTimeout]: 30s for receiving the full response
/// - [validateStatus]: only 200-299 are considered successful; anything else throws DioException
///
/// This provider is injected into [DataSourceImpl] via [ref.watch()],
/// following the injection chain: Service Provider → DataSource → Repository → Notifier → UI.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
      followRedirects: true,
    ),
  );

  ref.onDispose(() => dio.close());

  return dio;
});
