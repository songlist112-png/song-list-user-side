import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/sync_service.dart';
import 'package:my_app/features/sync/presentation/widgets/initial_sync_gate.dart';

void main() {
  testWidgets('opens the master library only after initial sync completes', (
    tester,
  ) async {
    final statuses = StreamController<SyncStatus>();
    addTearDown(statuses.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncStatusProvider.overrideWith((_) => statuses.stream)],
        child: const MaterialApp(
          home: InitialSyncGate(child: Text('Master song library')),
        ),
      ),
    );

    statuses.add(
      const SyncStatus(
        phase: SyncPhase.synchronizing,
        isInitialSync: true,
        progress: 0.5,
        syncedSongs: 500,
        totalSongs: 1000,
      ),
    );
    await tester.pump();
    expect(find.text('Preparing your song library'), findsOneWidget);
    expect(find.text('Master song library'), findsNothing);

    statuses.add(
      const SyncStatus(
        phase: SyncPhase.completed,
        isInitialSync: true,
        progress: 1,
        syncedSongs: 1000,
        totalSongs: 1000,
      ),
    );
    await tester.pump();
    expect(find.text('Master song library'), findsOneWidget);
    expect(find.text('Preparing your song library'), findsNothing);
  });
}
