import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/widgets/app_chip.dart';
import 'package:my_app/app/theme/app_colors.dart';
import 'package:my_app/features/boards/presentation/widgets/song_card_widget.dart';
import 'package:my_app/shared/models/song.dart';

void main() {
  testWidgets('AppChip renders label and handles tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppChip(label: 'Acoustic', onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Acoustic'), findsOneWidget);
    await tester.tap(find.text('Acoustic'));
    expect(tapped, isTrue);
  });

  testWidgets('song card shows user-created status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SongCardWidget(
            song: Song(id: '1', title: 'User song'),
          ),
        ),
      ),
    );

    expect(find.text('User-created'), findsOneWidget);
  });

  testWidgets('song card shows admin-created status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SongCardWidget(
            song: Song(
              id: '1',
              title: 'Admin song',
              creatorType: SongCreatorType.admin,
              canEdit: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Admin-created'), findsOneWidget);
  });

  testWidgets('only user lyric lines use green indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongCardWidget(
            song: const Song(
              id: '1',
              title: 'Admin song',
              creatorType: SongCreatorType.admin,
              canEdit: false,
              lyrics: 'Admin lyrics\nSecond admin line',
              personalLyrics:
                  'Admin lyrics\nMy personal note\nSecond admin line',
            ),
            isExpanded: true,
            onPersonalEdit: () {},
          ),
        ),
      ),
    );

    final lyrics = tester.widget<Text>(
      find.text('Admin lyrics\nMy personal note\nSecond admin line'),
    );
    final editIcon = tester.widget<Icon>(find.byIcon(Icons.edit_note));
    final spans = (lyrics.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(find.text('Personal edit'), findsOneWidget);
    expect(spans.map((span) => span.style?.color), [
      Colors.black,
      AppColors.personalEdit,
      Colors.black,
    ]);
    expect(editIcon.color, AppColors.personalEdit);
  });
}
