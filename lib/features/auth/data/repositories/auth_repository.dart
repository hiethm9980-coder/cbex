import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/session_manager.dart';
import '../models/auth_models.dart';

/// Auth data layer against the CEBX Mobile Customer API.
///
/// On a successful login/register the bearer token is persisted via
/// [SessionManager.onLoginSuccess]; the AuthInterceptor then attaches it.
class AuthRepository {
  final ApiClient _client;
  final SessionManager _session;

  AuthRepository({required ApiClient client, required SessionManager session})
      : _client = client,
        _session = session;

  Future<AuthData> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post<AuthData>(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'device_name': await _deviceName(),
      },
      fromJson: (json) => AuthData.fromJson(_asMap(json)),
    );
    final data = res.data!;
    await _session.onLoginSuccess(token: data.token);
    await _session.storage.saveLastEmail(email);
    return data;
  }

  /// [body] holds the registration fields (account_name, account_type, name,
  /// email, password, password_confirmation, phone, locale, country).
  Future<AuthData> register(Map<String, dynamic> body) async {
    final res = await _client.post<AuthData>(
      ApiConstants.register,
      data: {...body, 'device_name': await _deviceName()},
      fromJson: (json) => AuthData.fromJson(_asMap(json)),
    );
    final data = res.data!;
    if (data.token.isNotEmpty) {
      await _session.onLoginSuccess(token: data.token);
    }
    return data;
  }

  Future<AuthUser> me() async {
    final res = await _client.get<AuthUser>(
      ApiConstants.me,
      fromJson: (json) => AuthUser.fromJson(_asMap(json)),
    );
    return res.data!;
  }

  Future<void> logout() async {
    try {
      await _client.post<void>(ApiConstants.logout);
    } finally {
      await _session.onLogout();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _client.post<void>(ApiConstants.logoutAll);
    } finally {
      await _session.onLogout();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _client.post<void>(ApiConstants.forgotPassword, data: {'email': email});
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _client.put<void>(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );
  }

  /// Last email used to log in (for pre-filling the login form).
  Future<String?> lastEmail() => _session.storage.getLastEmail();

  // ── helpers ──
  static Map<String, dynamic> _asMap(Object? json) =>
      json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};

  /// A short, human-readable device label for the `device_name` field.
  Future<String> _deviceName() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      final m = info.data;
      final model =
          (m['model'] ?? m['name'] ?? m['prettyName'] ?? 'Device').toString();
      final brand = (m['brand'] ?? m['manufacturer'] ?? '').toString();
      final name = '$brand $model'.trim();
      final result = name.isEmpty ? 'CBEX-App' : name;
      return result.length > 255 ? result.substring(0, 255) : result;
    } catch (_) {
      return 'CBEX-App';
    }
  }
}
