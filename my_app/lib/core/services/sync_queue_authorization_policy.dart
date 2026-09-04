import 'dart:convert';

import '../../database/local/models/sync_queue.dart';
import '../../shared/models/song_list.dart';

/// Rejects queued writes that target data outside the active user's ownership.
class SyncQueueAuthorizationPolicy {
  SyncQueueAuthorizationPolicy({
    required this.userId,
    required List<SongList> boards,
  }) {
    for (final board in boards) {
      final ownsBoard = board.ownerId == userId && board.canEdit;
      _ownedBoards[board.id] = ownsBoard;
      for (final column in board.columns) {
        final ownsColumn =
            ownsBoard &&
            column.songs.every(
              (song) =>
                  song.canEdit &&
                  (song.createdBy == null || song.createdBy == userId),
            );
        _ownedColumns[column.id] = ownsColumn;
        for (final song in column.songs) {
          _ownedSongs[song.id] = ownsColumn && song.canEdit;
        }
      }
    }
  }

  final String userId;
  final Map<String, bool> _ownedBoards = {};
  final Map<String, bool> _ownedColumns = {};
  final Map<String, bool> _ownedSongs = {};

  bool rejects(SyncQueue item) {
    final payload = _payload(item);
    final createdBy = payload['created_by'];
    if (createdBy is String && createdBy != userId) return true;
    if (item.operation == 'reorder') {
      return _ownedColumns[payload['column_id'] ?? item.entityId] != true;
    }
    if (item.operation == 'move') {
      return _ownedColumns[payload['source_column_id']] != true ||
          _ownedColumns[payload['destination_column_id']] != true ||
          _ownedSongs[payload['song_id']] != true;
    }
    if (item.entityType == 'boards' &&
        _ownedBoards.containsKey(item.entityId)) {
      return _ownedBoards[item.entityId] != true;
    }
    return false;
  }

  Map<String, dynamic> _payload(SyncQueue item) {
    try {
      if (item.payload == null) return const {};
      final decoded = jsonDecode(item.payload!);
      return decoded is Map
          ? decoded.cast<String, dynamic>()
          : const <String, dynamic>{};
    } on FormatException {
      return const {};
    }
  }
}
