import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/local/models/cached_board.dart';
import '../../database/local/models/sync_metadata.dart';
import '../../database/local/models/sync_queue.dart';
import '../../database/remote/datasources/song_remote_datasource.dart';
import '../../features/boards/data/board_codec.dart';
import '../../shared/models/song_list.dart';
import '../../shared/models/song_attachment.dart';

final syncServiceProvider = Provider<SyncService>(
  (_) => throw StateError('SyncService provider was not initialized'),
);

class SyncService {
  SyncService({
    required Isar isar,
    SyncRemoteDataSource? remote,
    Connectivity? connectivity,
  }) : // Isar stays private; public constructor keeps conventional `isar` name.
       // ignore: prefer_initializing_formals
       _isar = isar,
       _remote = remote ?? SyncRemoteDataSource(),
       _connectivity = connectivity ?? Connectivity();

  final Isar _isar;
  final SyncRemoteDataSource _remote;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;
  RealtimeChannel? _realtimeChannel;
  Timer? _timer;
  bool _running = false;
  final Map<String, Future<Uint8List>> _attachmentDownloads = {};

  Future<void> start() async {
    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none)) unawaited(synchronize());
    });
    _timer ??= Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(synchronize()),
    );
    _authSubscription ??= Supabase.instance.client.auth.onAuthStateChange
        .listen((state) {
          if (state.session != null) {
            _subscribeToRemoteChanges();
            unawaited(synchronize());
          }
        });
    _subscribeToRemoteChanges();
    await synchronize();
  }

  Future<void> stop() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timer?.cancel();
    _timer = null;
    await _authSubscription?.cancel();
    _authSubscription = null;
    final channel = _realtimeChannel;
    if (channel != null) await Supabase.instance.client.removeChannel(channel);
    _realtimeChannel = null;
  }

  Future<void> synchronize() async {
    if (_running) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;
    _running = true;
    try {
      final metadata = await _metadataFor(userId);
      final pending = await _pendingFor(userId);
      final watermark = await _remote.serverTime();

      // Required conflict invariant: remote state is fetched before any upload.
      final remoteChanged =
          metadata.lastSync == null ||
          pending.isNotEmpty ||
          await _remote.hasChangesSince(metadata.lastSync!);
      if (remoteChanged) {
        final remoteBoards = (await _remote.fetchBoardGraph()).cast<SongList>();
        await _replaceCleanCache(userId, remoteBoards, pending);
      }

      for (final item in pending) {
        final nextAttempt = item.nextAttemptAt;
        if (nextAttempt != null &&
            nextAttempt.isAfter(DateTime.now().toUtc())) {
          continue;
        }
        try {
          await _remote.apply(item);
          await _isar.writeTxn(() => _isar.syncQueues.delete(item.id));
        } catch (error, stackTrace) {
          debugPrint(
            'Sync upload failed for ${item.entityType}/${item.entityId}: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
          await _recordRetry(item, error);
          rethrow;
        }
      }

      // Canonical server response wins after accepted client mutations.
      final canonical = (await _remote.fetchBoardGraph()).cast<SongList>();
      await _replaceAllCache(userId, canonical);
      metadata
        ..lastSync = watermark
        ..lastSuccessAt = DateTime.now().toUtc()
        ..lastError = null;
      await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
    } catch (error, stackTrace) {
      debugPrint('Background sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final metadata = await _metadataFor(userId)
        ..lastError = error.toString();
      await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
    } finally {
      _running = false;
    }
  }

  void _subscribeToRemoteChanges() {
    if (_realtimeChannel != null) return;
    _realtimeChannel = Supabase.instance.client
        .channel('offline-sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'songs',
          callback: (_) => unawaited(synchronize()),
        )
        .subscribe();
  }

  Future<SyncMetadata> _metadataFor(String userId) async =>
      await _isar.syncMetadatas.filter().userIdEqualTo(userId).findFirst() ??
      (SyncMetadata()..userId = userId);

  Future<List<SyncQueue>> _pendingFor(String userId) async {
    final items = await _isar.syncQueues
        .filter()
        .userIdEqualTo(userId)
        .and()
        .statusEqualTo('pending')
        .findAll();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  Future<void> _replaceCleanCache(
    String userId,
    List<SongList> remoteBoards,
    List<SyncQueue> pending,
  ) async {
    final localRows = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(userId)
        .findAll();
    final dirtyBoardIds = <String>{};
    for (final row in localRows) {
      final document = row.document;
      if (pending.any((item) => document.contains(item.entityId))) {
        dirtyBoardIds.add(row.uuid);
      }
    }
    final remoteIds = remoteBoards.map((board) => board.id).toSet();
    await _isar.writeTxn(() async {
      for (final row in localRows) {
        if (!dirtyBoardIds.contains(row.uuid) &&
            !remoteIds.contains(row.uuid)) {
          await _isar.cachedBoards.delete(row.id);
        }
      }
      for (final board in remoteBoards) {
        if (dirtyBoardIds.contains(board.id)) continue;
        await _putBoard(userId, board);
      }
    });
  }

  Future<void> _replaceAllCache(String userId, List<SongList> boards) async {
    final ids = boards.map((board) => board.id).toSet();
    final existing = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(userId)
        .findAll();
    await _isar.writeTxn(() async {
      for (final row in existing.where((row) => !ids.contains(row.uuid))) {
        await _isar.cachedBoards.delete(row.id);
      }
      for (final board in boards) {
        await _putBoard(userId, board);
      }
    });
  }

  Future<void> _putBoard(String userId, SongList board) async {
    final existing = await _isar.cachedBoards
        .filter()
        .cacheKeyEqualTo('$userId:${board.id}')
        .findFirst();
    final mergedBoard = existing == null
        ? board
        : _preserveCachedAttachmentPaths(
            board,
            BoardCodec.decode(existing.document),
          );
    await _isar.cachedBoards.put(
      (existing ?? CachedBoard())
        ..uuid = board.id
        ..cacheKey = '$userId:${board.id}'
        ..accountId = userId
        ..ownerId = board.ownerId
        ..document = BoardCodec.encode(mergedBoard)
        ..updatedAt = DateTime.now().toUtc(),
    );
  }

  Future<void> _recordRetry(SyncQueue item, Object error) async {
    item
      ..attempts += 1
      ..lastError = error.toString()
      ..status = item.attempts >= 10 ? 'failed' : 'pending'
      ..nextAttemptAt = DateTime.now().toUtc().add(
        Duration(seconds: 1 << item.attempts.clamp(1, 8)),
      );
    await _isar.writeTxn(() => _isar.syncQueues.put(item));
  }

  /// Downloads one attachment on demand, caches it, then persists localPath in
  /// Isar. Concurrent taps share one request. Normal synchronization stays
  /// metadata-only.
  Future<Uint8List> downloadAttachment(SongAttachment attachment) {
    final storagePath = attachment.storagePath;
    if (storagePath == null) {
      final localPath = attachment.localPath;
      if (localPath == null) {
        return Future.error(
          const FileSystemException('Attachment has no local or remote path'),
        );
      }
      return File(localPath).readAsBytes();
    }
    return _attachmentDownloads.putIfAbsent(
      storagePath,
      () => _downloadAndCacheAttachment(
        attachment,
      ).whenComplete(() => _attachmentDownloads.remove(storagePath)),
    );
  }

  Future<Uint8List> _downloadAndCacheAttachment(
    SongAttachment attachment,
  ) async {
    final storagePath = attachment.storagePath!;
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}attachments',
    );
    await directory.create(recursive: true);
    final file = _attachmentFile(directory, attachment);
    if (await file.exists() && await file.length() == attachment.fileSize) {
      final bytes = await file.readAsBytes();
      await _persistAttachmentPath(attachment, file.path);
      return bytes;
    }
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw const FileSystemException(
        'Attachment is not cached and device is offline',
      );
    }

    late final Uint8List bytes;
    try {
      bytes = await _remote.downloadAttachment(storagePath);
    } on StorageException catch (error) {
      if (!_isMissingStorageObject(error)) rethrow;
      throw FileSystemException(
        'Attachment no longer exists on server',
        storagePath,
      );
    }
    final temporary = File('${file.path}.part');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
    await _persistAttachmentPath(attachment, file.path);
    return bytes;
  }

  File _attachmentFile(Directory directory, SongAttachment attachment) {
    final storagePath = attachment.storagePath!;
    final safeId = (attachment.id ?? storagePath.hashCode.toString())
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final safeName = attachment.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    return File(
      '${directory.path}${Platform.pathSeparator}${safeId}_$safeName',
    );
  }

  Future<void> _persistAttachmentPath(
    SongAttachment attachment,
    String localPath,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final rows = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(userId)
        .findAll();
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final board = BoardCodec.decode(row.document);
        final updated = _replaceAttachmentPath(board, attachment, localPath);
        if (identical(updated, board)) continue;
        row
          ..document = BoardCodec.encode(updated)
          ..updatedAt = DateTime.now().toUtc();
        await _isar.cachedBoards.put(row);
      }
    });
  }

  SongList _replaceAttachmentPath(
    SongList board,
    SongAttachment target,
    String localPath,
  ) {
    var changed = false;
    final columns = board.columns.map((column) {
      final songs = column.songs.map((song) {
        final attachments = song.attachments.map((item) {
          if (!_sameAttachment(item, target)) return item;
          changed = true;
          return SongAttachment(
            id: item.id,
            name: item.name,
            storagePath: item.storagePath,
            localPath: localPath,
            fileType: item.fileType,
            fileSize: item.fileSize,
          );
        }).toList();
        return song.copyWith(attachments: attachments);
      }).toList();
      return column.copyWith(songs: songs);
    }).toList();
    return changed ? board.copyWith(columns: columns) : board;
  }

  SongList _preserveCachedAttachmentPaths(SongList remote, SongList local) {
    final cachedPaths = <String, String>{};
    for (final column in local.columns) {
      for (final song in column.songs) {
        for (final attachment in song.attachments) {
          final path = attachment.localPath;
          if (path != null) cachedPaths[_attachmentKey(attachment)] = path;
        }
      }
    }
    var result = remote;
    for (final column in remote.columns) {
      for (final song in column.songs) {
        for (final attachment in song.attachments) {
          final path = cachedPaths[_attachmentKey(attachment)];
          if (path != null) {
            result = _replaceAttachmentPath(result, attachment, path);
          }
        }
      }
    }
    return result;
  }

  static bool _sameAttachment(SongAttachment first, SongAttachment second) =>
      _attachmentKey(first) == _attachmentKey(second);

  static String _attachmentKey(SongAttachment attachment) =>
      attachment.id ?? attachment.storagePath ?? attachment.name;

  static bool _isMissingStorageObject(StorageException error) {
    final details = '${error.message} ${error.error} ${error.statusCode}';
    return details.contains('NoSuchKey') ||
        details.contains('Object not found') ||
        details.contains('not_found') ||
        details.contains('"statusCode":"404"');
  }
}
