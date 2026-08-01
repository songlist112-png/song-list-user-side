import '../../../shared/models/song.dart';
import '../../../shared/models/song_column.dart';

abstract final class BoardFilter {
  static List<SongColumn> columns(
    List<SongColumn> columns, {
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return columns;

    return columns
        .expand((column) {
          if (column.title.toLowerCase().contains(normalizedQuery)) {
            return [column];
          }

          final songs = column.songs
              .where((song) => _matchesQuery(song, normalizedQuery))
              .toList(growable: false);
          return songs.isEmpty
              ? const <SongColumn>[]
              : [column.copyWith(songs: songs)];
        })
        .toList(growable: false);
  }

  static List<Song> songs(List<Song> songs, {String? key, String? accidental}) {
    if (key == null && accidental == null) return songs;

    return songs
        .where((song) {
          final songKey = song.key;
          if (songKey == null || songKey.isEmpty) return false;
          if (key != null && !songKey.startsWith(key)) return false;
          return switch (accidental) {
            'flat' => songKey.contains('b'),
            'sharp' => songKey.contains('#'),
            _ => true,
          };
        })
        .toList(growable: false);
  }

  static bool _matchesQuery(Song song, String query) =>
      song.title.toLowerCase().contains(query) ||
      (song.artistName?.toLowerCase().contains(query) ?? false) ||
      (song.key?.toLowerCase().contains(query) ?? false);
}
