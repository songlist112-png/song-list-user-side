import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/sync_queue_authorization_policy.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';
import 'package:my_app/shared/models/song_list.dart';

void main() {
  const userId = '279347fe-dd7c-4158-833d-e556c981addf';
  final ownedBoard = SongList(
    id: 'board',
    ownerId: userId,
    name: 'Mine',
    createdAt: DateTime.utc(2026),
    columns: const [
      SongColumn(
        id: 'source',
        title: 'Source',
        songs: [Song(id: 'song', title: 'Song', createdBy: userId)],
      ),
      SongColumn(id: 'destination', title: 'Destination'),
    ],
  );

  test('rejects supplied foreign-owned failed board mutation', () {
    final policy = SyncQueueAuthorizationPolicy(
      userId: userId,
      boards: [ownedBoard],
    );
    final item = _item(
      entityType: 'boards',
      entityId: 'foreign-board',
      operation: 'upsert',
      payload: {
        'id': 'foreign-board',
        'created_by': '81f0fcf2-ce79-4343-bb3f-cc4f90d14d8b',
      },
    )..status = 'failed';

    expect(policy.rejects(item), isTrue);
  });

  test('allows owned reorder and move mutations', () {
    final policy = SyncQueueAuthorizationPolicy(
      userId: userId,
      boards: [ownedBoard],
    );
    final reorder = _item(
      entityType: 'songs',
      entityId: 'source',
      operation: 'reorder',
      payload: {
        'column_id': 'source',
        'ids': ['song'],
      },
    );
    final move = _item(
      entityType: 'songs',
      entityId: 'song',
      operation: 'move',
      payload: {
        'song_id': 'song',
        'source_column_id': 'source',
        'destination_column_id': 'destination',
        'source_song_ids': <String>[],
        'destination_song_ids': ['song'],
      },
    );

    expect(policy.rejects(reorder), isFalse);
    expect(policy.rejects(move), isFalse);
  });

  test('malformed legacy payload does not crash authorization cleanup', () {
    final policy = SyncQueueAuthorizationPolicy(
      userId: userId,
      boards: [ownedBoard],
    );
    final item = _item(
      entityType: 'artists',
      entityId: 'artist',
      operation: 'upsert',
      payload: const {},
    )..payload = '[]';

    expect(policy.rejects(item), isFalse);
  });
}

SyncQueue _item({
  required String entityType,
  required String entityId,
  required String operation,
  required Map<String, dynamic> payload,
}) => SyncQueue()
  ..entityType = entityType
  ..entityId = entityId
  ..operation = operation
  ..payload = jsonEncode(payload)
  ..status = 'pending'
  ..createdAt = DateTime.utc(2026)
  ..userId = '279347fe-dd7c-4158-833d-e556c981addf';
