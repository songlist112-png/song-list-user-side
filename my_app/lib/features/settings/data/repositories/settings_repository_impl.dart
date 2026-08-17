import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../database/local/models/sync_queue.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_datasource.dart';
import '../datasources/remote_settings_datasource.dart';
import '../models/user_preferences_model.dart';

/// Offline-first settings store.
///
/// The local copy is the source of truth. Every save writes locally and enqueues
/// a `user_preferences` sync operation, which the background [SyncService]
/// flushes to Supabase (with retry/backoff) once connectivity allows. Loading
/// reads local first and only falls back to the server when nothing is cached.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required Isar isar,
    required String? Function() userId,
    required LocalSettingsDataSource local,
    RemoteSettingsDataSource? remote,
    void Function()? onSyncNeeded,
  }) : // Fields stay private while the constructor remains conventional.
       // ignore: prefer_initializing_formals
       _isar = isar,
       // ignore: prefer_initializing_formals
       _userId = userId,
       // ignore: prefer_initializing_formals
       _local = local,
       _remote = remote ?? RemoteSettingsDataSource(),
       // ignore: prefer_initializing_formals
       _onSyncNeeded = onSyncNeeded;

  final Isar _isar;
  final String? Function() _userId;
  final LocalSettingsDataSource _local;
  final RemoteSettingsDataSource _remote;
  final void Function()? _onSyncNeeded;

  String get _requiredUserId =>
      _userId() ?? (throw StateError('Authentication required'));

  @override
  Future<UserPreferences> load() async {
    final cached = await _local.read();
    if (cached != null) return cached.toEntity();

    UserPreferencesModel? remote;
    try {
      remote = await _remote.fetch();
    } catch (error) {
      debugPrint('Could not load remote preferences: $error');
    }
    final preferences = remote?.toEntity() ?? const UserPreferences();
    await _local.write(UserPreferencesModel.fromEntity(preferences));
    return preferences;
  }

  @override
  Future<void> save(UserPreferences preferences) async {
    final ownerId = _requiredUserId;
    final model = UserPreferencesModel.fromEntity(preferences);
    await _local.write(model);

    final now = DateTime.now().toUtc();
    final payload = <String, Object?>{
      'lyrics_font_scale': model.lyricsFontScale,
      'updated_at': now.toIso8601String(),
    };
    await _isar.writeTxn(() async {
      final stale = await _isar.syncQueues
          .filter()
          .userIdEqualTo(ownerId)
          .and()
          .entityTypeEqualTo('user_preferences')
          .and()
          .entityIdEqualTo(ownerId)
          .and()
          .statusEqualTo('pending')
          .findAll();
      await _isar.syncQueues.deleteAll(stale.map((item) => item.id).toList());
      await _isar.syncQueues.put(
        SyncQueue()
          ..entityType = 'user_preferences'
          ..entityId = ownerId
          ..operation = 'upsert'
          ..payload = jsonEncode(payload)
          ..status = 'pending'
          ..createdAt = now
          ..userId = ownerId,
      );
    });
    _onSyncNeeded?.call();
  }
}
