import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/subscription/domain/subscription_entitlement.dart';
import 'package:my_app/features/subscription/domain/subscription_repository.dart';
import 'package:my_app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:my_app/features/subscription/presentation/widgets/subscription_gate.dart';

class _GateRepository implements SubscriptionRepository {
  _GateRepository({this.remote, this.cached, this.remoteError});

  final SubscriptionEntitlement? remote;
  final SubscriptionEntitlement? cached;
  final Object? remoteError;

  @override
  Future<SubscriptionEntitlement?> loadCached(String userId) async => cached;

  @override
  Future<SubscriptionEntitlement> validate(String userId) async {
    if (remoteError case final error?) throw error;
    return remote!;
  }
}

void main() {
  final validatedAt = DateTime(2026, 8, 13, 12);

  SubscriptionEntitlement entitlement({
    required SubscriptionStatus status,
    required String plan,
    required DateTime expiresAt,
    DateTime? offlineGraceUntil,
  }) => SubscriptionEntitlement(
    plan: plan,
    status: status,
    expiresAt: expiresAt,
    lastValidatedAt: validatedAt,
    offlineGraceUntil:
        offlineGraceUntil ?? validatedAt.add(const Duration(hours: 24)),
  );

  Future<void> pumpGate(
    WidgetTester tester, {
    required _GateRepository repository,
    required DateTime now,
  }) async {
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subscriptionGateProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(
          home: SubscriptionGate(
            child: Scaffold(body: Text('Protected application content')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('locks app and shows paywall for an expired trial', (
    tester,
  ) async {
    await pumpGate(
      tester,
      repository: _GateRepository(
        remote: entitlement(
          status: SubscriptionStatus.trial,
          plan: 'trial',
          expiresAt: validatedAt,
        ),
      ),
      now: validatedAt,
    );

    expect(find.text('Keep the music going'), findsOneWidget);
    expect(find.text('Subscribe now'), findsOneWidget);
    expect(find.text('Protected application content'), findsNothing);
  });

  testWidgets('locks app and shows paywall for an expired subscription', (
    tester,
  ) async {
    await pumpGate(
      tester,
      repository: _GateRepository(
        remote: entitlement(
          status: SubscriptionStatus.active,
          plan: 'monthly',
          expiresAt: validatedAt,
        ),
      ),
      now: validatedAt,
    );

    expect(find.text('Keep the music going'), findsOneWidget);
    expect(find.text('Subscribe now'), findsOneWidget);
    expect(find.text('Protected application content'), findsNothing);
  });

  testWidgets('locks app after exactly 24 hours offline', (tester) async {
    final cached = entitlement(
      status: SubscriptionStatus.active,
      plan: 'monthly',
      expiresAt: validatedAt.add(const Duration(days: 30)),
    );
    await pumpGate(
      tester,
      repository: _GateRepository(
        cached: cached,
        remoteError: const SocketException('offline'),
      ),
      now: validatedAt.add(const Duration(hours: 24)),
    );

    expect(find.text('Connect to verify'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Protected application content'), findsNothing);
  });

  testWidgets('locks an open app when its offline grace period elapses', (
    tester,
  ) async {
    var now = validatedAt;
    final cached = entitlement(
      status: SubscriptionStatus.active,
      plan: 'monthly',
      expiresAt: validatedAt.add(const Duration(days: 30)),
      offlineGraceUntil: validatedAt.add(const Duration(minutes: 3)),
    );
    final controller = SubscriptionGateController(
      _GateRepository(
        cached: cached,
        remoteError: const SocketException('offline'),
      ),
      () => 'user-1',
      clock: () => now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subscriptionGateProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(
          home: SubscriptionGate(
            child: Scaffold(body: Text('Protected application content')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Protected application content'), findsOneWidget);

    now = cached.offlineGraceUntil;
    await tester.pump(const Duration(minutes: 3));
    await tester.pumpAndSettle();

    expect(find.text('Connect to verify'), findsOneWidget);
    expect(find.text('Protected application content'), findsNothing);
  });
}
