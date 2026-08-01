import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/presentation/widgets/song_card_widget.dart';
import 'package:my_app/features/boards/presentation/widgets/song_column_widget.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';

void main() {
  testWidgets('full expanded lyrics scroll with column without overflow', (
    tester,
  ) async {
    final lyrics = List.filled(80, 'Long lyric line').join('\n');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 420,
            child: SongColumnWidget(
              column: SongColumn(
                id: 'column',
                title: 'Set list',
                songs: [Song(id: 'song', title: 'Long song', lyrics: lyrics)],
              ),
              isViewMode: true,
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
}
