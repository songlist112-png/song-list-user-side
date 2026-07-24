import 'song.dart';

class SongColumn {
  final String id;
  final String title;
  final List<Song> songs;
  final int order;

  const SongColumn({
    required this.id,
    required this.title,
    this.songs = const [],
    this.order = 0,
  });

  SongColumn copyWith({
    String? id,
    String? title,
    List<Song>? songs,
    int? order,
  }) {
    return SongColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      songs: songs ?? this.songs,
      order: order ?? this.order,
    );
  }
}
