import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Secure wrapper over `flutter_secure_storage` for the Sanctum bearer token and
/// a couple of small auth-related values. On Android this is backed by
/// EncryptedSharedPreferences; never store the token in plain SharedPreferences.
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ── Token ──
  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.token, value: token);

  Future<String?> getToken() => _storage.read(key: StorageKeys.token);

  Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  // ── Last email (login pre-fill; intentionally persists across logout) ──
  Future<void> saveLastEmail(String email) =>
      _storage.write(key: StorageKeys.lastUsername, value: email);

  Future<String?> getLastEmail() => _storage.read(key: StorageKeys.lastUsername);

  /// Clears session data (token) but keeps the last email for pre-fill.
  Future<void> clearAll() async {
    await _storage.delete(key: StorageKeys.token);
    // StorageKeys.lastUsername (email) intentionally retained.
  }
}
