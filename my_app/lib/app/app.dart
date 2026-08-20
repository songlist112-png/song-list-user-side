import 'dart:async';

import 'package:flutter/material.dart';

import '../core/services/screen_capture_protection.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Uncomment to block screenshots and screen recordings on Android and iOS.
    // unawaited(ScreenCaptureProtection.acquire());
  }

  @override
  void dispose() {
    unawaited(ScreenCaptureProtection.release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Song List',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
