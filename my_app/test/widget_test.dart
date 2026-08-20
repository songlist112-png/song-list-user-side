import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/widgets/app_chip.dart';
import 'package:my_app/app/theme/app_colors.dart';
import 'package:my_app/features/boards/presentation/widgets/song_card_widget.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:my_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:my_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:my_app/features/songs/presentation/widgets/protected_lyrics_text.dart';
import 'package:my_app/shared/models/song.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  UserPreferences preferences = const UserPreferences();

  @override
  Future<UserPreferences> load() async => preferences;

  @override
  Future<void> save(UserPreferences newPreferences) async {
    preferences = newPreferences;
  }
}

ProviderScope _settingsScope(
  Widget child, {
  _InMemorySettingsRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        repository ?? _InMemorySettingsRepository(),
      ),
    ],
    child: child,
  );
}

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

  testWidgets('song card shows edited status for user-created song', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongCardWidget(
            song: const Song(
              id: '1',
              title: 'User song',
              lyrics: 'Some lyrics',
              personalLyrics: 'Some lyrics',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Edited'), findsOneWidget);
  });

  testWidgets('song card shows library status for admin-created song', (tester) async {
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

    expect(find.text('Library'), findsOneWidget);
  });

  testWidgets('only user lyric lines use green indicator', (tester) async {
    await tester.pumpWidget(
      _settingsScope(
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
      ),
    );

    expect(find.text('Personal lyrics & notes'), findsOneWidget);

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() ==
                'Admin lyrics\nMy personal note\nSecond admin line',
      ),
    );
    var span = richText.text as TextSpan;
    while (span.children?.length == 1) {
      span = span.children!.single as TextSpan;
    }
    final spans = span.children!.cast<TextSpan>();
    expect(spans.map((span) => span.style?.color), [
      Colors.black,
      AppColors.personalEdit,
      Colors.black,
    ]);
  });

  testWidgets('lyrics zoom persists to settings', (tester) async {
    final repository = _InMemorySettingsRepository();
    const lyrics = 'Line one\nLine two';

    await tester.pumpWidget(
      _settingsScope(
        MaterialApp(
          home: Scaffold(
            body: SongCardWidget(
              song: const Song(id: '1', title: 'Zoom song', lyrics: lyrics),
              isExpanded: true,
              isViewMode: true,
            ),
          ),
        ),
        repository: repository,
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.text_increase), findsOneWidget);
    await tester.tap(find.byIcon(Icons.text_increase));
    await tester.pump();

    expect(repository.preferences.lyricsFontScale, closeTo(1.2, 0.0001));

    final lyricText = tester.widget<Text>(find.text(lyrics));
    expect(lyricText.style?.fontSize, closeTo(13 * 1.2, 0.001));
  });

  testWidgets('displayed lyrics disable copying by default', (tester) async {
    await tester.pumpWidget(
      _settingsScope(
        const MaterialApp(
          home: Scaffold(
            body: SongCardWidget(
              song: Song(id: '1', title: 'Protected', lyrics: 'Private lyrics'),
              isExpanded: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ProtectedLyricsText), findsOneWidget);
    expect(find.byType(SelectionArea), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    expect(find.byType(EditableText), findsNothing);

    final lyrics = find.text('Private lyrics');
    await tester.longPress(lyrics);
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsNothing);
    expect(find.text('Cut'), findsNothing);
    expect(find.text('Paste'), findsNothing);
    expect(find.text('Select all'), findsNothing);

    await tester.tap(lyrics);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(lyrics);
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
