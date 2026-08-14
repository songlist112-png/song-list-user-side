import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/sync_service.dart';
import '../../../database/isar_database.dart';
import '../../../database/local/models/personal_song_edit.dart';
import '../../../database/local/models/sync_queue.dart';
import '../domain/personal_song_edit_repository.dart';

final personalSongEditRepositoryProvider = Provider<PersonalSongEditRepository>(
  (ref) => IsarPersonalSongEditRepository(
    isar: IsarDatabase.instance,
    userId: () => Supabase.instance.client.auth.currentUser?.id,
    onSyncNeeded: () => unawaited(ref.read(syncServiceProvider).synchronize()),
  ),
);

class IsarPersonalSongEditRepository implements PersonalSongEditRepository {
  IsarPersonalSongEditRepository({
    required Isar isar,
    required this.userId,
    this.onSyncNeeded,
  }) : // Isar stays private while constructor remains conventional.
       // ignore: prefer_initializing_formals
       _isar = isar;

  static const maxLyricsLength = 100000;

  final Isar _isar;
  final String? Function() userId;
  final void Function()? onSyncNeeded;
  final Uuid _uuid = const Uuid();

  String get _requiredUserId =>
      userId() ?? (throw StateError('Authentication required'));

  @override
  Future<void> save({required String songId, required String lyrics}) async {
    if (lyrics.length > maxLyricsLength) {
      throw ArgumentError.value(
        lyrics,
        'lyrics',
        'Lyrics exceed 100,000 characters',
      );
    }
    final ownerId = _requiredUserId;
    final cacheKey = '$ownerId:$songId';
    final existing = await _isar.personalSongEditRecords
        .filter()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();
    final now = DateTime.now().toUtc();
    final edit = existing ?? PersonalSongEditRecord()
      ..cacheKey = cacheKey
      ..userId = ownerId
      ..songId = songId
      ..editId = _uuid.v4();
    edit
      ..lyrics = lyrics
      ..clientUpdatedAt = now
      ..deleted = false;
    await _persist(edit);
  }

  @override
  Future<void> remove(String songId) async {
    final ownerId = _requiredUserId;
    final cacheKey = '$ownerId:$songId';
    final edit = await _isar.personalSongEditRecords
        .filter()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();
    if (edit == null || edit.deleted) return;
    edit
      ..deleted = true
      ..clientUpdatedAt = DateTime.now().toUtc();
    await _persist(edit);
  }

  Future<void> _persist(PersonalSongEditRecord edit) async {
    final payload = <String, Object?>{
      'id': edit.editId,
      'song_id': edit.songId,
      'lyrics': edit.lyrics,
      'client_updated_at': edit.clientUpdatedAt.toIso8601String(),
      'deleted': edit.deleted,
    };
    await _isar.writeTxn(() async {
      await _isar.personalSongEditRecords.put(edit);
      final stale = await _isar.syncQueues
          .filter()
          .userIdEqualTo(edit.userId)
          .and()
          .entityTypeEqualTo('user_song_edits')
          .and()
          .entityIdEqualTo(edit.songId)
          .and()
          .statusEqualTo('pending')
          .findAll();
      await _isar.syncQueues.deleteAll(stale.map((item) => item.id).toList());
      await _isar.syncQueues.put(
        SyncQueue()
          ..entityType = 'user_song_edits'
          ..entityId = edit.songId
          ..operation = 'upsert'
          ..payload = jsonEncode(payload)
          ..status = 'pending'
          ..createdAt = edit.clientUpdatedAt
          ..userId = edit.userId,
      );
    });
    onSyncNeeded?.call();
  }
}
