import 'package:isar_community/isar.dart';

part 'personal_song_edit.g.dart';

@collection
class PersonalSongEditRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cacheKey;

  @Index()
  late String userId;

  @Index()
  late String songId;

  late String editId;
  late String lyrics;
  late DateTime clientUpdatedAt;
  DateTime? serverUpdatedAt;
  bool deleted = false;
}
