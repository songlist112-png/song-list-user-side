import '../../database/local/models/sync_queue.dart';

typedef ApplySyncQueueItem = Future<void> Function(SyncQueue item);
typedef RecordSyncQueueFailure =
    Future<void> Function(SyncQueue item, Object error, StackTrace stackTrace);

/// Uploads independent queue items without one failure blocking later items.
class SyncQueueBatchProcessor {
  const SyncQueueBatchProcessor._();

  static Future<List<SyncQueue>> process({
    required List<SyncQueue> items,
    required ApplySyncQueueItem apply,
    required RecordSyncQueueFailure onFailure,
    required void Function(DateTime nextAttemptAt) onDeferred,
    DateTime? now,
  }) async {
    final applied = <SyncQueue>[];
    final currentTime = now ?? DateTime.now().toUtc();
    for (final item in items) {
      final nextAttempt = item.nextAttemptAt;
      if (nextAttempt != null && nextAttempt.isAfter(currentTime)) {
        onDeferred(nextAttempt);
        continue;
      }
      try {
        await apply(item);
        applied.add(item);
      } catch (error, stackTrace) {
        await onFailure(item, error, stackTrace);
      }
    }
    return applied;
  }
}
