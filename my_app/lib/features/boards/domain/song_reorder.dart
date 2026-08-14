import '../../../shared/models/song.dart';

/// Applies Flutter's adjusted `onReorderItem` indices to a song list.
List<Song> reorderSongsByIndex(List<Song> songs, int oldIndex, int newIndex) {
  RangeError.checkValidIndex(oldIndex, songs, 'oldIndex');
  RangeError.checkValidIndex(newIndex, songs, 'newIndex');

  final reordered = List<Song>.of(songs);
  final song = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, song);
  return reordered;
}
