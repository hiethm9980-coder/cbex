import 'dart:async';

import '../storage/secure_token_storage.dart';

typedef SessionExpiredCallback = void Function(String message);

/// Owns the auth token lifecycle and broadcasts auth-state changes.
///
/// [onTokenExpired] is triggered on any 401 (idempotently) so the app can route
/// back to login exactly once, even under concurrent failures.
class SessionManager {
  final SecureTokenStorage _storage;

  SessionManager({required SecureTokenStorage storage}) : _storage = storage;

  SecureTokenStorage get storage => _storage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  /// Set by the UI layer to surface a "session expired" message.
  SessionExpiredCallback? onSessionExpired;

  Future<void> onLoginSuccess({required String token}) async {
    await _storage.saveToken(token);
    _isAuthenticated = true;
    _authStateController.add(true);
  }

  Future<void> onLogout() async {
    await _storage.clearAll();
    _isAuthenticated = false;
    _authStateController.add(false);
  }

  /// Idempotent: the guard flips synchronously before the first await so
  /// concurrent 401s collapse into a single redirect.
  Future<void> onTokenExpired() async {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    await _storage.clearAll();
    _authStateController.add(false);
    onSessionExpired?.call('انتهت جلستك. الرجاء تسجيل الدخول مجددًا.');
  }

  Future<bool> tryRestoreSession() async {
    final has = await _storage.hasToken();
    _isAuthenticated = has;
    return has;
  }

  void dispose() => _authStateController.close();
}
