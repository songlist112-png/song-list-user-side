import 'package:isar_community/isar.dart';

import '../../../database/local/models/sync_queue.dart';
import 'datasources/local_settings_datasource.dart';
import 'datasources/remote_settings_datasource.dart';

/// Flushes queued preference writes and merges remote preferences into the
/// local store, mirroring the support feature's sync coordinator.
class SettingsSyncCoordinator {
  SettingsSyncCoordinator({
    required Isar isar,
    LocalSettingsDataSource? local,
    RemoteSettingsDataSource? remote,
  }) : // Local store stays injectable while the constructor stays conventional.
       // ignore: prefer_initializing_formals
       _isar = isar,
       _local = local ?? LocalSettingsDataSource(),
       _remote = remote ?? RemoteSettingsDataSource();

  final Isar _isar;
  final LocalSettingsDataSource _local;
  final RemoteSettingsDataSource _remote;

  bool handles(SyncQueue item) => item.entityType == 'user_preferences';

  Future<void> apply(SyncQueue item) => _remote.apply(item);

  /// Pulls remote preferences into the local store unless a local preference
  /// write is still pending, in which case local wins until it is flushed.
  Future<void> pull(String userId) async {
    final pending = await _isar.syncQueues
        .filter()
        .userIdEqualTo(userId)
        .and()
        .entityTypeEqualTo('user_preferences')
        .and()
        .statusEqualTo('pending')
        .findAll();
    if (pending.isNotEmpty) return;

    final remote = await _remote.fetch(userId: userId);
    if (remote == null) return;
    final local = await _local.read();
    if (local != null && local.lyricsFontScale == remote.lyricsFontScale) {
      return;
    }
    await _local.write(remote);
  }
}
