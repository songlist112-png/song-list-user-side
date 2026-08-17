import 'package:isar_community/isar.dart';

part 'song.g.dart';

@collection
class SongCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;

  late String artist;

  int? tempo;

  // C, C#, D, D#, E, F, F#, G, G#, A, A#, B
  String? keyRoot;

  // Major, Minor
  String? keyType;

  List<String> labels = [];

  late String lyrics;

  bool isPublished = false;

  late DateTime createdAt;

  late DateTime updatedAt;

  bool deleted = false;
}
