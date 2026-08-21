import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/database/remote/datasources/song_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  test(
    'successful reorder RPC is authoritative for repeated alternating orders',
    () async {
      final client = _MockSupabaseClient();
      final receivedOrders = <List<String>>[];
      final dataSource = SyncRemoteDataSource(
        client: client,
        reorderSongsRpc: ({required columnId, required ids}) async {
          expect(columnId, 'column-id');
          receivedOrders.add(List<String>.of(ids));
        },
      );
      for (var cycle = 0; cycle < 5; cycle++) {
        await dataSource.apply(_reorder(['song-2', 'song-1']));
        await dataSource.apply(_reorder(['song-1', 'song-2']));
      }

      expect(receivedOrders, hasLength(10));
      expect(receivedOrders.last, ['song-1', 'song-2']);
    },
  );
}

SyncQueue _reorder(List<String> ids) => SyncQueue()
  ..entityType = 'songs'
  ..entityId = 'column-id'
  ..operation = 'reorder'
  ..payload = jsonEncode({'column_id': 'column-id', 'ids': ids})
  ..status = 'pending'
  ..createdAt = DateTime.utc(2026)
  ..userId = 'user-id';
