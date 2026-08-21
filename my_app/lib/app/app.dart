import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/screen_capture_protection.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      if (event.session != null) {
        unawaited(ref.read(settingsProvider.notifier).reloadFromRemote());
      }
    });
    // Uncomment to block screenshots and screen recordings on Android and iOS.
    // unawaited(ScreenCaptureProtection.acquire());
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(ScreenCaptureProtection.release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(settingsProvider).valueOrNull?.darkMode ?? false;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Song List',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
