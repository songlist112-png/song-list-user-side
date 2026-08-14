import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/database/isar_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/env.dart';
import 'core/widgets/configuration_error_app.dart';
import 'core/services/background_sync.dart';
import 'core/services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final missingKeys = Env.missingRequiredKeys;
  if (missingKeys.isNotEmpty) {
    runApp(ConfigurationErrorApp(missingKeys: missingKeys));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  await IsarDatabase.initialize();

  await initializeBackgroundSync();

  final syncService = SyncService(isar: IsarDatabase.instance);
  unawaited(syncService.start());

  runApp(
    ProviderScope(
      overrides: [syncServiceProvider.overrideWithValue(syncService)],
      child: const MyApp(),
    ),
  );
}
