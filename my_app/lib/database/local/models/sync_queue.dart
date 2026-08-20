import 'package:isar_community/isar.dart';

part 'sync_queue.g.dart';

@collection
class SyncQueue {
  Id id = Isar.autoIncrement;

  late String entityType;

  late String entityId;

  late String operation;

  String? payload;

  late String status;

  late DateTime createdAt;

  @Index()
  late String userId;

  int attempts = 0;
  DateTime? nextAttemptAt;
  String? lastError;
}
