import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _normalUsernameKey = 'remembered_username';
  static const _normalPasswordKey = 'remembered_password';
  static const _expoPasswordKey = 'expo_password';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveNormalLogin({
    required String username,
    required String password,
  }) async {
    await _storage.write(key: _normalUsernameKey, value: username);
    await _storage.write(key: _normalPasswordKey, value: password);
  }

  Future<Map<String, String>?> readNormalLogin() async {
    final username = await _storage.read(key: _normalUsernameKey);
    final password = await _storage.read(key: _normalPasswordKey);

    if (username == null || password == null ||
        username.isEmpty || password.isEmpty) {
      return null;
    }

    return {'username': username, 'password': password};
  }

  Future<void> clearNormalLogin() async {
    await _storage.delete(key: _normalUsernameKey);
    await _storage.delete(key: _normalPasswordKey);
  }

  Future<void> saveExpoPassword(String password) async {
    await _storage.write(key: _expoPasswordKey, value: password);
  }

  Future<String?> readExpoPassword() async {
    return _storage.read(key: _expoPasswordKey);
  }

  Future<void> clearExpoPassword() async {
    await _storage.delete(key: _expoPasswordKey);
  }
}
