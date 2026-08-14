import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/subscription/presentation/widgets/subscription_modal.dart';

void main() {
  testWidgets('expired modal offers subscription and revalidation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionModal(
            problem: SubscriptionProblem.expired,
            onRetry: () async {},
            onSignOut: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Keep the music going'), findsOneWidget);
    expect(find.text('Subscribe now'), findsOneWidget);
    expect(find.text('I already subscribed'), findsOneWidget);
  });

  testWidgets('offline modal requires internet and supports retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionModal(
            problem: SubscriptionProblem.internetRequired,
            onRetry: () async => retried = true,
            onSignOut: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Connect to verify'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retried, isTrue);
  });

  testWidgets('service failure does not blame the internet connection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionModal(
            problem: SubscriptionProblem.serviceUnavailable,
            onRetry: () async {},
            onSignOut: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Verification unavailable'), findsOneWidget);
    expect(find.textContaining('internet may be working'), findsOneWidget);
  });

  testWidgets('allows switching away from the blocked account', (tester) async {
    var signedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionModal(
            problem: SubscriptionProblem.expired,
            onRetry: () async {},
            onSignOut: () async => signedOut = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Log out / Use another account'));
    await tester.pump();

    expect(signedOut, isTrue);
  });
}
