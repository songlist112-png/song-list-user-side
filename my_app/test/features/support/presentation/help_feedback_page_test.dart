import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/support/presentation/pages/help_feedback_page.dart';

void main() {
  testWidgets('shows help copy and both ticket actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpFeedbackPage()));

    expect(find.text('Help & Feedback'), findsOneWidget);
    expect(find.text('How can we help?'), findsOneWidget);
    expect(find.text('Send Feedback'), findsOneWidget);
    expect(find.text('My Tickets'), findsOneWidget);
    expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);
  });
}
