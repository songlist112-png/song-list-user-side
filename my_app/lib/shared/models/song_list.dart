import 'song_column.dart';
import 'artist.dart';
import 'label.dart';

enum BoardCreatorType { admin, user }

class SongList {
  final String id;
  final String ownerId;
  final String name;
  final List<SongColumn> columns;
  final List<Artist> artists;
  final List<Label> labels;
  final bool showArtist;
  final bool showBpm;
  final bool darkMode;
  final bool isPublished;
  final bool canEdit;
  final BoardCreatorType creatorType;
  final DateTime createdAt;

  const SongList({
    required this.id,
    required this.ownerId,
    required this.name,
    this.columns = const [],
    this.artists = const [],
    this.labels = const [],
    this.showArtist = true,
    this.showBpm = false,
    this.darkMode = false,
    this.isPublished = false,
    this.canEdit = true,
    this.creatorType = BoardCreatorType.user,
    required this.createdAt,
  });

  SongList copyWith({
    String? id,
    String? ownerId,
    String? name,
    List<SongColumn>? columns,
    List<Artist>? artists,
    List<Label>? labels,
    bool? showArtist,
    bool? showBpm,
    bool? darkMode,
    bool? isPublished,
    bool? canEdit,
    BoardCreatorType? creatorType,
    DateTime? createdAt,
  }) {
    return SongList(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      columns: columns ?? this.columns,
      artists: artists ?? this.artists,
      labels: labels ?? this.labels,
      showArtist: showArtist ?? this.showArtist,
      showBpm: showBpm ?? this.showBpm,
      darkMode: darkMode ?? this.darkMode,
      isPublished: isPublished ?? this.isPublished,
      canEdit: canEdit ?? this.canEdit,
      creatorType: creatorType ?? this.creatorType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
