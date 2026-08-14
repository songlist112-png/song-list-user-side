import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> validateOrStartTrial() async {
    final response = await _client.rpc('validate_or_start_subscription');
    if (response is! Map) {
      throw const FormatException('Invalid subscription response');
    }
    return Map<String, dynamic>.from(response);
  }
}
