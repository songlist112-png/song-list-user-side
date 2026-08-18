import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/database/remote/datasources/song_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  test(
    'successful reorder RPC is left to canonical sync confirmation',
    () async {
      final client = _MockSupabaseClient();
      String? receivedColumnId;
      List<String>? receivedIds;
      final dataSource = SyncRemoteDataSource(
        client: client,
        reorderSongsRpc: ({required columnId, required ids}) async {
          receivedColumnId = columnId;
          receivedIds = ids;
        },
      );
      final item = SyncQueue()
        ..entityType = 'songs'
        ..entityId = 'column-id'
        ..operation = 'reorder'
        ..payload = jsonEncode({
          'column_id': 'column-id',
          'ids': ['song-1', 'song-2'],
        })
        ..status = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..userId = 'user-id';

      await expectLater(dataSource.apply(item), completes);

      expect(receivedColumnId, 'column-id');
      expect(receivedIds, ['song-1', 'song-2']);
    },
  );
}
