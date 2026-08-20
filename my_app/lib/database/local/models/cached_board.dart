import 'package:isar_community/isar.dart';

part 'cached_board.g.dart';

/// Locally materialized board aggregate. UI reads only this collection.
@collection
class CachedBoard {
  Id id = Isar.autoIncrement;

  @Index()
  late String uuid;

  @Index(unique: true, replace: true)
  late String cacheKey;

  @Index()
  late String accountId;

  @Index()
  late String ownerId;

  /// JSON-encoded [SongList] graph.
  late String document;

  late DateTime updatedAt;
}
