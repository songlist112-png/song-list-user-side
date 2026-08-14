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
    String plan = 'trial',
    DateTime? expiresAt,
    DateTime? graceUntil,
  }) => SubscriptionEntitlement(
    plan: plan,
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

  test(
    'allows cached access immediately before the 24-hour deadline',
    () async {
      final repository = _FakeSubscriptionRepository()
        ..remoteError = const SocketException('offline')
        ..cached = entitlement();
      final controller = SubscriptionGateController(
        repository,
        () => 'user-1',
        clock: () => now
            .add(const Duration(hours: 24))
            .subtract(const Duration(microseconds: 1)),
      );

      await controller.validate();

      expect(controller.state.status, SubscriptionGateStatus.entitled);
    },
  );

  test('requires validation at exactly 24 hours offline', () async {
    final repository = _FakeSubscriptionRepository()
      ..remoteError = const SocketException('offline')
      ..cached = entitlement();
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now.add(const Duration(hours: 24)),
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.internetRequired);
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

  test('blocks an expired trial even when its status is still trial', () async {
    final repository = _FakeSubscriptionRepository()
      ..remote = entitlement(status: SubscriptionStatus.trial, expiresAt: now);
    final controller = SubscriptionGateController(
      repository,
      () => 'user-1',
      clock: () => now,
    );

    await controller.validate();

    expect(controller.state.status, SubscriptionGateStatus.expired);
  });

  test(
    'blocks an expired paid subscription even when status is active',
    () async {
      final repository = _FakeSubscriptionRepository()
        ..remote = entitlement(
          status: SubscriptionStatus.active,
          plan: 'monthly',
          expiresAt: now,
        );
      final controller = SubscriptionGateController(
        repository,
        () => 'user-1',
        clock: () => now,
      );

      await controller.validate();

      expect(controller.state.status, SubscriptionGateStatus.expired);
    },
  );
}
