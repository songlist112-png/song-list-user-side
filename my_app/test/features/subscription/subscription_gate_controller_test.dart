import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/subscription/domain/subscription_entitlement.dart';
import 'package:my_app/features/subscription/domain/subscription_repository.dart';
import 'package:my_app/features/subscription/presentation/providers/subscription_provider.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  SubscriptionEntitlement? remote;
  SubscriptionEntitlement? cached;
  Object? remoteError;

  @override
  Future<SubscriptionEntitlement?> loadCached(String userId) async => cached;

  @override
  Future<SubscriptionEntitlement> validate(String userId) async {
    if (remoteError case final error?) throw error;
    return remote!;
  }
}

void main() {
  final now = DateTime(2026, 8, 11, 12);

  SubscriptionEntitlement entitlement({
    SubscriptionStatus status = SubscriptionStatus.trial,
    DateTime? expiresAt,
    DateTime? graceUntil,
  }) => SubscriptionEntitlement(
    plan: 'trial',
    status: status,
    expiresAt: expiresAt ?? now.add(const Duration(days: 7)),
    lastValidatedAt: now,
    offlineGraceUntil: graceUntil ?? now.add(const Duration(hours: 24)),
  );

  test('allows a server-validated trial', () async {
    final repository = _FakeSubscriptionRepository()..remote = entitlement();
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.entitled);
  });

  test('allows a valid cached entitlement while offline', () async {
    final repository = _FakeSubscriptionRepository()
      ..remoteError = const SocketException('offline')
      ..cached = entitlement();
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.entitled);
  });

  test('requires internet when the offline grace period is stale', () async {
    final repository = _FakeSubscriptionRepository()
      ..remoteError = const SocketException('offline')
      ..cached = entitlement(
        graceUntil: now.subtract(const Duration(seconds: 1)),
      );
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.internetRequired);
  });

  test('requires internet when the device clock moves backwards', () async {
    final repository = _FakeSubscriptionRepository()
      ..remoteError = const SocketException('offline')
      ..cached = entitlement();
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now.subtract(const Duration(hours: 1)),
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.internetRequired);
  });

  test(
    'reports backend validation failures separately from internet',
    () async {
      final repository = _FakeSubscriptionRepository()
        ..remoteError = const FormatException('RPC missing');
      final controller = SubscriptionGateController(
        repository,
        () => 'user-1',
        clock: () => now,
      );

      await controller.validate();

      expect(
        controller.state.status,
        SubscriptionGateStatus.serviceUnavailable,
      );
    },
  );

  test('blocks an expired subscription', () async {
    final repository = _FakeSubscriptionRepository()
      ..remote = entitlement(
        status: SubscriptionStatus.expired,
        expiresAt: now.subtract(const Duration(minutes: 1)),
      );
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.expired);
  });
}
