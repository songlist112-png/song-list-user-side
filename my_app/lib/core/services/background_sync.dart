import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../database/isar_database.dart';
import '../constants/env.dart';
import 'sync_service.dart';

const backgroundSyncTask = 'com.songlist.background-sync';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((_, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
      await IsarDatabase.initialize();
      await SyncService(isar: IsarDatabase.instance).synchronize();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Background worker failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  });
}

Future<void> initializeBackgroundSync() async {
  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTask,
    backgroundSyncTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
