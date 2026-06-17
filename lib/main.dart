import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'injection.dart';

/// Application entry point.
///
/// Initializes the GetIt data layer (storage → session → ApiClient →
/// repositories) before launching the Riverpod app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProviderScope(child: CbexApp()));
}
