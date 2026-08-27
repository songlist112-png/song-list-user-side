import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app/router/app_router.dart';

void main() {
  test('uses selector when no board was remembered', () {
    expect(restoredBoardLocation(null), '/');
    expect(restoredBoardLocation('  '), '/');
  });

  test('builds restored board startup location', () {
    final location = Uri.parse(restoredBoardLocation('board-id'));

    expect(location.path, '/board/board-id');
    expect(location.queryParameters['restored'], 'true');
  });
}
