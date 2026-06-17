// Smoke test: the app boots through the splash and lands on the login screen
// when there is no stored token.
//
// flutter_secure_storage is mocked to return no token (→ unauthenticated), so
// the GoRouter redirect sends us to /login.

import 'package:cbex/app.dart';
import 'package:cbex/injection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the secure-storage plugin: no token stored.
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'readAll') return <String, String>{};
      return null; // read / write / delete
    });

    await GetIt.instance.reset();
    await initDependencies();
  });

  testWidgets('boots to the login screen when unauthenticated',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CbexApp()));

    // Splash runs checkSession() (no token) → unauthenticated → redirect /login.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }

    // Title + CTA both read 'تسجيل الدخول'.
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });
}
