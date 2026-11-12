import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/domain/board_filter.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';

void main() {
  const songs = [
    Song(id: '1', title: 'Perfect', artistName: 'Ed Sheeran', key: 'G'),
    Song(id: '2', title: 'Oceans', artistName: 'Hillsong', key: 'C#'),
    Song(id: '3', title: 'Grace', key: 'Db'),
  ];
  const columns = [
    SongColumn(id: '1', title: 'Sunday', songs: songs),
    SongColumn(
      id: '2',
      title: 'Friday',
      songs: [Song(id: '4', title: 'Alive', key: 'A')],
    ),
  ];

  group('BoardFilter.columns', () {
    test('returns original columns for blank query', () {
      expect(BoardFilter.columns(columns, query: '  '), same(columns));
    });

    test('matches column title without removing its songs', () {
      final result = BoardFilter.columns(columns, query: 'SUNDAY');

      expect(result, hasLength(1));
      expect(result.single.songs, songs);
    });

    test('matches song fields case-insensitively', () {
      final result = BoardFilter.columns(columns, query: 'sheeran');

      expect(result.single.songs.map((song) => song.id), ['1']);
    });

    test('omits columns without matches', () {
      expect(BoardFilter.columns(columns, query: 'missing'), isEmpty);
    });

    test('keeps expanded songs alongside current search matches', () {
      final result = BoardFilter.columns(
        columns,
        query: 'oceans',
        retainedSongIds: const {'1'},
      );

      expect(result.single.songs.map((song) => song.id), ['1', '2']);
    });
  });

  group('BoardFilter.firstMatchingColumnId', () {
    test('returns the first column containing the query match', () {
      expect(BoardFilter.firstMatchingColumnId(columns, query: 'alive'), '2');
    });

    test('returns null for a blank or missing query', () {
      expect(BoardFilter.firstMatchingColumnId(columns, query: ' '), isNull);
      expect(
        BoardFilter.firstMatchingColumnId(columns, query: 'missing'),
        isNull,
      );
    });
  });

  group('BoardFilter.songs', () {
    test('filters by key and accidental', () {
      final result = BoardFilter.songs(songs, key: 'C', accidental: 'sharp');

      expect(result.map((song) => song.id), ['2']);
    });

    test('filters flat keys', () {
      final result = BoardFilter.songs(songs, accidental: 'flat');

      expect(result.map((song) => song.id), ['3']);
    });

    test('returns original songs without filters', () {
      expect(BoardFilter.songs(songs), same(songs));
    });

    test('keeps expanded songs that do not match the key filter', () {
      final result = BoardFilter.songs(
        songs,
        key: 'C',
        retainedSongIds: const {'1'},
      );

      expect(result.map((song) => song.id), ['1', '2']);
    });
  });
}
