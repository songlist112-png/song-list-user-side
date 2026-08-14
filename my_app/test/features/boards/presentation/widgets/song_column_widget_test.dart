import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/presentation/widgets/song_card_widget.dart';
import 'package:my_app/features/boards/presentation/widgets/song_column_widget.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:my_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:my_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  @override
  Future<UserPreferences> load() async => const UserPreferences();

  @override
  Future<void> save(UserPreferences preferences) async {}
}

void main() {
  testWidgets('full expanded lyrics scroll with column without overflow', (
    tester,
  ) async {
    final lyrics = List.filled(80, 'Long lyric line').join('\n');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _InMemorySettingsRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 420,
              child: SongColumnWidget(
                column: SongColumn(
                  id: 'column',
                  title: 'Set list',
                  songs: [
                    Song(id: 'song', title: 'Long song', lyrics: lyrics),
                  ],
                ),
                isViewMode: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Long song'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(SongCardWidget)).height,
      greaterThan(420),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text(lyrics), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin-created songs never expose reorder handles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: SongColumnWidget(
              column: const SongColumn(
                id: 'admin-column',
                title: 'Admin songs',
                songs: [
                  Song(id: 'one', title: 'One', canEdit: false),
                  Song(id: 'two', title: 'Two', canEdit: false),
                  Song(id: 'three', title: 'Three', canEdit: false),
                ],
              ),
              isViewMode: true,
              onReorderSongs: (_, _) {},
              onMoveSong: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ReorderableDragStartListener), findsNothing);
    expect(find.byType(ReorderableDelayedDragStartListener), findsNothing);
    expect(find.byIcon(Icons.drag_indicator), findsNothing);
    expect(find.byIcon(Icons.drive_file_move_outlined), findsNothing);
  });

  testWidgets('user-owned songs can be reordered', (tester) async {
    (int, int)? reordered;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: SongColumnWidget(
              column: const SongColumn(
                id: 'user-column',
                title: 'My songs',
                songs: [
                  Song(id: 'one', title: 'One'),
                  Song(id: 'two', title: 'Two'),
                  Song(id: 'three', title: 'Three'),
                ],
              ),
              onReorderSongs: (oldIndex, newIndex) {
                reordered = (oldIndex, newIndex);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ReorderableDragStartListener), findsNWidgets(3));
    expect(find.byType(ReorderableDelayedDragStartListener), findsNWidgets(3));
    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));

    final handles = find.byType(ReorderableDragStartListener);
    final bottom = tester.getBottomRight(find.byType(ReorderableListView));
    final gesture = await tester.startGesture(tester.getCenter(handles.first));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(handles.at(1)));
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.moveTo(bottom + const Offset(-20, 100));
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(reordered?.$1, 0);
    expect(reordered?.$2, 2);
  });

  testWidgets('personal songs expose move action', (tester) async {
    Song? requestedMove;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SongColumnWidget(
              column: const SongColumn(
                id: 'column',
                title: 'My songs',
                songs: [
                  Song(id: 'mine', title: 'Mine'),
                  Song(id: 'mine-too', title: 'Mine too'),
                ],
              ),
              onMoveSong: (song) => requestedMove = song,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.drive_file_move_outlined), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.drive_file_move_outlined).first);
    expect(requestedMove?.id, 'mine');
  });
}
