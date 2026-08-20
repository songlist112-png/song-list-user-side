import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/sync_service.dart';
import 'package:my_app/features/sync/presentation/pages/initial_sync_page.dart';

void main() {
  testWidgets('shows real song progress on compact Android and iOS screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    try {
      for (final platform in const [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          _app(
            const SyncStatus(
              phase: SyncPhase.synchronizing,
              isInitialSync: true,
              progress: 0.64,
              syncedSongs: 640,
              totalSongs: 1000,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Preparing your song library'), findsOneWidget);
        expect(find.text('64'), findsOneWidget);
        expect(find.text('640 of 1000 songs'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('offers retry without discarding saved progress', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _app(
        const SyncStatus(
          phase: SyncPhase.offline,
          isInitialSync: true,
          progress: 0.5,
          syncedSongs: 500,
          totalSongs: 1000,
        ),
        onRetry: () async => retries++,
      ),
    );

    expect(find.text('You’re offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retries, 1);
  });

  testWidgets('shows completed song count when an older server has no total', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SyncStatus(
          phase: SyncPhase.synchronizing,
          isInitialSync: true,
          progress: 0.2,
          syncedSongs: 500,
        ),
      ),
    );

    expect(find.text('500 songs ready'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  test('sync status clamps progress for accessible percentage output', () {
    const status = SyncStatus(
      phase: SyncPhase.synchronizing,
      isInitialSync: true,
      progress: 1.4,
    );

    expect(status.progressPercent, 100);
  });
}

Widget _app(SyncStatus status, {Future<void> Function()? onRetry}) =>
    MaterialApp(
      home: InitialSyncPage(
        status: status,
        onRetry: onRetry ?? () async {},
        onSignOut: () async {},
      ),
    );
