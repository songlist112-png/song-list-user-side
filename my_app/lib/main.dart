import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/database/isar_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/env.dart';
import 'core/services/background_sync.dart';
import 'core/services/sync_service.dart';
import 'core/widgets/configuration_error_app.dart';
import 'core/widgets/startup_error_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final missingKeys = Env.missingRequiredKeys;
  if (missingKeys.isNotEmpty) {
    runApp(ConfigurationErrorApp(missingKeys: missingKeys));
    return;
  }

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    await IsarDatabase.initialize();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app bootstrap',
      ),
    );
    runApp(const StartupErrorApp());
    return;
  }

  final syncService = SyncService(isar: IsarDatabase.instance);
  runApp(
    ProviderScope(
      overrides: [syncServiceProvider.overrideWithValue(syncService)],
      child: const MyApp(),
    ),
  );

  unawaited(_startBackgroundServices(syncService));
}

Future<void> _startBackgroundServices(SyncService syncService) async {
  try {
    await initializeBackgroundSync();
  } catch (error, stackTrace) {
    debugPrint('Background scheduling is unavailable: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await syncService.start();
  } catch (error, stackTrace) {
    debugPrint('Initial synchronization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
