import 'dart:async';
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
import 'board_sync_cache.dart';
import 'song_arrangement_confirmation.dart';

final syncServiceProvider = Provider<SyncService>(
  (_) => throw StateError('SyncService provider was not initialized'),
);

final syncStatusProvider = StreamProvider<SyncStatus>(
  (ref) => ref.watch(syncServiceProvider).statusChanges,
);

enum SyncPhase { idle, checking, synchronizing, completed, offline, failed }

@immutable
class SyncStatus {
  const SyncStatus({
    required this.phase,
    required this.isInitialSync,
    this.progress,
    this.syncedSongs = 0,
    this.totalSongs,
  });

  const SyncStatus.idle()
    : phase = SyncPhase.idle,
      isInitialSync = false,
      progress = null,
      syncedSongs = 0,
      totalSongs = null;

  const SyncStatus.checking()
    : phase = SyncPhase.checking,
      isInitialSync = true,
      progress = 0,
      syncedSongs = 0,
      totalSongs = null;

  final SyncPhase phase;
  final bool isInitialSync;
  final double? progress;
  final int syncedSongs;
  final int? totalSongs;

  bool get isBackgroundSyncing => phase == SyncPhase.synchronizing;
  int get progressPercent => ((progress ?? 0).clamp(0, 1) * 100).round();
}

class SyncService {
  static const syncVersion = 2;
  static const initialSongBatchSize = 500;

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
  SyncStatus _status = const SyncStatus.checking();
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final Map<String, Future<Uint8List>> _attachmentDownloads = {};
  final Map<String, Future<String?>> _avatarDownloads = {};

  Stream<SyncStatus> get statusChanges async* {
    yield _status;
    yield* _statusController.stream;
  }

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
    _setStatus(const SyncStatus.idle());
  }

  Future<void> synchronize() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setStatus(const SyncStatus.idle());
      return;
    }
    if (_running) {
      _rerunRequested = true;
      return;
    }
    _running = true;
    final userId = user.id;
    var isInitialSync = true;
    try {
      await _ensureAuthProfile(user);
      final metadata = await _metadataFor(userId);
      await _prepareSyncMetadata(metadata);
      isInitialSync = !metadata.initialSyncComplete;
      _setStatus(
        SyncStatus(
          phase: SyncPhase.synchronizing,
          isInitialSync: isInitialSync,
          progress: isInitialSync
              ? metadata.initialSongTotal == null
                    ? 0.02
                    : _initialProgress(metadata)
              : null,
          syncedSongs: metadata.initialSongsSynced,
          totalSongs: metadata.initialSongTotal,
        ),
      );
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        _setStatus(
          SyncStatus(
            phase: SyncPhase.offline,
            isInitialSync: isInitialSync,
            progress: isInitialSync ? _status.progress : null,
            syncedSongs: metadata.initialSongsSynced,
            totalSongs: metadata.initialSongTotal,
          ),
        );
        return;
      }

      var pending = await _discardUnauthorizedReorders(
        userId,
        await _pendingFor(userId),
      );
      // Capture watermark before reads so changes racing this pull remain
      // strictly newer and are collected by the next incremental sync.
      final serverWatermark = await _remote.serverTime();
      await _syncProfile(userId);
      var completedWatermark = serverWatermark;
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
      if (remoteChanged) {
        completedWatermark = await _pullBoardChanges(
          userId,
          metadata,
          serverWatermark,
        );
      }
      if (pending.isNotEmpty) {
        pending = await _discardConfirmedArrangements(pending);
        final applied = await _applyPending(pending);
        await _confirmAppliedArrangements(applied);
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
        }
        if (applied.isNotEmpty) _rerunRequested = true;
      }
      metadata
        ..lastSync = metadata.initialSyncComplete ? completedWatermark : null
        ..lastSuccessAt = DateTime.now().toUtc()
        ..lastError = null;
      await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
      _setStatus(
        SyncStatus(
          phase: SyncPhase.completed,
          isInitialSync: isInitialSync,
          progress: isInitialSync ? 1 : null,
          syncedSongs: metadata.initialSongsSynced,
          totalSongs: metadata.initialSongTotal,
        ),
      );
    } catch (error, stackTrace) {
      _setStatus(
        SyncStatus(
          phase: SyncPhase.failed,
          isInitialSync: isInitialSync,
          progress: isInitialSync ? _status.progress : null,
          syncedSongs: _status.syncedSongs,
          totalSongs: _status.totalSongs,
        ),
      );
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

  void _setStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void _subscribeToRemoteChanges() {
    if (_realtimeChannel != null) return;
    _realtimeChannel = Supabase.instance.client
        .channel('offline-sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'boards',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'columns',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'songs',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'labels',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'artists',
          callback: (_) => unawaited(synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attachments',
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

  Future<void> _prepareSyncMetadata(SyncMetadata metadata) async {
    if (metadata.syncVersion == syncVersion) return;
    metadata
      ..syncVersion = syncVersion
      ..initialSyncComplete = false
      ..initialSyncUpperBound = null
      ..songCursorUpdatedAt = null
      ..songCursorId = null
      ..initialSongsSynced = 0
      ..initialSongTotal = null
      ..lastSync = null
      ..lastSuccessAt = null
      ..lastError = null;
    await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
  }

  Future<DateTime> _pullBoardChanges(
    String userId,
    SyncMetadata metadata,
    DateTime serverWatermark,
  ) async {
    final isInitial = !metadata.initialSyncComplete;
    final upperBound = isInitial
        ? metadata.initialSyncUpperBound ?? serverWatermark
        : serverWatermark;
    final cache = BoardSyncCache(isar: _isar, userId: userId);
    final isResumingInitialPage =
        isInitial && metadata.songCursorUpdatedAt != null;
    final structure = await _remote.fetchStructureDelta(
      since: isInitial ? null : metadata.lastSync,
      until: upperBound,
    );
    await cache.applyStructure(
      structure,
      isInitial: isInitial && !isResumingInitialPage,
    );
    if (isInitial) _emitInitialProgress(metadata);
    if (isInitial && metadata.initialSyncUpperBound == null) {
      metadata.initialSyncUpperBound = upperBound;
      await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
    }

    await _pullSongPages(cache, metadata, upperBound, isInitial: isInitial);
    metadata
      ..initialSyncComplete = true
      ..initialSyncUpperBound = null
      ..songCursorUpdatedAt = null
      ..songCursorId = null;
    await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
    if (upperBound.isBefore(serverWatermark)) _rerunRequested = true;
    return upperBound;
  }

  Future<void> _pullSongPages(
    BoardSyncCache cache,
    SyncMetadata metadata,
    DateTime upperBound, {
    required bool isInitial,
  }) async {
    if (isInitial && metadata.initialSongTotal == null) {
      try {
        metadata.initialSongTotal = await _remote.fetchVisibleSongCount(
          until: upperBound,
        );
        await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
        _emitInitialProgress(metadata);
      } on Exception catch (error) {
        debugPrint(
          'Initial song count unavailable; using page progress: $error',
        );
      }
    }
    while (true) {
      final page = await _remote.fetchSongPage(
        since: isInitial ? null : metadata.lastSync,
        until: upperBound,
        cursorUpdatedAt: metadata.songCursorUpdatedAt,
        cursorId: metadata.songCursorId,
        pageSize: initialSongBatchSize,
      );
      if (isInitial && page.totalCount != null) {
        metadata.initialSongTotal = page.totalCount;
      }
      await cache.applySongPage(page.rows);
      if (page.rows.isEmpty) {
        if (isInitial) {
          await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
          _emitInitialProgress(metadata);
        }
        break;
      }
      metadata
        ..songCursorUpdatedAt = page.nextUpdatedAt
        ..songCursorId = page.nextId;
      if (isInitial) metadata.initialSongsSynced += page.rows.length;
      await _isar.writeTxn(() => _isar.syncMetadatas.put(metadata));
      if (isInitial) _emitInitialProgress(metadata);
      await Future<void>.delayed(Duration.zero);
      if (!page.hasMore) break;
    }
  }

  void _emitInitialProgress(SyncMetadata metadata) {
    _setStatus(
      SyncStatus(
        phase: SyncPhase.synchronizing,
        isInitialSync: true,
        progress: _initialProgress(metadata),
        syncedSongs: metadata.initialSongsSynced,
        totalSongs: metadata.initialSongTotal,
      ),
    );
  }

  static double _initialProgress(SyncMetadata metadata) {
    const structureWeight = 0.08;
    final total = metadata.initialSongTotal;
    if (total == null) {
      final completedBatches =
          metadata.initialSongsSynced / initialSongBatchSize;
      return (structureWeight + (completedBatches * 0.12)).clamp(
        structureWeight,
        0.92,
      );
    }
    if (total == 0) return 1;
    final songProgress = (metadata.initialSongsSynced / total).clamp(0, 1);
    return structureWeight + ((1 - structureWeight) * songProgress);
  }

  Future<List<SyncQueue>> _discardConfirmedArrangements(
    List<SyncQueue> pending,
  ) async {
    final confirmation = SongArrangementConfirmation.from(pending);
    if (confirmation.isEmpty) return pending;
    final orders = await _remote.fetchOwnedSongOrders(confirmation.columnIds);
    if (!confirmation.matchesOrders(orders)) return pending;
    await _deleteQueueItems(confirmation.queueIds);
    return pending
        .where((item) => !confirmation.queueIds.contains(item.id))
        .toList(growable: false);
  }

  Future<List<SyncQueue>> _applyPending(List<SyncQueue> pending) async {
    final applied = <SyncQueue>[];
    for (final item in pending) {
      final nextAttempt = item.nextAttemptAt;
      if (nextAttempt != null && nextAttempt.isAfter(DateTime.now().toUtc())) {
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
    return applied;
  }

  Future<void> _confirmAppliedArrangements(List<SyncQueue> applied) async {
    final confirmation = SongArrangementConfirmation.from(applied);
    final orders = await _remote.fetchOwnedSongOrders(confirmation.columnIds);
    final rejectedIds = confirmation.rejectedQueueIdsForOrders(orders);
    final confirmedIds = applied
        .where((item) => !rejectedIds.contains(item.id))
        .map((item) => item.id)
        .toSet();
    await _deleteQueueItems(confirmedIds);
    final rejected = await _currentPending(rejectedIds);
    if (rejected.isEmpty) return;
    for (final item in rejected) {
      await _recordRetry(
        item,
        StateError('Server did not confirm song arrangement'),
      );
    }
    throw StateError('Server did not confirm song arrangement');
  }

  Future<List<SyncQueue>> _currentPending(Set<int> ids) async {
    final result = <SyncQueue>[];
    for (final id in ids) {
      final item = await _isar.syncQueues.get(id);
      if (item != null && item.status == 'pending') result.add(item);
    }
    return result;
  }

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

  Future<void> _deleteQueueItems(Set<int> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(() => _isar.syncQueues.deleteAll(ids.toList()));
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
