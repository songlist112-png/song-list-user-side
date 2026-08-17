import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/widgets/startup_error_app.dart';

void main() {
  testWidgets('shows a safe recovery message without exception details', (
    tester,
  ) async {
    await tester.pumpWidget(const StartupErrorApp());

    expect(find.text('Unable to start the app'), findsOneWidget);
    expect(find.textContaining('reinstall the latest APK'), findsOneWidget);
  });
}
