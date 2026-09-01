import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/songs/presentation/pages/add_edit_song_page.dart';
import 'package:my_app/shared/models/label.dart';
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
    expect(find.byTooltip('Attachment actions'), findsOneWidget);
    expect(find.byTooltip('View attachment'), findsNothing);
    expect(find.byTooltip('Download file'), findsNothing);
    expect(find.byTooltip('Remove'), findsNothing);

    await tester.scrollUntilVisible(
      find.byTooltip('Attachment actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Attachment actions'));
    await tester.pumpAndSettle();

    expect(find.text('View'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('opens a local attachment from song editor', (tester) async {
    String? openedPath;
    String? openedMediaType;
    const attachment = SongAttachment(
      name: 'lyrics.txt',
      localPath: '/picked/lyrics.txt',
      fileType: 'text/plain',
      fileSize: 42,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddEditSongPage(
          existingSong: Song(
            id: 'song-1',
            title: 'Song',
            attachments: [attachment],
          ),
          availableArtists: const [],
          onSave: (_) async {},
          onOpenAttachment: (path, mediaType) async {
            openedPath = path;
            openedMediaType = mediaType;
          },
        ),
      ),
    );

    final attachmentActions = find.byTooltip('Attachment actions');
    await tester.scrollUntilVisible(
      attachmentActions,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(attachmentActions);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(openedPath, attachment.localPath);
    expect(openedMediaType, attachment.fileType);
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

  testWidgets('plus button creates and selects label', (tester) async {
    Song? savedSong;
    const newLabel = Label(id: 'new-label', name: 'Worship');
    await tester.pumpWidget(
      MaterialApp(
        home: AddEditSongPage(
          availableArtists: const [],
          onAddLabel: () async => newLabel,
          onSave: (song) async => savedSong = song,
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter song title'),
      'Song',
    );
    final addLabelButton = find.byTooltip('Add new label');
    await tester.scrollUntilVisible(
      addLabelButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addLabelButton);
    await tester.pumpAndSettle();

    expect(find.text('Worship'), findsOneWidget);
    expect(
      tester.getRect(find.text('LABELS')).left,
      lessThan(tester.getRect(addLabelButton).left),
    );
    expect(
      tester.getRect(find.text('Worship')).top,
      greaterThan(tester.getRect(addLabelButton).bottom),
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(savedSong?.labels, ['new-label']);
  });
}
