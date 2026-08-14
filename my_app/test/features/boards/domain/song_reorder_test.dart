import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/domain/song_reorder.dart';
import 'package:my_app/shared/models/song.dart';

void main() {
  const songs = [
    Song(id: 'one', title: 'One'),
    Song(id: 'two', title: 'Two'),
    Song(id: 'three', title: 'Three'),
  ];

  test('moves first song to bottom', () {
    final reordered = reorderSongsByIndex(songs, 0, 2);

    expect(reordered.map((song) => song.id), ['two', 'three', 'one']);
  });

  test('moves first song to bottom in a two-song list', () {
    final reordered = reorderSongsByIndex(songs.take(2).toList(), 0, 1);

    expect(reordered.map((song) => song.id), ['two', 'one']);
  });

  test('moves last song to top', () {
    final reordered = reorderSongsByIndex(songs, 2, 0);

    expect(reordered.map((song) => song.id), ['three', 'one', 'two']);
  });

  test('does not mutate source list', () {
    reorderSongsByIndex(songs, 0, 2);

    expect(songs.map((song) => song.id), ['one', 'two', 'three']);
  });
}
