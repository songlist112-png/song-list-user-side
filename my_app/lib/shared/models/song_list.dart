import 'song_column.dart';
import 'artist.dart';
import 'label.dart';

class SongList {
  final String id;
  final String name;
  final List<SongColumn> columns;
  final List<Artist> artists;
  final List<Label> labels;
  final bool showArtist;
  final bool showBpm;
  final bool darkMode;
  final DateTime createdAt;

  const SongList({
    required this.id,
    required this.name,
    this.columns = const [],
    this.artists = const [],
    this.labels = const [],
    this.showArtist = true,
    this.showBpm = false,
    this.darkMode = false,
    required this.createdAt,
  });

  SongList copyWith({
    String? id,
    String? name,
    List<SongColumn>? columns,
    List<Artist>? artists,
    List<Label>? labels,
    bool? showArtist,
    bool? showBpm,
    bool? darkMode,
    DateTime? createdAt,
  }) {
    return SongList(
      id: id ?? this.id,
      name: name ?? this.name,
      columns: columns ?? this.columns,
      artists: artists ?? this.artists,
      labels: labels ?? this.labels,
      showArtist: showArtist ?? this.showArtist,
      showBpm: showBpm ?? this.showBpm,
      darkMode: darkMode ?? this.darkMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
