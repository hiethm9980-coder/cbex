import 'package:dio/dio.dart';

import '../storage/secure_token_storage.dart';
import 'session_manager.dart';

/// Attaches `Accept: application/json` and the Sanctum
/// `Authorization: Bearer <token>` header to every request, and triggers session
/// expiry if a thrown 401 ever reaches the error path.
///
/// Note: [ApiClient] uses `validateStatus: (_) => true`, so 401s are normally
/// handled there (no DioException). [onError] is a belt-and-suspenders guard.
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _storage;
  final SessionManager _sessionManager;

  AuthInterceptor({
    required SecureTokenStorage storage,
    required SessionManager sessionManager,
  })  : _storage = storage,
        _sessionManager = sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _sessionManager.onTokenExpired();
    }
    handler.next(err);
  }
}
