import 'package:equatable/equatable.dart';

/// Minimal account summary carried inside the user payload.
class AuthAccount extends Equatable {
  final String id;
  final String name;
  final String? type; // individual | organization

  const AuthAccount({required this.id, required this.name, this.type});

  factory AuthAccount.fromJson(Map<String, dynamic> json) => AuthAccount(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        type: (json['type'] ?? json['account_type']) as String?,
      );

  @override
  List<Object?> get props => [id, name, type];
}

/// The authenticated user (`GET /me` and login `data.user`).
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? locale;
  final String? timezone;
  final String? role;
  final List<String> permissions;
  final AuthAccount? account;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.locale,
    this.timezone,
    this.role,
    this.permissions = const [],
    this.account,
  });

  /// UI gating: whether the user holds [permission] (from `/me`).
  bool can(String permission) => permissions.contains(permission);

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        locale: json['locale'] as String?,
        timezone: json['timezone'] as String?,
        role: json['role'] as String?,
        permissions:
            (json['permissions'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        account: json['account'] is Map
            ? AuthAccount.fromJson(
                Map<String, dynamic>.from(json['account'] as Map))
            : null,
      );

  @override
  List<Object?> get props =>
      [id, name, email, phone, locale, timezone, role, permissions, account];
}

/// Result of `POST /login` (and `/register`): the user plus the bearer token.
class AuthData extends Equatable {
  final AuthUser user;
  final String token;
  final String tokenType;

  const AuthData({
    required this.user,
    required this.token,
    this.tokenType = 'Bearer',
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        user: AuthUser.fromJson(
            Map<String, dynamic>.from((json['user'] ?? const {}) as Map)),
        token: json['token'] as String? ?? '',
        tokenType: json['token_type'] as String? ?? 'Bearer',
      );

  @override
  List<Object?> get props => [user, token, tokenType];
}
