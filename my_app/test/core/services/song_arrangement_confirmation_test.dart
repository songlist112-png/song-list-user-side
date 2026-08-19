import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/song_arrangement_confirmation.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';
import 'package:my_app/shared/models/song_list.dart';

void main() {
  test('confirms the final move when an earlier reorder is superseded', () {
    final reorder = _queue(1, 'column-a', 'reorder', {
      'column_id': 'column-a',
      'ids': ['song-2', 'song-1'],
    });
    final move = _queue(2, 'song-1', 'move', {
      'source_column_id': 'column-a',
      'destination_column_id': 'column-b',
      'source_song_ids': ['song-2'],
      'destination_song_ids': ['song-1'],
    });

    final confirmation = SongArrangementConfirmation.from([reorder, move]);

    expect(confirmation.matches(_board(a: ['song-2'], b: ['song-1'])), isTrue);
    expect(confirmation.rejectedQueueIds(_board(a: [], b: [])), {2});
  });

  test('confirms moving a song away and back in one sync batch', () {
    final moveAway = _queue(1, 'song-1', 'move', {
      'source_column_id': 'column-a',
      'destination_column_id': 'column-b',
      'source_song_ids': ['song-2'],
      'destination_song_ids': ['song-1'],
    });
    final moveBack = _queue(2, 'song-1', 'move', {
      'source_column_id': 'column-b',
      'destination_column_id': 'column-a',
      'source_song_ids': <String>[],
      'destination_song_ids': ['song-2', 'song-1'],
    });

    final confirmation = SongArrangementConfirmation.from([moveAway, moveBack]);

    expect(
      confirmation.matches(_board(a: ['song-2', 'song-1'], b: [])),
      isTrue,
    );
    expect(
      confirmation.matchesOrders({
        'column-a': ['song-2', 'song-1'],
        'column-b': <String>[],
      }),
      isTrue,
    );
    expect(confirmation.queueIds, {1, 2});
  });

  test('admin songs do not affect personal arrangement confirmation', () {
    final reorder = _queue(1, 'column-a', 'reorder', {
      'column_id': 'column-a',
      'ids': ['song-2', 'song-1'],
    });
    final board = _board(a: ['song-2', 'song-1'], b: [], adminSongInA: true);

    expect(SongArrangementConfirmation.from([reorder]).matches(board), isTrue);
  });
}

SyncQueue _queue(
  int id,
  String entityId,
  String operation,
  Map<String, dynamic> payload,
) => SyncQueue()
  ..id = id
  ..entityType = 'songs'
  ..entityId = entityId
  ..operation = operation
  ..payload = jsonEncode(payload)
  ..status = 'pending'
  ..createdAt = DateTime.utc(2026)
  ..userId = 'user';

List<SongList> _board({
  required List<String> a,
  required List<String> b,
  bool adminSongInA = false,
}) => [
  SongList(
    id: 'board',
    ownerId: 'user',
    name: 'Board',
    createdAt: DateTime.utc(2026),
    columns: [
      SongColumn(
        id: 'column-a',
        title: 'A',
        songs: [
          if (adminSongInA)
            const Song(id: 'admin-song', title: 'Admin', canEdit: false),
          ...a.map((id) => Song(id: id, title: id)),
        ],
      ),
      SongColumn(
        id: 'column-b',
        title: 'B',
        songs: b.map((id) => Song(id: id, title: id)).toList(),
      ),
    ],
  ),
];
