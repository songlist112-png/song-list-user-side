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
}
