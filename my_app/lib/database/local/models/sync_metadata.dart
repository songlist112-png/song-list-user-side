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

  /// Local contract version for the materialized board cache.
  int syncVersion = 0;

  /// True only after every initial song page is committed to Isar.
  bool initialSyncComplete = false;

  /// Fixed server watermark used to make a resumed initial pull consistent.
  DateTime? initialSyncUpperBound;

  /// Keyset cursor for the last song page committed to Isar.
  DateTime? songCursorUpdatedAt;
  String? songCursorId;
}
