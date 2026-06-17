import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/errors/errors.dart';
import 'core/providers/core_providers.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'shared/controllers/global_error_handler.dart';

/// Root application widget — Arabic-first (RTL), driven by GoRouter.
///
/// Wires [SessionManager.onSessionExpired] to a dialog so any 401 surfaces a
/// "session expired" message before the router redirects back to login.
class CbexApp extends ConsumerStatefulWidget {
  const CbexApp({super.key});

  @override
  ConsumerState<CbexApp> createState() => _CbexAppState();
}

class _CbexAppState extends ConsumerState<CbexApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final session = ref.read(sessionManagerProvider);
      session.onSessionExpired = (message) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          GlobalErrorHandler.show(
            ctx,
            UiError(
              title: 'انتهت الجلسة',
              message: message,
              action: ErrorAction.dialog,
            ),
          );
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CBEX',
      debugShowCheckedModeBanner: false,

      // ── Theme (CBEX brand) ──
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      // ── Localization (en + ar); Arabic forced → RTL ──
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('ar'),

      routerConfig: router,
    );
  }
}
