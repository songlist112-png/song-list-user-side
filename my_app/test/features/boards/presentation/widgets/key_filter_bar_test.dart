import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/presentation/widgets/key_filter_bar.dart';

void main() {
  testWidgets('shows complete clear key on compact phone width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 180);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyFilterBar(
            onKeySelected: (_) {},
            onAccidentalSelected: (_) {},
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    final clearKey = find.text('✕');
    expect(clearKey, findsOneWidget);
    expect(tester.getRect(clearKey).right, lessThanOrEqualTo(320));

    await tester.tap(clearKey);
    expect(cleared, isTrue);
    expect(tester.takeException(), isNull);
  });
}
