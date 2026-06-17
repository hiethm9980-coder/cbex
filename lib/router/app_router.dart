import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

/// Root navigator key — lets non-widget code (e.g. SessionManager) show dialogs.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter whose redirect is driven by [authProvider]'s AuthStatus.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth.isUnknown) {
        return loc == '/splash' ? null : '/splash';
      }
      if (auth.isUnauthenticated) {
        return loc == '/login' ? null : '/login';
      }
      // authenticated → leave splash/login for home.
      if (loc == '/splash' || loc == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
