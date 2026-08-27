import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/data/last_board_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keeps last board isolated by signed-in user', () async {
    SharedPreferences.setMockInitialValues({});
    var userId = 'user-a';
    final store = LastBoardStore(userId: () => userId);

    await store.save('board-a');
    expect(await store.read(), 'board-a');
    await store.saveColumnIndex(2);
    expect(await store.readColumnIndex(), 2);

    userId = 'user-b';
    expect(await store.read(), isNull);
    expect(await store.readColumnIndex(), 0);
    await store.save('board-b');
    await store.saveColumnIndex(1);
    expect(await store.read(), 'board-b');
    expect(await store.readColumnIndex(), 1);

    userId = 'user-a';
    expect(await store.read(), 'board-a');
    expect(await store.readColumnIndex(), 2);
    await store.save('board-a-new');
    expect(await store.readColumnIndex(), 0);
    await store.clear();
    expect(await store.read(), isNull);
    expect(await store.readColumnIndex(), 0);
  });

  test('ignores empty board IDs and unauthenticated sessions', () async {
    SharedPreferences.setMockInitialValues({});
    String? userId;
    final store = LastBoardStore(userId: () => userId);

    await store.save('board');
    expect(await store.read(), isNull);

    userId = 'user';
    await store.save('   ');
    expect(await store.read(), isNull);
  });
}
