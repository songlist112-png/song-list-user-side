import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/sync_queue_batch_processor.dart';
import 'package:my_app/database/local/models/sync_queue.dart';

void main() {
  test('failed item does not block later independent uploads', () async {
    final attempted = <String>[];
    final failures = <String>[];
    final items = ['first', 'broken', 'last'].map(_item).toList();

    final applied = await SyncQueueBatchProcessor.process(
      items: items,
      apply: (item) async {
        attempted.add(item.entityId);
        if (item.entityId == 'broken') throw StateError('RLS denied');
      },
      onFailure: (item, _, _) async => failures.add(item.entityId),
      onDeferred: (_) {},
      now: DateTime.utc(2026),
    );

    expect(attempted, ['first', 'broken', 'last']);
    expect(applied.map((item) => item.entityId), ['first', 'last']);
    expect(failures, ['broken']);
  });
}

SyncQueue _item(String id) => SyncQueue()
  ..entityType = 'artists'
  ..entityId = id
  ..operation = 'upsert'
  ..status = 'pending'
  ..createdAt = DateTime.utc(2026)
  ..userId = 'user';
