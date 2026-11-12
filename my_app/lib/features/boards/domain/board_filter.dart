import '../../../shared/models/song.dart';
import '../../../shared/models/song_column.dart';

abstract final class BoardFilter {
  static String? firstMatchingColumnId(
    List<SongColumn> columns, {
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return null;

    for (final column in columns) {
      if (column.title.toLowerCase().contains(normalizedQuery) ||
          column.songs.any((song) => _matchesQuery(song, normalizedQuery))) {
        return column.id;
      }
    }
    return null;
  }

  static List<SongColumn> columns(
    List<SongColumn> columns, {
    required String query,
    Set<String> retainedSongIds = const <String>{},
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return columns;

    return columns
        .expand((column) {
          if (column.title.toLowerCase().contains(normalizedQuery)) {
            return [column];
          }

          final songs = column.songs
              .where(
                (song) =>
                    retainedSongIds.contains(song.id) ||
                    _matchesQuery(song, normalizedQuery),
              )
              .toList(growable: false);
          return songs.isEmpty
              ? const <SongColumn>[]
              : [column.copyWith(songs: songs)];
        })
        .toList(growable: false);
  }

  static List<Song> songs(
    List<Song> songs, {
    String? key,
    String? accidental,
    Set<String> retainedSongIds = const <String>{},
  }) {
    if (key == null && accidental == null) return songs;

    return songs
        .where((song) {
          if (retainedSongIds.contains(song.id)) return true;
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
