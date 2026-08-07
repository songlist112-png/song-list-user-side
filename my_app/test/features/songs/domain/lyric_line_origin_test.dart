import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/songs/domain/lyric_line_origin.dart';

void main() {
  test('marks unchanged admin lines black and user lines personal', () {
    final lines = classifyLyricLines(
      originalLyrics: 'First line\nSecond line',
      displayedLyrics: 'First line\nMy note\nSecond line changed',
    );

    expect(lines.map((line) => line.isPersonal), [false, true, true]);
  });

  test('inserted note does not mark following admin lines personal', () {
    final lines = classifyLyricLines(
      originalLyrics: 'First line\nSecond line',
      displayedLyrics: 'First line\n[My note]\nSecond line',
    );

    expect(lines.map((line) => line.isPersonal), [false, true, false]);
  });

  test('additional duplicate line is personal', () {
    final lines = classifyLyricLines(
      originalLyrics: 'Chorus',
      displayedLyrics: 'Chorus\nChorus',
    );

    expect(lines.map((line) => line.isPersonal), [false, true]);
  });
}
