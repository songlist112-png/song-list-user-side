import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/presentation/widgets/name_prompt_dialog.dart';

void main() {
  testWidgets('returns a trimmed name without lifecycle errors', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showNamePrompt(context, title: 'Rename Board');
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Updated board  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'Updated board');
    expect(tester.takeException(), isNull);
  });
}
