import 'package:isar_community/isar.dart';

part 'sync_metadata.g.dart';

@collection
class SyncMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  DateTime? lastSync;
  DateTime? lastSuccessAt;
  String? lastError;
}
