import 'package:isar_community/isar.dart';

import 'song.dart';

part 'attachment.g.dart';

@collection
class Attachment {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String fileUrl;

  late String fileType;

  late int fileSize;

  late DateTime createdAt;

  /// Relationship: Many Attachments -> One Song
  final song = IsarLink<SongCollection>();
}
