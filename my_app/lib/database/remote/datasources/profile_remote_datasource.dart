import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote profile reads used only by SyncService.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> fetchCurrent(String userId) async {
    return await _client
        .from('profiles')
        .select(
          'id, email, full_name, avatar_url, role, trial_minutes_used, '
          'last_login_at, created_at, updated_at',
        )
        .eq('id', userId)
        .maybeSingle();
  }
}
