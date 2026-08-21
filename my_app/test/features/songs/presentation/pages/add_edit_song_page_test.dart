import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/songs/presentation/pages/add_edit_song_page.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_attachment.dart';

void main() {
  testWidgets('shows stored song attachments', (tester) async {
    const attachment = SongAttachment(
      id: 'attachment-1',
      name: 'chart.pdf',
      storagePath: 'user/song/chart.pdf',
      fileType: 'application/pdf',
      fileSize: 42,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddEditSongPage(
            existingSong: const Song(
              id: 'song-1',
              title: 'Song',
              attachments: [attachment],
            ),
            availableArtists: const [],
            onSave: (_) async {},
          ),
        ),
      ),
    );

    expect(find.text('chart.pdf'), findsOneWidget);
    expect(find.byTooltip('Download file'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsOneWidget);
  });

  testWidgets('plus button adds and selects artist', (tester) async {
    Song? savedSong;
    await tester.pumpWidget(
      MaterialApp(
        home: AddEditSongPage(
          availableArtists: const ['Existing Artist'],
          onAddArtist: () async => 'New Artist',
          onSave: (song) async => savedSong = song,
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter song title'),
      'Song',
    );
    await tester.tap(find.byTooltip('Add new artist'));
    await tester.pumpAndSettle();

    expect(find.text('New Artist'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(savedSong?.artistName, 'New Artist');
  });
}
