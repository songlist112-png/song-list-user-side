import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/sync_service.dart';
import '../../../../database/isar_database.dart';
import '../../data/datasources/local_settings_datasource.dart';
import '../../data/datasources/remote_settings_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return SettingsRepositoryImpl(
    isar: IsarDatabase.instance,
    userId: () => Supabase.instance.client.auth.currentUser?.id,
    local: LocalSettingsDataSource(),
    remote: RemoteSettingsDataSource(),
    onSyncNeeded: syncService.synchronize,
  );
});

/// Holds the loaded preferences and propagates updates to storage.
final settingsProvider =
    StateNotifierProvider<SettingsController, AsyncValue<UserPreferences>>(
      (ref) => SettingsController(ref.watch(settingsRepositoryProvider)),
    );

class SettingsController extends StateNotifier<AsyncValue<UserPreferences>> {
  SettingsController(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      state = AsyncValue.data(await _repository.load());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Applies the lyrics zoom multiplier locally and persists it.
  ///
  /// The state is updated optimistically because the local write already
  /// succeeded once the awaited save completes. A remote push failure still
  /// throws so the caller can surface it without losing the local change.
  Future<void> updateLyricsFontScale(double scale) async {
    final clamped = scale.clamp(
      UserPreferences.minLyricsFontScale,
      UserPreferences.maxLyricsFontScale,
    );
    final current = state.valueOrNull ?? const UserPreferences();
    final updated = current.copyWith(lyricsFontScale: clamped);
    state = AsyncValue.data(updated);
    await _repository.save(updated);
  }
}
