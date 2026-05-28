// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:kreator_frame/domain/domain.dart';
import 'package:kreator_frame/infrastructure/infrastructure.dart';
import 'package:kreator_frame/shared/services/services.dart';

/// Provider for the application's DataSource.
/// Injects the Dio client via [dioProvider] following Riverpod DI patterns.
final dataSourceProvider = Provider<DataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DataSourceImpl(dio: dio);
});

/// Provider for the application's Repository.
/// Receives the DataSource through dependency injection.
/// Follows the Clean Architecture pattern: DataSource → Repository → UI.
final repositoryProvider = Provider<Repository>((ref) {
  final dataSource = ref.watch(dataSourceProvider);
  return RepositoryImpl(dataSource);
});
