// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'key_value_storage_service.dart';

/// Implementation of KeyValueStorageServices using SharedPreferences.
///
/// Provides persistent storage for primitive types (int, String, bool).
/// Uses SharedPreferences as the underlying storage mechanism.
/// Caches the SharedPreferences instance after first load for performance.
class KeyValueStorageServicesImpl extends KeyValueStorageServices {
  static SharedPreferences? _cachedPrefs;

  /// Gets the SharedPreferences instance, using cache after first load.
  Future<SharedPreferences> getSharedPreferences() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }


  @override
  Future<T?> getKeyValue<T>(String key) async {
    final preferences = await getSharedPreferences();

    switch(T) {
      case const (int):
        return preferences.getInt(key) as T?;
      case const (String):
        return preferences.getString(key) as T?;
      case const (bool):
        return preferences.getBool(key) as T?;
      default:
        throw UnimplementedError('GET not implemented for type ${ T.runtimeType }');
    }
  }

  @override
  Future<bool> removeKey(String key) async {
    final preferences = await getSharedPreferences();
    return await preferences.remove(key);
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    
    final preferences = await getSharedPreferences();

    switch(T) {
      case const (int):
        preferences.setInt(key, value as int);
        break;
      case const (String):
        preferences.setString(key, value as String);
        break;
      case const (bool):
        preferences.setBool(key, value as bool);
        break;
      default:
        throw UnimplementedError('SET not implemented for type ${ T.runtimeType }');
    }

  }

}
