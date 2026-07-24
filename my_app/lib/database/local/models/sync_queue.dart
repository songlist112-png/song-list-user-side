import 'package:isar/isar.dart';

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
}
