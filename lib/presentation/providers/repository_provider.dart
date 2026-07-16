// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show debugPrint;

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/infrastructure/infrastructure.dart';
import 'package:kreator_frame/shared/services/services.dart';

/// Provider for the key-value storage service.
///
/// Exposes [KeyValueStorageServicesImpl] as the abstract [KeyValueStorageServices]
/// contract so consumers depend on the interface, not the concrete class.
/// The singleton semantics of SharedPreferences are already handled inside
/// [KeyValueStorageServicesImpl] via its static cache; this provider simply
/// makes the service injectable and mockable for testing.
final keyValueStorageProvider = Provider<KeyValueStorageServices>((ref) {
  return KeyValueStorageServicesImpl();
});

/// Provider for the active wallpaper download cancel token holder.
///
/// The holder is intentionally exposed as a singleton-style provider (not
/// `autoDispose`) so the in-flight cancel token survives the recreation of
/// [dataSourceProvider]. If the holder were created inside `dataSourceProvider`
/// it would be rebuilt whenever any of its watched dependencies change and
/// the user would lose the ability to cancel an active download.
final downloadCancelTokenHolderProvider =
    Provider<DownloadCancelTokenHolder>((ref) {
  final holder = DownloadCancelTokenHolder();
  ref.onDispose(holder.clear);
  return holder;
});

/// Provider for the InAppUpdateManager instance.
///
/// Keeps a single manager alive for the app's lifetime via `ref.keepAlive()`
/// and logs cleanup on disposal. The manager is created once and reused
/// across check and execute calls to respect the Play Core API guidelines.
final inAppUpdateManagerProvider = Provider<InAppUpdateManager>((ref) {
  final manager = InAppUpdateManager();
  ref.onDispose(() {
    debugPrint('InAppUpdateManager disposed');
  });
  return manager;
});

/// Provider for the application's DataSource.
/// Injects the Dio client via [dioProvider], the cancel token holder via
/// [downloadCancelTokenHolderProvider], and the in-app update manager via
/// [inAppUpdateManagerProvider] following Riverpod DI patterns.
final dataSourceProvider = Provider<DataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final downloadCancelTokenHolder =
      ref.watch(downloadCancelTokenHolderProvider);
  final inAppUpdateManager = ref.watch(inAppUpdateManagerProvider);
  return DataSourceImpl(
    dio: dio,
    downloadCancelTokenHolder: downloadCancelTokenHolder,
    inAppUpdateManager: inAppUpdateManager,
  );
});

/// Provider for the application's Repository.
/// Receives the DataSource through dependency injection.
/// Follows the Clean Architecture pattern: DataSource → Repository → UI.
final repositoryProvider = Provider<Repository>((ref) {
  final dataSource = ref.watch(dataSourceProvider);
  return RepositoryImpl(dataSource);
});
