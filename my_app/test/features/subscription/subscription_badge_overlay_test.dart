import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/features/subscription/domain/subscription_entitlement.dart';
import 'package:my_app/features/subscription/domain/subscription_repository.dart';
import 'package:my_app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:my_app/features/subscription/presentation/widgets/subscription_badge_overlay.dart';

class _EntitledRepository implements SubscriptionRepository {
  const _EntitledRepository(this.entitlement);

  final SubscriptionEntitlement entitlement;

  @override
  Future<SubscriptionEntitlement?> loadCached(String userId) async =>
      entitlement;

  @override
  Future<SubscriptionEntitlement> validate(String userId) async => entitlement;
}

void main() {
  final now = DateTime(2026, 8, 29, 12);
  final entitlement = SubscriptionEntitlement(
    plan: 'monthly',
    status: SubscriptionStatus.active,
    expiresAt: now.add(const Duration(days: 30)),
    lastValidatedAt: now,
    offlineGraceUntil: now.add(const Duration(hours: 24)),
  );

  Future<void> pumpBadge(
    WidgetTester tester, {
    bool visible = true,
    bool validateEntitlement = true,
  }) async {
    final controller = SubscriptionGateController(
      _EntitledRepository(entitlement),
      () => 'user-1',
      clock: () => now,
    );
    if (visible && validateEntitlement) await controller.validate();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subscriptionGateProvider.overrideWith((ref) => controller)],
        child: MaterialApp(
          home: TickerMode(
            enabled: false,
            child: SubscriptionBadgeOverlay(
              visible: visible,
              child: const Scaffold(body: Text('Board content')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('money badge opens plans in a modal sheet', (tester) async {
    await pumpBadge(tester);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Plans & Billing'), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
    expect(find.byIcon(Icons.attach_money_rounded), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('subscription-badge-material'))),
      const Size(100, 80),
    );
    final badgeMaterial = tester.widget<Material>(
      find.byKey(const ValueKey('subscription-badge-material')),
    );
    expect(badgeMaterial.color, Colors.transparent);
    expect(badgeMaterial.elevation, 0);
    await tester.tap(find.byTooltip('Plans & Billing'));
    await tester.pumpAndSettle();

    expect(find.text('Plans & Billing'), findsOneWidget);
    expect(find.text('Subscribed'), findsOneWidget);
    expect(find.text('Song List Premium'), findsNWidgets(2));
  });

  testWidgets('money badge can be hidden on subscription page', (tester) async {
    await pumpBadge(tester, visible: false);

    expect(find.byTooltip('Plans & Billing'), findsNothing);
    expect(find.text('Board content'), findsOneWidget);
  });

  testWidgets('translucent close button hides the money badge', (tester) async {
    await pumpBadge(tester, validateEntitlement: false);

    final closeButton = find.byTooltip('Hide subscription shortcut');
    expect(closeButton, findsOneWidget);
    final closeMaterial = tester.widget<Material>(
      find.byKey(const ValueKey('subscription-badge-close')),
    );
    expect(closeMaterial.color?.a, closeTo(0.6, 0.01));

    await tester.tap(closeButton);
    await tester.pump();

    expect(find.byTooltip('Plans & Billing'), findsNothing);
    expect(find.text('Board content'), findsOneWidget);
  });

  testWidgets('money badge drags vertically and snaps to the left edge', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpBadge(tester, validateEntitlement: false);

    final badge = find.byTooltip('Plans & Billing');
    final initialCenter = tester.getCenter(badge);
    await tester.drag(badge, const Offset(-340, -180));
    await tester.pumpAndSettle();
    final movedCenter = tester.getCenter(badge);

    expect(initialCenter.dx, closeTo(362, 1));
    expect(movedCenter.dx, closeTo(38, 1));
    expect(movedCenter.dy, lessThan(initialCenter.dy));
    expect(tester.takeException(), isNull);
  });
}
