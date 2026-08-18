import 'dart:convert';

import '../../database/local/models/sync_queue.dart';
import '../../shared/models/song_list.dart';

/// Resolves the final desired song order from a chronological sync batch.
///
/// Later operations intentionally supersede earlier expectations for the same
/// column. This prevents a valid move-back sequence from being compared with
/// an intermediate server arrangement.
class SongArrangementConfirmation {
  SongArrangementConfirmation._({
    required this.queueIds,
    required this._expectations,
  });

  factory SongArrangementConfirmation.from(List<SyncQueue> items) {
    final queueIds = <int>{};
    final expectations = <String, _ColumnExpectation>{};
    for (final item in items) {
      if (!_isArrangement(item)) continue;
      queueIds.add(item.id);
      final payload = _payload(item);
      if (item.operation == 'reorder') {
        _setExpectation(
          expectations,
          item,
          payload['column_id'],
          payload['ids'],
        );
        continue;
      }
      _setExpectation(
        expectations,
        item,
        payload['source_column_id'],
        payload['source_song_ids'],
      );
      _setExpectation(
        expectations,
        item,
        payload['destination_column_id'],
        payload['destination_song_ids'],
      );
    }
    return SongArrangementConfirmation._(
      queueIds: queueIds,
      expectations: expectations,
    );
  }

  final Set<int> queueIds;
  final Map<String, _ColumnExpectation> _expectations;

  bool get isEmpty => _expectations.isEmpty;

  bool matches(List<SongList> boards) => rejectedQueueIds(boards).isEmpty;

  Set<int> rejectedQueueIds(List<SongList> boards) {
    final rejected = <int>{};
    for (final entry in _expectations.entries) {
      final actual = _ownedSongIds(boards, entry.key);
      if (!_sameOrder(actual, entry.value.songIds)) {
        rejected.add(entry.value.queueId);
      }
    }
    return rejected;
  }

  static bool _isArrangement(SyncQueue item) =>
      item.operation == 'reorder' || item.operation == 'move';

  static Map<String, dynamic> _payload(SyncQueue item) {
    final value = item.payload;
    if (value == null) throw const FormatException('Missing sync payload');
    return (jsonDecode(value) as Map).cast<String, dynamic>();
  }

  static void _setExpectation(
    Map<String, _ColumnExpectation> expectations,
    SyncQueue item,
    Object? columnId,
    Object? songIds,
  ) {
    if (columnId is! String || songIds is! List) {
      throw const FormatException('Invalid song arrangement payload');
    }
    expectations[columnId] = _ColumnExpectation(
      queueId: item.id,
      songIds: songIds.cast<String>(),
    );
  }

  static List<String> _ownedSongIds(List<SongList> boards, String columnId) {
    for (final board in boards) {
      for (final column in board.columns) {
        if (column.id != columnId) continue;
        return column.songs
            .where((song) => song.canEdit)
            .map((song) => song.id)
            .toList(growable: false);
      }
    }
    return const [];
  }

  static bool _sameOrder(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}

class _ColumnExpectation {
  const _ColumnExpectation({required this.queueId, required this.songIds});

  final int queueId;
  final List<String> songIds;
}
