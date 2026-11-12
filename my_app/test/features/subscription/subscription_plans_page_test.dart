import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/subscription/domain/subscription_entitlement.dart';
import 'package:my_app/features/subscription/domain/subscription_repository.dart';
import 'package:my_app/features/subscription/presentation/pages/subscription_plans_page.dart';
import 'package:my_app/features/subscription/presentation/providers/subscription_provider.dart';

class _PlanRepository implements SubscriptionRepository {
  const _PlanRepository(this.entitlement);

  final SubscriptionEntitlement entitlement;

  @override
  Future<SubscriptionEntitlement?> loadCached(String userId) async =>
      entitlement;

  @override
  Future<SubscriptionEntitlement> validate(String userId) async => entitlement;
}

void main() {
  final now = DateTime(2026, 8, 29, 12);

  SubscriptionEntitlement entitlement({
    required SubscriptionStatus status,
    required String plan,
  }) => SubscriptionEntitlement(
    plan: plan,
    status: status,
    expiresAt: now.add(const Duration(days: 30)),
    lastValidatedAt: now,
    offlineGraceUntil: now.add(const Duration(hours: 24)),
  );

  Future<void> pumpPage(
    WidgetTester tester, {
    required SubscriptionEntitlement entitlement,
    Future<bool> Function(Uri)? launchPortal,
  }) async {
    final controller = SubscriptionGateController(
      _PlanRepository(entitlement),
      () => 'user-1',
      clock: () => now,
    );
    await controller.validate();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subscriptionGateProvider.overrideWith((ref) => controller)],
        child: MaterialApp(
          home: SubscriptionPlansPage(launchPortal: launchPortal),
        ),
      ),
    );
  }

  testWidgets('shows active premium subscription as current plan', (
    tester,
  ) async {
    await pumpPage(
      tester,
      entitlement: entitlement(
        status: SubscriptionStatus.active,
        plan: 'monthly',
      ),
    );

    expect(find.text('Subscribed'), findsOneWidget);
    expect(find.text('Song List Premium'), findsNWidgets(2));
    expect(find.text('Current plan'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
    expect(find.textContaining('Monthly plan'), findsOneWidget);
  });

  testWidgets('shows trial user as not yet subscribed to premium', (
    tester,
  ) async {
    await pumpPage(
      tester,
      entitlement: entitlement(status: SubscriptionStatus.trial, plan: 'trial'),
    );

    expect(find.text('Free trial'), findsOneWidget);
    expect(find.text('Song List Trial'), findsOneWidget);
    expect(find.text('Current plan'), findsNothing);
    expect(find.text('View premium plans'), findsOneWidget);
  });

  testWidgets('opens billing portal from premium card', (tester) async {
    Uri? openedUri;
    await pumpPage(
      tester,
      entitlement: entitlement(
        status: SubscriptionStatus.active,
        plan: 'monthly',
      ),
      launchPortal: (uri) async {
        openedUri = uri;
        return true;
      },
    );

    await tester.tap(find.text('Manage subscription'));
    await tester.pump();

    expect(openedUri, isNotNull);
    expect(openedUri!.scheme, 'https');
  });

  testWidgets('premium card remains usable on a narrow screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await pumpPage(
      tester,
      entitlement: entitlement(
        status: SubscriptionStatus.active,
        plan: 'monthly',
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Manage subscription'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Manage subscription'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
