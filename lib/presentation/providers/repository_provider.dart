// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/infrastructure/infrastructure.dart';
import 'package:kreator_frame/shared/services/services.dart';

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

/// Provider for the application's DataSource.
/// Injects the Dio client via [dioProvider] and the cancel token holder via
/// [downloadCancelTokenHolderProvider] following Riverpod DI patterns.
final dataSourceProvider = Provider<DataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final downloadCancelTokenHolder =
      ref.watch(downloadCancelTokenHolderProvider);
  return DataSourceImpl(
    dio: dio,
    downloadCancelTokenHolder: downloadCancelTokenHolder,
  );
});

/// Provider for the application's Repository.
/// Receives the DataSource through dependency injection.
/// Follows the Clean Architecture pattern: DataSource → Repository → UI.
final repositoryProvider = Provider<Repository>((ref) {
  final dataSource = ref.watch(dataSourceProvider);
  return RepositoryImpl(dataSource);
});
