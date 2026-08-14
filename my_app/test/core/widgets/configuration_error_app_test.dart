import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/widgets/configuration_error_app.dart';

void main() {
  testWidgets('shows missing public configuration without exposing values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ConfigurationErrorApp(
        missingKeys: ['SUPABASE_URL', 'SUPABASE_ANON_KEY'],
      ),
    );

    expect(find.text('App configuration missing'), findsOneWidget);
    expect(find.text('SUPABASE_URL, SUPABASE_ANON_KEY'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
