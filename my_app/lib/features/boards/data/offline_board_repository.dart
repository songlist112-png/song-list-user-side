import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../database/local/models/cached_board.dart';
import '../../../database/local/models/personal_song_edit.dart';
import '../../../database/local/models/sync_queue.dart';
import '../../../shared/models/artist.dart';
import '../../../shared/models/label.dart';
import '../../../shared/models/song.dart';
import '../../../shared/models/song_attachment.dart';
import '../../../shared/models/song_column.dart';
import '../../../shared/models/song_list.dart';
import '../../../shared/utils/media_type.dart';
import 'board_codec.dart';
import 'board_repository.dart';

/// Offline-first repository. Every domain read/write is an Isar operation.
/// Network I/O belongs exclusively to SyncService.
class OfflineBoardRepository implements BoardRepository {
  OfflineBoardRepository({
    required Isar isar,
    required this.userId,
    required this.downloadRemoteAttachment,
    this.onSyncNeeded,
  }) : // Isar stays private; public constructor keeps conventional `isar` name.
       // ignore: prefer_initializing_formals
       _isar = isar,
       super();

  final Isar _isar;
  final String? Function() userId;
  final Future<Uint8List> Function(SongAttachment) downloadRemoteAttachment;
  final void Function()? onSyncNeeded;
  final Uuid _uuid = const Uuid();
  Future<void> _reorderTail = Future<void>.value();
  String? _activeBoardId;

  String get _requiredUserId {
    final value = userId();
    if (value == null) throw StateError('Authentication required');
    return value;
  }

  @override
  Stream<void> watchChanges() {
    final controller = StreamController<void>();
    final subscriptions = <StreamSubscription<void>>[];
    controller.onListen = () {
      subscriptions.addAll([
        _isar.cachedBoards
            .filter()
            .accountIdEqualTo(_requiredUserId)
            .watchLazy()
            .listen(controller.add),
        _isar.personalSongEditRecords
            .filter()
            .userIdEqualTo(_requiredUserId)
            .watchLazy()
            .listen(controller.add),
      ]);
    };
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    return controller.stream;
  }

  @override
  Future<List<SongList>> fetchBoards() async {
    final rows = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(_requiredUserId)
        .findAll();
    final edits = await _personalEditsBySong();
    final boards = rows
        .map(
          (row) =>
              _overlayPersonalEdits(BoardCodec.decode(row.document), edits),
        )
        .toList();
    boards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return boards;
  }

  @override
  Future<SongList> fetchBoard(String id) async {
    _activeBoardId = id;
    final row = await _isar.cachedBoards
        .filter()
        .cacheKeyEqualTo('$_requiredUserId:$id')
        .findFirst();
    if (row == null) throw StateError('Board not available offline');
    return _overlayPersonalEdits(
      BoardCodec.decode(row.document),
      await _personalEditsBySong(),
    );
  }

  @override
  Future<SongList> createBoard(String name) async {
    final now = DateTime.now().toUtc();
    final board = SongList(
      id: _uuid.v4(),
      ownerId: _requiredUserId,
      name: name.trim(),
      createdAt: now,
    );
    await _saveAndQueue(
      board,
      entityType: 'boards',
      entityId: board.id,
      operation: 'upsert',
      payload: _boardPayload(board),
    );
    return board;
  }

  @override
  Future<void> updateBoard(SongList board) => _saveAndQueue(
    board,
    entityType: 'boards',
    entityId: board.id,
    operation: 'upsert',
    payload: _boardPayload(board),
  );

  @override
  Future<void> deleteBoard(String id) async {
    final row = await _findBoardRow(id);
    await _isar.writeTxn(() async {
      await _isar.cachedBoards.delete(row.id);
      await _putQueue('boards', id, 'delete', const {});
    });
    onSyncNeeded?.call();
  }

  @override
  Future<SongColumn> createColumn(
    String boardId,
    String title,
    int position,
  ) async {
    final column = SongColumn(
      id: _uuid.v4(),
      title: title.trim(),
      order: position,
    );
    await _mutate(
      boardId,
      (board) => board.copyWith(columns: [...board.columns, column]),
      entityType: 'columns',
      entityId: column.id,
      operation: 'upsert',
      payload: {
        'id': column.id,
        'board_id': boardId,
        'created_by': _requiredUserId,
        'title': column.title,
        'position': column.order,
      },
    );
    return column;
  }

  @override
  Future<void> updateColumn(SongColumn column) async {
    final board = await _boardContainingColumn(column.id);
    await _mutate(
      board.id,
      (value) => value.copyWith(
        columns: value.columns
            .map((item) => item.id == column.id ? column : item)
            .toList(),
      ),
      entityType: 'columns',
      entityId: column.id,
      operation: 'upsert',
      payload: {
        'id': column.id,
        'board_id': board.id,
        'created_by': board.ownerId,
        'title': column.title.trim(),
        'position': column.order,
      },
    );
  }

  @override
  Future<void> deleteColumn(String id) async {
    final board = await _boardContainingColumn(id);
    await _mutate(
      board.id,
      (value) => value.copyWith(
        columns: value.columns.where((column) => column.id != id).toList(),
      ),
      entityType: 'columns',
      entityId: id,
      operation: 'delete',
      payload: const {},
    );
  }

  @override
  Future<Song> createSong(String columnId, Song song, int position) async {
    final board = await _boardContainingColumn(columnId);
    final saved = _withAttachmentIds(
      song.copyWith(
        id: _uuid.v4(),
        createdBy: _requiredUserId,
        creatorType: SongCreatorType.user,
        canEdit: true,
      ),
    );
    await _mutate(
      board.id,
      (value) => value.copyWith(
        columns: value.columns.map((column) {
          if (column.id != columnId) return column;
          final songs = [...column.songs];
          songs.insert(position.clamp(0, songs.length), saved);
          return column.copyWith(songs: songs);
        }).toList(),
      ),
      entityType: 'songs',
      entityId: saved.id,
      operation: 'upsert',
      payload: _songPayload(saved, columnId, position),
    );
    return saved;
  }

  @override
  Future<Song> updateSong(Song song) async {
    final saved = _withAttachmentIds(song);
    final location = await _songLocation(saved.id);
    await _mutate(
      location.$1.id,
      (board) => board.copyWith(
        columns: board.columns
            .map(
              (column) => column.copyWith(
                songs: column.songs
                    .map((item) => item.id == saved.id ? saved : item)
                    .toList(),
              ),
            )
            .toList(),
      ),
      entityType: 'songs',
      entityId: saved.id,
      operation: 'upsert',
      payload: _songPayload(saved, location.$2.id, location.$3),
    );
    return saved;
  }

  @override
  Future<void> deleteSong(String id) async {
    final location = await _songLocation(id);
    await _mutate(
      location.$1.id,
      (board) => board.copyWith(
        columns: board.columns
            .map(
              (column) => column.copyWith(
                songs: column.songs.where((song) => song.id != id).toList(),
              ),
            )
            .toList(),
      ),
      entityType: 'songs',
      entityId: id,
      operation: 'delete',
      payload: const {},
    );
  }

  @override
  Future<void> reorderSongs(List<Song> songs) async {
    if (songs.isEmpty) return;
    final snapshot = List<Song>.unmodifiable(songs);
    final operation = _reorderTail.then((_) => _persistSongOrder(snapshot));
    _reorderTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    await operation;
    onSyncNeeded?.call();
  }

  @override
  Future<void> moveSong(String songId, String destinationColumnId) async {
    final operation = _reorderTail.then(
      (_) => _persistSongMove(songId, destinationColumnId),
    );
    _reorderTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    await operation;
    onSyncNeeded?.call();
  }

  Future<void> _persistSongMove(
    String songId,
    String destinationColumnId,
  ) async {
    final source = await _songLocation(songId);
    final board = source.$1;
    final sourceColumn = source.$2;
    if (!board.canEdit) {
      throw StateError('Only songs on your board can be moved');
    }
    final song = sourceColumn.songs.firstWhere((item) => item.id == songId);
    if (!song.canEdit || sourceColumn.songs.any((item) => !item.canEdit)) {
      throw StateError('Only user-owned songs can be moved');
    }
    if (sourceColumn.id == destinationColumnId) return;

    final destinationColumn = board.columns.firstWhere(
      (column) => column.id == destinationColumnId,
      orElse: () => throw StateError('Destination column not found'),
    );
    if (destinationColumn.songs.any((item) => !item.canEdit)) {
      throw StateError('Cannot move songs into an admin-song column');
    }
    final sourceSongs = sourceColumn.songs
        .where((item) => item.id != songId)
        .toList(growable: false);
    final destinationSongs = [...destinationColumn.songs, song];

    await _mutate(
      board.id,
      (value) => value.copyWith(
        columns: value.columns
            .map(
              (column) => switch (column.id) {
                final id when id == sourceColumn.id => column.copyWith(
                  songs: sourceSongs,
                ),
                final id when id == destinationColumn.id => column.copyWith(
                  songs: destinationSongs,
                ),
                _ => column,
              },
            )
            .toList(growable: false),
      ),
      entityType: 'songs',
      entityId: songId,
      operation: 'move',
      payload: {
        'song_id': songId,
        'source_column_id': sourceColumn.id,
        'destination_column_id': destinationColumn.id,
        'source_song_ids': sourceSongs.map((item) => item.id).toList(),
        'destination_song_ids': destinationSongs
            .map((item) => item.id)
            .toList(),
      },
    );
  }

  Future<void> _persistSongOrder(List<Song> songs) async {
    final location = await _songLocation(songs.first.id);
    final currentSongs = location.$2.songs;
    if (currentSongs.any((song) => !song.canEdit)) {
      throw StateError('Only user-owned songs can be reordered');
    }
    final ids = songs.map((song) => song.id).toList();
    final currentIds = currentSongs.map((song) => song.id).toSet();
    if (ids.toSet().length != ids.length ||
        ids.length != currentIds.length ||
        !currentIds.containsAll(ids)) {
      throw StateError('Reorder must contain every song exactly once');
    }
    await _mutate(
      location.$1.id,
      (board) => board.copyWith(
        columns: board.columns
            .map(
              (column) => column.id == location.$2.id
                  ? column.copyWith(songs: songs)
                  : column,
            )
            .toList(),
      ),
      entityType: 'songs',
      entityId: location.$2.id,
      operation: 'reorder',
      payload: {'column_id': location.$2.id, 'ids': ids},
    );
  }

  @override
  Future<Artist> createArtist(String name) async {
    final board = await _requireActiveBoard();
    final artist = Artist(
      id: _uuid.v4(),
      createdBy: _requiredUserId,
      name: name.trim(),
    );
    await _mutate(
      board.id,
      (value) => value.copyWith(artists: [...value.artists, artist]),
      entityType: 'artists',
      entityId: artist.id,
      operation: 'upsert',
      payload: _artistPayload(artist),
    );
    return artist;
  }

  @override
  Future<Artist> updateArtist(Artist artist) async {
    final board = await _boardContainingArtist(artist.id);
    await _mutate(
      board.id,
      (value) => value.copyWith(
        artists: value.artists
            .map((item) => item.id == artist.id ? artist : item)
            .toList(),
      ),
      entityType: 'artists',
      entityId: artist.id,
      operation: 'upsert',
      payload: _artistPayload(artist),
    );
    return artist;
  }

  @override
  Future<void> deleteArtist(String id) async {
    final board = await _boardContainingArtist(id);
    await _mutate(
      board.id,
      (value) => value.copyWith(
        artists: value.artists.where((item) => item.id != id).toList(),
      ),
      entityType: 'artists',
      entityId: id,
      operation: 'delete',
      payload: const {},
    );
  }

  @override
  Future<Label> createLabel(String boardId, String name, Color color) async {
    final label = Label(
      id: _uuid.v4(),
      createdBy: _requiredUserId,
      name: name.trim(),
      color: color,
    );
    await _mutate(
      boardId,
      (board) => board.copyWith(labels: [...board.labels, label]),
      entityType: 'labels',
      entityId: label.id,
      operation: 'upsert',
      payload: _labelPayload(label),
    );
    return label;
  }

  @override
  Future<Label> updateLabel(String boardId, Label label) async {
    await _mutate(
      boardId,
      (board) => board.copyWith(
        labels: board.labels
            .map((item) => item.id == label.id ? label : item)
            .toList(),
      ),
      entityType: 'labels',
      entityId: label.id,
      operation: 'upsert',
      payload: _labelPayload(label),
    );
    return label;
  }

  @override
  Future<void> deleteLabel(String id) async {
    final board = await _boardContainingLabel(id);
    await _mutate(
      board.id,
      (value) => value.copyWith(
        labels: value.labels.where((item) => item.id != id).toList(),
      ),
      entityType: 'labels',
      entityId: id,
      operation: 'delete',
      payload: const {},
    );
  }

  @override
  Future<Uint8List> downloadAttachment(SongAttachment attachment) async {
    final path = attachment.localPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists() && await file.length() == attachment.fileSize) {
        return file.readAsBytes();
      }
    }
    return downloadRemoteAttachment(attachment);
  }

  Future<void> _mutate(
    String boardId,
    SongList Function(SongList) transform, {
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final row = await _findBoardRow(boardId);
    final board = transform(BoardCodec.decode(row.document));
    row
      ..document = BoardCodec.encode(board)
      ..updatedAt = DateTime.now().toUtc();
    await _isar.writeTxn(() async {
      await _isar.cachedBoards.put(row);
      await _putQueue(entityType, entityId, operation, payload);
    });
  }

  Future<void> _saveAndQueue(
    SongList board, {
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final accountId = _requiredUserId;
    final existing = await _isar.cachedBoards
        .filter()
        .cacheKeyEqualTo('$accountId:${board.id}')
        .findFirst();
    final row = existing ?? CachedBoard()
      ..uuid = board.id
      ..ownerId = board.ownerId
      ..accountId = accountId
      ..cacheKey = '$accountId:${board.id}';
    row
      ..document = BoardCodec.encode(board)
      ..updatedAt = DateTime.now().toUtc();
    await _isar.writeTxn(() async {
      await _isar.cachedBoards.put(row);
      await _putQueue(entityType, entityId, operation, payload);
    });
    onSyncNeeded?.call();
  }

  Future<void> _putQueue(
    String entityType,
    String entityId,
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final accountId = _requiredUserId;
    if (operation == 'reorder') {
      final stale = await _isar.syncQueues
          .filter()
          .userIdEqualTo(accountId)
          .and()
          .entityTypeEqualTo(entityType)
          .and()
          .entityIdEqualTo(entityId)
          .and()
          .operationEqualTo(operation)
          .and()
          .statusEqualTo('pending')
          .findAll();
      await _isar.syncQueues.deleteAll(stale.map((item) => item.id).toList());
    }
    await _isar.syncQueues.put(
      SyncQueue()
        ..entityType = entityType
        ..entityId = entityId
        ..operation = operation
        ..payload = jsonEncode(payload)
        ..status = 'pending'
        ..createdAt = DateTime.now().toUtc()
        ..userId = accountId,
    );
  }

  Future<CachedBoard> _findBoardRow(String id) async {
    final row = await _isar.cachedBoards
        .filter()
        .cacheKeyEqualTo('$_requiredUserId:$id')
        .findFirst();
    if (row == null) throw StateError('Board not available offline');
    return row;
  }

  Future<SongList> _requireActiveBoard() async {
    final id = _activeBoardId;
    if (id == null) throw StateError('No active board');
    return BoardCodec.decode((await _findBoardRow(id)).document);
  }

  Future<SongList> _boardWhere(bool Function(SongList) test) async {
    for (final board in await fetchBoards()) {
      if (test(board)) return board;
    }
    throw StateError('Local entity not found');
  }

  Future<SongList> _boardContainingColumn(String id) =>
      _boardWhere((board) => board.columns.any((column) => column.id == id));

  Future<SongList> _boardContainingArtist(String id) =>
      _boardWhere((board) => board.artists.any((artist) => artist.id == id));

  Future<SongList> _boardContainingLabel(String id) =>
      _boardWhere((board) => board.labels.any((label) => label.id == id));

  Future<(SongList, SongColumn, int)> _songLocation(String id) async {
    for (final board in await fetchBoards()) {
      for (final column in board.columns) {
        final index = column.songs.indexWhere((song) => song.id == id);
        if (index >= 0) return (board, column, index);
      }
    }
    throw StateError('Local song not found');
  }

  Song _withAttachmentIds(Song song) => song.copyWith(
    attachments: song.attachments
        .map(
          (item) => item.id != null
              ? item
              : SongAttachment(
                  id: _uuid.v4(),
                  name: item.name,
                  storagePath: item.storagePath,
                  localPath: item.localPath,
                  fileType: item.fileType,
                  fileSize: item.fileSize,
                ),
        )
        .toList(),
  );

  Future<Map<String, PersonalSongEditRecord>> _personalEditsBySong() async {
    final records = await _isar.personalSongEditRecords
        .filter()
        .userIdEqualTo(_requiredUserId)
        .and()
        .deletedEqualTo(false)
        .findAll();
    return {for (final record in records) record.songId: record};
  }

  SongList _overlayPersonalEdits(
    SongList board,
    Map<String, PersonalSongEditRecord> edits,
  ) => board.copyWith(
    columns: board.columns
        .map((column) {
          return column.copyWith(
            songs: column.songs
                .map((song) {
                  final edit = edits[song.id];
                  if (edit == null ||
                      song.creatorType != SongCreatorType.admin) {
                    return song;
                  }
                  return song.copyWith(
                    personalLyrics: edit.lyrics,
                    personalEditUpdatedAt: edit.clientUpdatedAt,
                  );
                })
                .toList(growable: false),
          );
        })
        .toList(growable: false),
  );

  Map<String, dynamic> _boardPayload(SongList board) => {
    'id': board.id,
    'created_by': board.ownerId,
    'name': board.name.trim(),
    'show_artist': board.showArtist,
    'show_bpm': board.showBpm,
    'dark_mode': board.darkMode,
  };

  Map<String, dynamic> _songPayload(
    Song song,
    String columnId,
    int position,
  ) => {
    'id': song.id,
    'column_id': columnId,
    'created_by': song.createdBy ?? _requiredUserId,
    'title': song.title.trim(),
    'tempo': song.tempo,
    'key_root': song.key,
    'key_type': song.keyType,
    'lyrics': song.lyrics?.trim() ?? '',
    'is_published': false,
    'deleted': false,
    'position': position,
    'artist_name': song.artistName,
    'label_ids': song.labels,
    'attachments': song.attachments
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'storage_path': item.storagePath,
            'local_path': item.localPath,
            'file_type': normalizeMediaType(item.fileType, fileName: item.name),
            'file_size': item.fileSize,
          },
        )
        .toList(),
  };

  Map<String, dynamic> _artistPayload(Artist artist) => {
    'id': artist.id,
    'created_by': artist.createdBy ?? _requiredUserId,
    'name': artist.name.trim(),
    'slug':
        '${artist.name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${artist.id}',
  };

  Map<String, dynamic> _labelPayload(Label label) => {
    'id': label.id,
    'created_by': label.createdBy ?? _requiredUserId,
    'name': label.name.trim(),
    'color':
        '#${label.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
  };
}
