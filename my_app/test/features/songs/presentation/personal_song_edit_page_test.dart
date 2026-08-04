import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app/theme/app_colors.dart';
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
    final field = tester.widget<TextField>(find.byType(TextField));
    final context = tester.element(find.byType(TextField));
    final span = field.controller!.buildTextSpan(
      context: context,
      style: field.style,
      withComposing: false,
    );
    final lineColors = span.children!.cast<TextSpan>().map(
      (line) => line.style?.color,
    );
    expect(field.style?.color, Colors.black);
    expect(lineColors, everyElement(AppColors.personalEdit));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, 'My lyrics\n[private note]');
  });
}
