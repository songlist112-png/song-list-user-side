import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../database/local/models/sync_queue.dart';
import '../models/user_preferences_model.dart';

/// Reads and pushes user preferences against the `user_preferences` table.
///
/// Reads fall back to the authenticated session's user; queued uploads carry
/// their own user id so the sync coordinator can flush them for the owner.
class RemoteSettingsDataSource {
  RemoteSettingsDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const _table = 'user_preferences';

  final SupabaseClient _client;

  String _currentUserId() =>
      _client.auth.currentUser?.id ??
      (throw StateError('Authentication required'));

  Future<UserPreferencesModel?> fetch({String? userId}) async {
    final row = await _client
        .from(_table)
        .select('lyrics_font_scale, updated_at')
        .eq('user_id', userId ?? _currentUserId())
        .maybeSingle();
    if (row == null) return null;
    return UserPreferencesModel.fromJson(row);
  }

  Future<void> apply(SyncQueue item) async {
    if (item.entityType != 'user_preferences') {
      throw ArgumentError.value(item.entityType, 'entityType');
    }
    final payload = item.payload == null
        ? <String, dynamic>{}
        : (jsonDecode(item.payload!) as Map).cast<String, dynamic>();
    await _client.from(_table).upsert(
      {
        'user_id': item.userId,
        'lyrics_font_scale': payload['lyrics_font_scale'],
        'updated_at': payload['updated_at'],
      },
      onConflict: 'user_id',
    );
  }
}
