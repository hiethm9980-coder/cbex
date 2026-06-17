import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/models/auth_models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;

  const AuthState({this.status = AuthStatus.unknown, this.user});

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  /// UI gating helper backed by the user's `/me` permissions.
  bool can(String permission) => user?.can(permission) ?? false;

  AuthState copyWith({AuthStatus? status, AuthUser? user}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user);
}

/// Global auth state. Drives the GoRouter redirect (splash → login → home).
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<bool>? _sub;

  @override
  AuthState build() {
    // Any 401 anywhere flips the session stream → drop to unauthenticated.
    _sub = ref.read(sessionManagerProvider).authStateStream.listen((isAuth) {
      if (!isAuth && state.isAuthenticated) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
    ref.onDispose(() => _sub?.cancel());
    return const AuthState();
  }

  /// Called by the splash screen on startup.
  Future<void> checkSession() async {
    final session = ref.read(sessionManagerProvider);
    final hasToken = await session.tryRestoreSession();
    if (!hasToken) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      // Token invalid/expired or server unreachable → require re-login.
      await session.onLogout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Throws [ApiException] on failure — handled by the login screen.
  Future<void> login(String email, String password) async {
    final data = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    state = AuthState(status: AuthStatus.authenticated, user: data.user);
  }

  /// Registers a new account + owner and auto-logs-in (the API returns a token).
  /// Throws [ApiException] on failure — handled by the register screen.
  Future<void> register({
    required String accountName,
    required String accountType,
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String country = 'SA',
    String locale = 'ar',
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final data = await repo.register({
      'account_name': accountName,
      'account_type': accountType,
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'country': country,
      'locale': locale,
    });
    // The repository stored the token; enrich with the full /me profile
    // (permissions, account) — fall back to the registration payload's user.
    var user = data.user;
    try {
      user = await repo.me();
    } catch (_) {
      // keep `data.user`
    }
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
