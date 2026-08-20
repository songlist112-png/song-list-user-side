import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../database/local/models/cached_board.dart';
import '../../database/local/models/sync_queue.dart';
import '../../database/remote/models/sync_pull_models.dart';
import '../../features/boards/data/board_codec.dart';
import '../../shared/models/artist.dart';
import '../../shared/models/label.dart';
import '../../shared/models/song.dart';
import '../../shared/models/song_attachment.dart';
import '../../shared/models/song_column.dart';
import '../../shared/models/song_list.dart';

/// Applies remote pages to the denormalized board cache using one Isar write
/// transaction per page. Pending local boards are never overwritten.
class BoardSyncCache {
  BoardSyncCache({required Isar isar, required this.userId})
    : // Keep the conventional public `isar` argument while storage is private.
      // ignore: prefer_initializing_formals
      _isar = isar;

  final Isar _isar;
  final String userId;
  bool _currentUserIsAdmin = false;

  Future<void> applyStructure(
    SyncStructureDelta delta, {
    required bool isInitial,
  }) async {
    _currentUserIsAdmin = delta.currentUserIsAdmin;
    final rows = await _localRows();
    final dirtyIds = await _dirtyBoardIds(rows);
    final boards = {
      for (final row in rows) row.uuid: BoardCodec.decode(row.document),
    };
    final changedIds = <String>{};
    final deletedIds = <String>{};

    if (isInitial) {
      _replaceInitialStructure(delta, boards, dirtyIds, changedIds, deletedIds);
    } else {
      _mergeStructureDelta(delta, boards, dirtyIds, changedIds, deletedIds);
    }
    await _writeChanges(rows, boards, changedIds, deletedIds);
  }

  Future<void> applySongPage(List<Map<String, dynamic>> changes) async {
    if (changes.isEmpty) return;
    final rows = await _localRows();
    final dirtyIds = await _dirtyBoardIds(rows);
    final boards = {
      for (final row in rows) row.uuid: BoardCodec.decode(row.document),
    };
    final changedIds = <String>{};
    for (final row in changes) {
      _applySongChange(row, boards, dirtyIds, changedIds);
    }
    await _writeChanges(rows, boards, changedIds, const {});
  }

  void _replaceInitialStructure(
    SyncStructureDelta delta,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
    Set<String> deletedIds,
  ) {
    final labels = delta.labels.where(_isActive).map(_labelFromRow).toList();
    final artists = delta.artists.where(_isActive).map(_artistFromRow).toList();
    final columnsByBoard = _initialColumns(delta.columns);
    final activeBoardIds = <String>{};
    for (final row in delta.boards.where(_isActive)) {
      final id = row['id'] as String;
      activeBoardIds.add(id);
      if (dirtyIds.contains(id)) continue;
      boards[id] = _boardFromRow(
        row,
        columns: columnsByBoard[id] ?? const [],
        labels: labels,
        artists: artists,
      );
      changedIds.add(id);
    }
    for (final id in boards.keys.toList()) {
      if (!dirtyIds.contains(id) && !activeBoardIds.contains(id)) {
        boards.remove(id);
        deletedIds.add(id);
      }
    }
  }

  void _mergeStructureDelta(
    SyncStructureDelta delta,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
    Set<String> deletedIds,
  ) {
    _applyTombstones(
      delta.tombstones,
      boards,
      dirtyIds,
      changedIds,
      deletedIds,
    );
    for (final row in delta.boards) {
      _mergeBoardRow(row, boards, dirtyIds, changedIds, deletedIds);
    }
    for (final row in delta.columns) {
      _mergeColumnRow(row, boards, dirtyIds, changedIds);
    }
    if (delta.labels.isNotEmpty) {
      _mergeLabels(delta.labels, boards, dirtyIds, changedIds);
    }
    if (delta.artists.isNotEmpty) {
      _mergeArtists(delta.artists, boards, dirtyIds, changedIds);
    }
  }

  void _applyTombstones(
    List<Map<String, dynamic>> rows,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
    Set<String> deletedIds,
  ) {
    for (final row in rows) {
      final type = row['entity_type'] as String;
      final id = row['entity_id'] as String;
      if (type == 'boards' && !dirtyIds.contains(id)) {
        boards.remove(id);
        deletedIds.add(id);
      } else if (type == 'columns') {
        _removeColumn(id, boards, dirtyIds, changedIds);
      } else if (type == 'songs') {
        _removeSong(id, boards, dirtyIds, changedIds);
      } else if (type == 'labels') {
        _removeLabel(id, boards, dirtyIds, changedIds);
      } else if (type == 'artists') {
        _removeArtist(id, boards, dirtyIds, changedIds);
      }
    }
  }

  void _mergeBoardRow(
    Map<String, dynamic> row,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
    Set<String> deletedIds,
  ) {
    final id = row['id'] as String;
    if (dirtyIds.contains(id)) return;
    if (!_isActive(row)) {
      boards.remove(id);
      deletedIds.add(id);
      return;
    }
    final existing = boards[id];
    boards[id] = _boardFromRow(
      row,
      columns: existing?.columns ?? const [],
      labels: existing?.labels ?? const [],
      artists: existing?.artists ?? const [],
    );
    changedIds.add(id);
  }

  void _mergeColumnRow(
    Map<String, dynamic> row,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    final boardId = row['board_id'] as String;
    final board = boards[boardId];
    if (board == null || dirtyIds.contains(boardId)) return;
    final id = row['id'] as String;
    final existing = board.columns.where((item) => item.id == id).firstOrNull;
    final columns = board.columns.where((item) => item.id != id).toList();
    if (_isActive(row)) {
      columns.add(_columnFromRow(row, songs: existing?.songs ?? const []));
    }
    columns.sort((a, b) => a.order.compareTo(b.order));
    boards[boardId] = board.copyWith(columns: columns);
    changedIds.add(boardId);
  }

  void _mergeLabels(
    List<Map<String, dynamic>> changes,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      final labels = {for (final item in entry.value.labels) item.id: item};
      for (final row in changes) {
        final id = row['id'] as String;
        if (_isActive(row)) {
          labels[id] = _labelFromRow(row);
        } else {
          labels.remove(id);
        }
      }
      boards[entry.key] = entry.value.copyWith(labels: labels.values.toList());
      changedIds.add(entry.key);
    }
  }

  void _mergeArtists(
    List<Map<String, dynamic>> changes,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      final artists = {for (final item in entry.value.artists) item.id: item};
      for (final row in changes) {
        final id = row['id'] as String;
        if (_isActive(row)) {
          artists[id] = _artistFromRow(row);
        } else {
          artists.remove(id);
        }
      }
      boards[entry.key] = entry.value.copyWith(
        artists: artists.values.toList(),
      );
      changedIds.add(entry.key);
    }
  }

  void _applySongChange(
    Map<String, dynamic> row,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    final songId = row['id'] as String;
    final sourceBoardId = _boardContainingSong(boards, songId);
    final targetColumnId = row['column_id'] as String?;
    final targetBoardId = targetColumnId == null
        ? null
        : _boardContainingColumn(boards, targetColumnId);
    if ((sourceBoardId != null && dirtyIds.contains(sourceBoardId)) ||
        (targetBoardId != null && dirtyIds.contains(targetBoardId))) {
      return;
    }
    final previous = _songById(boards, songId);
    _removeSong(songId, boards, dirtyIds, changedIds);
    if (!_isActive(row) || targetBoardId == null || targetColumnId == null) {
      return;
    }
    final board = boards[targetBoardId]!;
    final song = _songFromRow(row, previous);
    final position = (row['position'] as num?)?.toInt() ?? 0;
    boards[targetBoardId] = board.copyWith(
      columns: board.columns
          .map((column) {
            if (column.id != targetColumnId) return column;
            final songs = [...column.songs];
            songs.insert(position.clamp(0, songs.length), song);
            return column.copyWith(songs: songs);
          })
          .toList(growable: false),
    );
    changedIds.add(targetBoardId);
  }

  Map<String, List<SongColumn>> _initialColumns(
    List<Map<String, dynamic>> rows,
  ) {
    final result = <String, List<SongColumn>>{};
    for (final row in rows.where(_isActive)) {
      result
          .putIfAbsent(row['board_id'] as String, () => [])
          .add(_columnFromRow(row));
    }
    for (final columns in result.values) {
      columns.sort((a, b) => a.order.compareTo(b.order));
    }
    return result;
  }

  Future<List<CachedBoard>> _localRows() =>
      _isar.cachedBoards.filter().accountIdEqualTo(userId).findAll();

  Future<Set<String>> _dirtyBoardIds(List<CachedBoard> rows) async {
    final pending = await _isar.syncQueues
        .filter()
        .userIdEqualTo(userId)
        .and()
        .statusEqualTo('pending')
        .findAll();
    return {
      for (final row in rows)
        if (pending.any((item) => row.document.contains(item.entityId)))
          row.uuid,
    };
  }

  Future<void> _writeChanges(
    List<CachedBoard> existingRows,
    Map<String, SongList> boards,
    Set<String> changedIds,
    Set<String> deletedIds,
  ) async {
    final existingByUuid = {for (final row in existingRows) row.uuid: row};
    final puts = changedIds
        .where(boards.containsKey)
        .map((id) {
          final board = boards[id]!;
          return (existingByUuid[id] ?? CachedBoard())
            ..uuid = id
            ..cacheKey = '$userId:$id'
            ..accountId = userId
            ..ownerId = board.ownerId
            ..document = BoardCodec.encode(board)
            ..updatedAt = DateTime.now().toUtc();
        })
        .toList(growable: false);
    final deletes = deletedIds
        .map((id) => existingByUuid[id]?.id)
        .whereType<int>()
        .toList(growable: false);
    if (puts.isEmpty && deletes.isEmpty) return;
    await _isar.writeTxn(() async {
      if (puts.isNotEmpty) await _isar.cachedBoards.putAll(puts);
      if (deletes.isNotEmpty) await _isar.cachedBoards.deleteAll(deletes);
    });
  }

  SongList _boardFromRow(
    Map<String, dynamic> row, {
    required List<SongColumn> columns,
    required List<Label> labels,
    required List<Artist> artists,
  }) {
    final ownerId = row['created_by'] as String? ?? '';
    final canEdit = ownerId == userId;
    return SongList(
      id: row['id'] as String,
      ownerId: ownerId,
      name: row['name'] as String,
      columns: columns,
      labels: labels,
      artists: artists,
      showArtist: row['show_artist'] as bool? ?? true,
      showBpm: row['show_bpm'] as bool? ?? false,
      darkMode: row['dark_mode'] as bool? ?? false,
      isPublished: !canEdit,
      canEdit: canEdit,
      creatorType: canEdit && !_currentUserIsAdmin
          ? BoardCreatorType.user
          : BoardCreatorType.admin,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
    );
  }

  Song _songFromRow(Map<String, dynamic> row, Song? previous) {
    final createdBy = row['created_by'] as String?;
    final isOwner = createdBy == userId;
    return Song(
      id: row['id'] as String,
      createdBy: createdBy,
      creatorType: isOwner && !_currentUserIsAdmin
          ? SongCreatorType.user
          : SongCreatorType.admin,
      canEdit: isOwner,
      title: row['title'] as String,
      artistName: row['artist_name'] as String?,
      tempo: row['tempo'] as int?,
      key: row['key_root'] as String?,
      keyType: row['key_type'] as String?,
      labels: (row['label_ids'] as List? ?? const []).cast<String>(),
      lyrics: _optionalText(row['lyrics']),
      attachments: _attachments(row['attachments'], previous),
    );
  }

  List<SongAttachment> _attachments(Object? value, Song? previous) {
    final localById = {
      for (final item in previous?.attachments ?? const <SongAttachment>[])
        if (item.id != null) item.id!: item.localPath,
    };
    return (value as List? ?? const [])
        .map((item) {
          final row = (item as Map).cast<String, dynamic>();
          final storagePath = row['file_url'] as String;
          final storedName = storagePath.split('/').last;
          final id = row['id'] as String;
          return SongAttachment(
            id: id,
            name: storedName.contains('__')
                ? storedName.substring(storedName.indexOf('__') + 2)
                : storedName,
            storagePath: storagePath,
            localPath: localById[id],
            fileType: row['file_type'] as String,
            fileSize: (row['file_size'] as num).toInt(),
          );
        })
        .toList(growable: false);
  }

  Label _labelFromRow(Map<String, dynamic> row) => Label(
    id: row['id'] as String,
    createdBy: row['created_by'] as String?,
    name: row['name'] as String,
    color: _colorFromHex(row['color'] as String),
    canEdit: row['created_by'] == userId,
  );

  Artist _artistFromRow(Map<String, dynamic> row) => Artist(
    id: row['id'] as String,
    createdBy: row['created_by'] as String?,
    name: row['name'] as String,
    canEdit: row['created_by'] == userId,
  );

  static SongColumn _columnFromRow(
    Map<String, dynamic> row, {
    List<Song> songs = const [],
  }) => SongColumn(
    id: row['id'] as String,
    title: row['title'] as String,
    order: row['position'] as int? ?? 0,
    songs: songs,
  );

  static bool _isActive(Map<String, dynamic> row) =>
      (row['deleted'] as bool?) != true;

  static String? _optionalText(Object? value) {
    final text = value as String?;
    return text == null || text.isEmpty ? null : text;
  }

  static Color _colorFromHex(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  static String? _boardContainingColumn(
    Map<String, SongList> boards,
    String columnId,
  ) {
    for (final entry in boards.entries) {
      if (entry.value.columns.any((column) => column.id == columnId)) {
        return entry.key;
      }
    }
    return null;
  }

  static String? _boardContainingSong(
    Map<String, SongList> boards,
    String songId,
  ) {
    for (final entry in boards.entries) {
      if (entry.value.columns.any(
        (column) => column.songs.any((song) => song.id == songId),
      )) {
        return entry.key;
      }
    }
    return null;
  }

  static Song? _songById(Map<String, SongList> boards, String songId) {
    for (final board in boards.values) {
      for (final column in board.columns) {
        for (final song in column.songs) {
          if (song.id == songId) return song;
        }
      }
    }
    return null;
  }

  static void _removeSong(
    String songId,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      final hasSong = entry.value.columns.any(
        (column) => column.songs.any((song) => song.id == songId),
      );
      if (!hasSong) continue;
      boards[entry.key] = entry.value.copyWith(
        columns: entry.value.columns
            .map(
              (column) => column.copyWith(
                songs: column.songs
                    .where((song) => song.id != songId)
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
      changedIds.add(entry.key);
    }
  }

  static void _removeColumn(
    String columnId,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      if (!entry.value.columns.any((column) => column.id == columnId)) continue;
      boards[entry.key] = entry.value.copyWith(
        columns: entry.value.columns
            .where((column) => column.id != columnId)
            .toList(growable: false),
      );
      changedIds.add(entry.key);
    }
  }

  static void _removeLabel(
    String labelId,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      boards[entry.key] = entry.value.copyWith(
        labels: entry.value.labels
            .where((label) => label.id != labelId)
            .toList(growable: false),
      );
      changedIds.add(entry.key);
    }
  }

  static void _removeArtist(
    String artistId,
    Map<String, SongList> boards,
    Set<String> dirtyIds,
    Set<String> changedIds,
  ) {
    for (final entry in boards.entries.toList()) {
      if (dirtyIds.contains(entry.key)) continue;
      boards[entry.key] = entry.value.copyWith(
        artists: entry.value.artists
            .where((artist) => artist.id != artistId)
            .toList(growable: false),
      );
      changedIds.add(entry.key);
    }
  }
}
