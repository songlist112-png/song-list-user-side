import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/local/models/cached_board.dart';
import '../../database/local/models/profile.dart';
import '../../database/local/models/personal_song_edit.dart';
import '../../database/local/models/sync_metadata.dart';
import '../../database/local/models/sync_queue.dart';
import '../../database/remote/datasources/profile_remote_datasource.dart';
import '../../database/remote/datasources/song_remote_datasource.dart';
import '../../features/boards/data/board_codec.dart';
import '../../features/settings/data/settings_sync_coordinator.dart';
import '../../features/songs/domain/personal_song_edit_conflict_resolver.dart';
import '../../features/support/sync/support_sync_coordinator.dart';
import '../../shared/models/song_attachment.dart';
import '../../shared/models/song_list.dart';

final syncServiceProvider = Provider<SyncService>(
  (_) => throw StateError('SyncService provider was not initialized'),
);

class SyncService {
  SyncService({
    required Isar isar,
    SyncRemoteDataSource? remote,
    ProfileRemoteDataSource? profileRemote,
    SupportSyncCoordinator? supportSync,
    SettingsSyncCoordinator? settingsSync,
    Connectivity? connectivity,
  }) : // Isar stays private; public constructor keeps conventional `isar` name.
       // ignore: prefer_initializing_formals
       _isar = isar,
       _remote = remote ?? SyncRemoteDataSource(),
       _profileRemote = profileRemote ?? ProfileRemoteDataSource(),
       _supportSync = supportSync ?? SupportSyncCoordinator(isar: isar),
       _settingsSync = settingsSync ?? SettingsSyncCoordinator(isar: isar),
       _connectivity = connectivity ?? Connectivity();

  final Isar _isar;
  final SyncRemoteDataSource _remote;
  final ProfileRemoteDataSource _profileRemote;
  final SupportSyncCoordinator _supportSync;
  final SettingsSyncCoordinator _settingsSync;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;
  RealtimeChannel? _realtimeChannel;
  Timer? _timer;
  Timer? _retryTimer;
  DateTime? _retryAt;
  bool _running = false;
  bool _rerunRequested = false;
  final Map<String, Future<Uint8List>> _attachmentDownloads = {};
  final Map<String, Future<String?>> _avatarDownloads = {};

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
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAt = null;
    await _authSubscription?.cancel();
    _authSubscription = null;
    final channel = _realtimeChannel;
    if (channel != null) await Supabase.instance.client.removeChannel(channel);
    _realtimeChannel = null;
  }

  Future<void> synchronize() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    if (_running) {
      _rerunRequested = true;
      return;
    }
    _running = true;
    final userId = user.id;
    try {
      await _ensureAuthProfile(user);
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final metadata = await _metadataFor(userId);
      var pending = await _discardUnauthorizedReorders(
        userId,
        await _pendingFor(userId),
      );
      // Capture watermark before reads so changes racing this pull remain
      // strictly newer and are collected by the next incremental sync.
      final preparationFuture = Future.wait<Object?>([
        _remote.serverTime(),
        _syncProfile(userId),
      ]);
      final remoteEdits = await _remote.fetchPersonalSongEdits(
        since: metadata.lastSync,
      );
      await _mergePersonalSongEdits(userId, remoteEdits, pending);
      await _supportSync.pull(userId);
      await _settingsSync.pull(userId);
      pending = await _pendingFor(userId);

      // Required conflict invariant: remote state is fetched before any upload.
      final remoteChanged =
          metadata.lastSync == null ||
          pending.isNotEmpty ||
          await _remote.hasChangesSince(metadata.lastSync!);
      if (pending.isEmpty) {
        if (remoteChanged) {
          final remoteBoardsFuture = _remote.fetchBoardGraph();
          final remoteBoards = (await remoteBoardsFuture).cast<SongList>();
          final replaced = await _replaceAllCache(userId, remoteBoards);
          if (!replaced) _rerunRequested = true;
        }
      } else {
        final remoteBoardsFuture = _remote.fetchBoardGraph();
        final remoteBoards = (await remoteBoardsFuture).cast<SongList>();
        await _replaceCleanCache(userId, remoteBoards);
        final applied = <SyncQueue>[];

        for (final item in pending) {
          final nextAttempt = item.nextAttemptAt;
          if (nextAttempt != null &&
              nextAttempt.isAfter(DateTime.now().toUtc())) {
            _scheduleRetry(nextAttempt);
            continue;
          }
          try {
            if (_supportSync.handles(item)) {
              await _supportSync.apply(item);
            } else if (_settingsSync.handles(item)) {
              await _settingsSync.apply(item);
            } else {
              await _remote.apply(item);
            }
            applied.add(item);
          } catch (error, stackTrace) {
            debugPrint(
              'Sync upload failed for ${item.entityType}/${item.entityId}: $error',
            );
            debugPrintStack(stackTrace: stackTrace);
            await _recordRetry(item, error);
            rethrow;
          }
        }

        // Keep local arrangement until canonical server graph confirms it.
        final canonical = (await _remote.fetchBoardGraph()).cast<SongList>();
        final rejected = applied
            .where((item) => !_arrangementMatches(canonical, item))
            .toList(growable: false);
        final rejectedCurrent = <SyncQueue>[];
        for (final item in rejected) {
          final current = await _isar.syncQueues.get(item.id);
          if (current != null && current.status == 'pending') {
            rejectedCurrent.add(current);
          }
        }
        if (rejectedCurrent.isNotEmpty) {
          for (final item in rejectedCurrent) {
            await _recordRetry(
              item,
              StateError('Server did not confirm song arrangement'),
            );
          }
          await _replaceCleanCache(userId, canonical);
          throw StateError('Server did not confirm song arrangement');
        }

        await _isar.writeTxn(
          () => _isar.syncQueues.deleteAll(
            applied.map((item) => item.id).toList(growable: false),
          ),
        );
        await _supportSync.pull(userId);
        await _settingsSync.pull(userId);
        await _mergePersonalSongEdits(
          userId,
          await _remote.fetchPersonalSongEdits(),
          await _pendingFor(userId),
        );
        final remaining = await _pendingFor(userId);
        if (remaining.isEmpty) {
          _retryTimer?.cancel();
          _retryTimer = null;
          _retryAt = null;
          final replaced = await _replaceAllCache(userId, canonical);
          if (!replaced) _rerunRequested = true;
        } else {
          await _replaceCleanCache(userId, canonical);
        }
      }
      final preparation = await preparationFuture;
      final watermark = preparation.first! as DateTime;
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
      if (_rerunRequested) {
        _rerunRequested = false;
        unawaited(synchronize());
      }
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
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_song_edits',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'support_tickets',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'support_messages',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_preferences',
          callback: (_) => unawaited(synchronize()),
        )
        .subscribe();
  }

  Future<void> _mergePersonalSongEdits(
    String userId,
    List<Map<String, dynamic>> rows,
    List<SyncQueue> pending,
  ) async {
    final pendingBySong = <String, List<SyncQueue>>{};
    for (final item in pending.where(
      (item) => item.entityType == 'user_song_edits',
    )) {
      pendingBySong.putIfAbsent(item.entityId, () => []).add(item);
    }
    for (final row in rows.where((row) => row['user_id'] == userId)) {
      final songId = row['song_id'] as String;
      final remoteTime = DateTime.parse(
        row['client_updated_at'] as String,
      ).toUtc();
      final local = await _isar.personalSongEditRecords
          .filter()
          .cacheKeyEqualTo('$userId:$songId')
          .findFirst();
      final queued = pendingBySong[songId] ?? const <SyncQueue>[];
      final winner = PersonalSongEditConflictResolver.resolve(
        localUpdatedAt: local?.clientUpdatedAt,
        remoteUpdatedAt: remoteTime,
        hasPendingLocalMutation: queued.isNotEmpty,
      );
      if (winner == PersonalSongEditConflictWinner.local) {
        continue;
      }
      final record = local ?? PersonalSongEditRecord()
        ..cacheKey = '$userId:$songId'
        ..userId = userId
        ..songId = songId;
      record
        ..editId = row['id'] as String
        ..lyrics = row['lyrics'] as String
        ..clientUpdatedAt = remoteTime
        ..serverUpdatedAt = DateTime.parse(row['updated_at'] as String).toUtc()
        ..deleted = row['deleted'] as bool? ?? false;
      await _isar.writeTxn(() async {
        await _isar.personalSongEditRecords.put(record);
        if (queued.isNotEmpty) {
          await _isar.syncQueues.deleteAll(
            queued.map((item) => item.id).toList(growable: false),
          );
        }
      });
    }
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

  Future<List<SyncQueue>> _discardUnauthorizedReorders(
    String userId,
    List<SyncQueue> pending,
  ) async {
    final reorderItems = pending
        .where((item) => item.operation == 'reorder')
        .toList();
    if (reorderItems.isEmpty) return pending;

    final rows = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(userId)
        .findAll();
    final reorderableColumns = <String, bool>{};
    for (final row in rows) {
      final board = BoardCodec.decode(row.document);
      for (final column in board.columns) {
        reorderableColumns[column.id] = column.songs.every(
          (song) => song.canEdit,
        );
      }
    }

    final unauthorized = reorderItems
        .where((item) => reorderableColumns[item.entityId] == false)
        .toList();
    if (unauthorized.isEmpty) return pending;

    await _isar.writeTxn(
      () => _isar.syncQueues.deleteAll(
        unauthorized.map((item) => item.id).toList(),
      ),
    );
    debugPrint(
      'Discarded ${unauthorized.length} unauthorized admin-song reorder(s)',
    );
    final unauthorizedIds = unauthorized.map((item) => item.id).toSet();
    return pending.where((item) => !unauthorizedIds.contains(item.id)).toList();
  }

  Future<void> _ensureAuthProfile(User user) async {
    final existing = await _isar.profiles
        .filter()
        .userIdEqualTo(user.id)
        .findFirst();
    if (existing != null) return;

    final metadata = user.userMetadata;
    final now = DateTime.now().toUtc();
    final profile = Profile()
      ..userId = user.id
      ..email = user.email
      ..fullName = _firstMetadataValue(metadata, const ['full_name', 'name'])
      ..avatarUrl = _firstMetadataValue(metadata, const [
        'avatar_url',
        'picture',
      ])
      ..role = 'user'
      ..lastLoginAt = _parseDate(user.lastSignInAt)
      ..createdAt = _parseDate(user.createdAt) ?? now
      ..updatedAt = _parseDate(user.updatedAt) ?? now;
    await _isar.writeTxn(() => _isar.profiles.put(profile));
  }

  static String? _firstMetadataValue(
    Map<String, dynamic>? metadata,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = metadata?[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Future<void> _syncProfile(String userId) async {
    final row = await _profileRemote.fetchCurrent(userId);
    if (row == null) return;

    final existing = await _isar.profiles
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    final remoteAvatarUrl = row['avatar_url'] as String?;
    final email = row['email'] as String?;
    final fullName = row['full_name'] as String?;
    final role = row['role'] as String? ?? 'user';
    final trialMinutesUsed = (row['trial_minutes_used'] as num?)?.toInt();
    final lastLoginAt = _parseDate(row['last_login_at']);
    final createdAt =
        _parseDate(row['created_at']) ??
        existing?.createdAt ??
        DateTime.now().toUtc();
    final updatedAt =
        _parseDate(row['updated_at']) ??
        existing?.updatedAt ??
        DateTime.now().toUtc();
    final unchanged =
        existing != null &&
        existing.email == email &&
        existing.fullName == fullName &&
        existing.avatarUrl == remoteAvatarUrl &&
        existing.role == role &&
        existing.trialMinutesUsed == trialMinutesUsed &&
        existing.lastLoginAt == lastLoginAt &&
        existing.createdAt == createdAt &&
        existing.updatedAt == updatedAt;
    if (unchanged) return;

    final profile = existing ?? Profile();
    profile
      ..userId = row['id'] as String
      ..email = email
      ..fullName = fullName
      ..avatarLocalPath = existing?.avatarUrl == remoteAvatarUrl
          ? existing?.avatarLocalPath
          : null
      ..avatarUrl = remoteAvatarUrl
      ..role = role
      ..trialMinutesUsed = trialMinutesUsed
      ..lastLoginAt = lastLoginAt
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..syncedAt = DateTime.now().toUtc();
    await _isar.writeTxn(() => _isar.profiles.put(profile));
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toUtc();
  }

  Future<void> _replaceCleanCache(
    String userId,
    List<SongList> remoteBoards,
  ) async {
    final remoteIds = remoteBoards.map((board) => board.id).toSet();
    await _isar.writeTxn(() async {
      final localRows = await _isar.cachedBoards
          .filter()
          .accountIdEqualTo(userId)
          .findAll();
      final pending = await _isar.syncQueues
          .filter()
          .userIdEqualTo(userId)
          .and()
          .statusEqualTo('pending')
          .findAll();
      final dirtyBoardIds = <String>{};
      for (final row in localRows) {
        if (pending.any((item) => row.document.contains(item.entityId))) {
          dirtyBoardIds.add(row.uuid);
        }
      }
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

  bool _arrangementMatches(List<SongList> boards, SyncQueue item) {
    if (item.operation != 'reorder' && item.operation != 'move') return true;
    final payload = jsonDecode(item.payload!) as Map<String, dynamic>;
    if (item.operation == 'reorder') {
      return listEquals(
        _columnSongIds(boards, payload['column_id'] as String),
        (payload['ids'] as List).cast<String>(),
      );
    }
    return listEquals(
          _columnSongIds(boards, payload['source_column_id'] as String),
          (payload['source_song_ids'] as List).cast<String>(),
        ) &&
        listEquals(
          _columnSongIds(boards, payload['destination_column_id'] as String),
          (payload['destination_song_ids'] as List).cast<String>(),
        );
  }

  List<String> _columnSongIds(List<SongList> boards, String columnId) {
    for (final board in boards) {
      for (final column in board.columns) {
        if (column.id == columnId) {
          // Reorder uploads are deliberately limited to songs owned by this
          // account. A shared column may also contain admin songs, whose
          // positions this user cannot update. Confirm only the subset this
          // queue item is authorized to arrange.
          return column.songs
              .where((song) => song.canEdit)
              .map((song) => song.id)
              .toList(growable: false);
        }
      }
    }
    return const [];
  }

  Future<bool> _replaceAllCache(String userId, List<SongList> boards) async {
    final ids = boards.map((board) => board.id).toSet();
    final existing = await _isar.cachedBoards
        .filter()
        .accountIdEqualTo(userId)
        .findAll();
    return _isar.writeTxn(() async {
      final pendingMutation = await _isar.syncQueues
          .filter()
          .userIdEqualTo(userId)
          .and()
          .statusEqualTo('pending')
          .findFirst();
      if (pendingMutation != null) return false;

      for (final row in existing.where((row) => !ids.contains(row.uuid))) {
        await _isar.cachedBoards.delete(row.id);
      }
      for (final board in boards) {
        await _putBoard(userId, board);
      }
      return true;
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
    final document = BoardCodec.encode(mergedBoard);
    if (existing != null &&
        existing.ownerId == board.ownerId &&
        existing.document == document) {
      return;
    }
    await _isar.cachedBoards.put(
      (existing ?? CachedBoard())
        ..uuid = board.id
        ..cacheKey = '$userId:${board.id}'
        ..accountId = userId
        ..ownerId = board.ownerId
        ..document = document
        ..updatedAt = DateTime.now().toUtc(),
    );
  }

  Future<void> _recordRetry(SyncQueue item, Object error) async {
    final nextAttemptAt = DateTime.now().toUtc().add(
      Duration(seconds: 1 << (item.attempts + 1).clamp(1, 8)),
    );
    item
      ..attempts += 1
      ..lastError = error.toString()
      ..status = item.attempts >= 10 ? 'failed' : 'pending'
      ..nextAttemptAt = nextAttemptAt;
    await _isar.writeTxn(() => _isar.syncQueues.put(item));
    if (item.status == 'pending') _scheduleRetry(nextAttemptAt);
  }

  void _scheduleRetry(DateTime nextAttemptAt) {
    final scheduledAt = _retryAt;
    if (scheduledAt != null && !scheduledAt.isAfter(nextAttemptAt)) return;
    _retryTimer?.cancel();
    _retryAt = nextAttemptAt;
    final remaining = nextAttemptAt.difference(DateTime.now().toUtc());
    _retryTimer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      _retryTimer = null;
      _retryAt = null;
      unawaited(synchronize());
    });
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

  /// Lazily caches current user's avatar and records its local path in Isar.
  Future<String?> cacheProfileAvatar(Profile profile) {
    final avatarUrl = profile.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return Future.value(null);
    final key = '${profile.userId}:$avatarUrl';
    return _avatarDownloads.putIfAbsent(
      key,
      () => _downloadAndCacheAvatar(
        profile,
        avatarUrl,
      ).whenComplete(() => _avatarDownloads.remove(key)),
    );
  }

  Future<String?> _downloadAndCacheAvatar(
    Profile profile,
    String avatarUrl,
  ) async {
    final existingPath = profile.avatarLocalPath;
    if (existingPath != null && await File(existingPath).exists()) {
      return existingPath;
    }
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return null;

    final uri = Uri.parse(avatarUrl);
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw FormatException('Unsupported avatar URL', avatarUrl);
    }
    final client = HttpClient();
    late final Uint8List bytes;
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Avatar download failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      bytes = await consolidateHttpClientResponseBytes(response);
    } finally {
      client.close(force: true);
    }

    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}avatars');
    await directory.create(recursive: true);
    final extension = _safeAvatarExtension(uri.path);
    final safeUserId = profile.userId.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}$safeUserId$extension',
    );
    final temporary = File('${file.path}.part');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);

    final current = await _isar.profiles
        .filter()
        .userIdEqualTo(profile.userId)
        .findFirst();
    if (current == null || current.avatarUrl != avatarUrl) return null;
    current.avatarLocalPath = file.path;
    await _isar.writeTxn(() => _isar.profiles.put(current));
    return file.path;
  }

  static String _safeAvatarExtension(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0) return '.img';
    final extension = name.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension)
        ? extension
        : '.img';
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
