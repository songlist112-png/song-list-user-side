import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/songs/presentation/pages/personal_song_edit_page.dart';
import 'package:my_app/shared/models/song.dart';

void main() {
  testWidgets('edits only private lyrics and notes', (tester) async {
    String? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: PersonalSongEditPage(
          song: const Song(
            id: 'song',
            title: 'Admin title',
            creatorType: SongCreatorType.admin,
            canEdit: false,
            lyrics: 'Admin lyrics',
          ),
          onSave: (lyrics) async => saved = lyrics,
        ),
      ),
    );

    expect(find.text('Admin title'), findsOneWidget);
    expect(
      find.text(
        'Song details stay managed by admin. Only your private lyrics and notes change.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'My lyrics\n[private note]');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, 'My lyrics\n[private note]');
  });
}
